/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.onprc_billing.pipeline;

import org.apache.commons.lang3.time.DateUtils;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.Results;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.pipeline.AbstractTaskFactory;
import org.labkey.api.pipeline.AbstractTaskFactorySettings;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedAction;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.util.FileType;
import org.labkey.api.util.GUID;
import org.labkey.onprc_billing.ONPRC_BillingSchema;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * User: bbimber
 * Date: 8/6/12
 * Time: 12:57 PM
 */
public class BillingTask extends PipelineJob.Task<BillingTask.Factory>
{
    private final static SimpleDateFormat _dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    private final static String MISC_CHARGES_QUERY = "miscChargesFeeRates";

    protected BillingTask(Factory factory, PipelineJob job)
    {
        super(factory, job);
    }

    public static class Factory extends AbstractTaskFactory<AbstractTaskFactorySettings, BillingTask.Factory>
    {
        public Factory()
        {
            super(BillingTask.class);
        }

        @Override
        public List<FileType> getInputTypes()
        {
            return Collections.emptyList();
        }

        @Override
        public String getStatusName()
        {
            return PipelineJob.TaskStatus.running.toString();
        }

        @Override
        public List<String> getProtocolActionNames()
        {
            return Arrays.asList("Calculating Billing Data");
        }

        @Override
        public BillingTask createTask(PipelineJob job)
        {
            return new BillingTask(this, job);
        }

        @Override
        public boolean isJobComplete(PipelineJob job)
        {
            return false;
        }
    }

    @Override
    @NotNull
    public RecordedActionSet run() throws PipelineJobException
    {
        RecordedAction action = new RecordedAction();

        Container ehrContainer = getEHRContainer();
        if (ehrContainer == null)
            throw new PipelineJobException("EHRStudyContainer has not been set");

        getJob().getLogger().info("Beginning process to save monthly billing data");

        try (DbScope.Transaction transaction = ExperimentService.get().ensureTransaction())
        {
            getOrCreateInvoiceRunRecord();

            loadTransactionNumber();
            leaseFeeProcessing(ehrContainer);
            perDiemProcessing(ehrContainer);
            slaPerDiemProcessing();
            proceduresProcessing(ehrContainer);
            labworkProcessing(ehrContainer);
            miscChargesProcessing(ehrContainer);

            transaction.commit();
        }

        return new RecordedActionSet(Collections.singleton(action));
    }

    private int _lastTransactionNumber;

    private void loadTransactionNumber()
    {
        SqlSelector se;
        if (DbScope.getLabKeyScope().getSqlDialect().isSqlServer())
            se = new SqlSelector(ONPRC_BillingSchema.getInstance().getSchema(), new SQLFragment("select max(cast(transactionNumber as integer)) as expr from " + ONPRC_BillingSchema.NAME+ "." + ONPRC_BillingSchema.TABLE_INVOICED_ITEMS + " WHERE transactionNumber not like '%[^0-9]%'"));
        else if (DbScope.getLabKeyScope().getSqlDialect().isPostgreSQL())
        {
            se = new SqlSelector(ONPRC_BillingSchema.getInstance().getSchema(), new SQLFragment("select max(cast(transactionNumber as integer)) as expr from " + ONPRC_BillingSchema.NAME+ "." + ONPRC_BillingSchema.TABLE_INVOICED_ITEMS + " WHERE transactionNumber ~ '^[0-9]$'"));
        }
        else
        {
            throw new UnsupportedOperationException("The billing pipeline is only supported on sqlserver and postgres");
        }

        Integer[] rows = se.getArray(Integer.class);

        if (rows.length == 1)
        {
            _lastTransactionNumber = rows[0] == null ? 0 : rows[0];
        }
        else if (rows.length == 0)
        {
            _lastTransactionNumber = 0;
        }
        else
        {
            throw new IllegalArgumentException("Improper value for lastTransactionNumber.  Returned " + rows.length + " rows");
        }
    }

    private int getNextTransactionNumber()
    {
        _lastTransactionNumber++;

        return _lastTransactionNumber;
    }

    private Container getEHRContainer()
    {
        return EHRService.get().getEHRStudyContainer(getJob().getContainer());
    }

    private BillingPipelineJobSupport getSupport()
    {
        return (BillingPipelineJobSupport)getJob();
    }

    private String _invoiceId = null;

    private String getOrCreateInvoiceRunRecord() throws PipelineJobException
    {
        if (_invoiceId != null)
            return _invoiceId;

        try
        {
            getJob().getLogger().info("Creating invoice run record");

            // first look for existing records overlapping the provided date range.
            // so this should not be a problem
            TableInfo invoiceRunsUser = QueryService.get().getUserSchema(getJob().getUser(), getJob().getContainer(), ONPRC_BillingSchema.NAME).getTable(ONPRC_BillingSchema.TABLE_INVOICE_RUNS);
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("billingPeriodStart"), getSupport().getEndDate(), CompareType.DATE_LTE);
            filter.addCondition(FieldKey.fromString("billingPeriodEnd"), getSupport().getStartDate(), CompareType.DATE_GTE);


            TableSelector ts = new TableSelector(invoiceRunsUser, filter, null);
            if (ts.exists())
            {
                throw new PipelineJobException("There is already an existing billing period that overlaps the provided interval");
            }

            if (getSupport().getEndDate().before(getSupport().getStartDate()) || getSupport().getEndDate().equals(getSupport().getStartDate()))
            {
                throw new PipelineJobException("Cannot create a billing run with an end date before the start date");
            }

            Date today = DateUtils.truncate(new Date(), Calendar.DATE);
            if (getSupport().getEndDate().after(today) || getSupport().getEndDate().equals(today))
            {
                throw new PipelineJobException("Cannot create a billing run with an end date in the future");
            }


            TableInfo invoiceRuns = ONPRC_BillingSchema.getInstance().getSchema().getTable(ONPRC_BillingSchema.TABLE_INVOICE_RUNS);

            Map<String, Object> toCreate = new CaseInsensitiveHashMap<>();
            toCreate.put("billingPeriodStart", getSupport().getStartDate());
            toCreate.put("billingPeriodEnd", getSupport().getEndDate());
            toCreate.put("runDate", new Date());
            toCreate.put("status", "Finalized");
            toCreate.put("comment", getSupport().getComment());

            //TODO: create/set an invoice #?
            //toCreate.put("invoiceNumber", null);

            toCreate.put("container", getJob().getContainer().getId());
            toCreate.put("objectid", new GUID().toString());
            toCreate.put("created", new Date());
            toCreate.put("createdby", getJob().getUser().getUserId());
            toCreate.put("modified", new Date());
            toCreate.put("modifiedby", getJob().getUser().getUserId());

            toCreate = Table.insert(getJob().getUser(), invoiceRuns, toCreate);
            _invoiceId = (String)toCreate.get("objectid");
            return _invoiceId;
        }
        catch (RuntimeSQLException e)
        {
            throw new PipelineJobException(e);
        }
    }

    private static final String[] invoicedItemsCols = new String[]{
            "Id",
            "date",
            "chargeId",
            "item",
            "itemcode", "category",
            "servicecenter",
            "project", "debitedaccount", "investigatorid", "faid", "firstname", "lastname", "department", "contactphone",
            "creditedaccount",
            "quantity", "unitCost", "totalcost",
            "rateId", "exemptionId", "creditaccountid", "comment", "transactionType", "sourceRecord", "chargeCategory"};

    private void writeToInvoicedItems(List<Map<String, Object>> rows, String[] colNames, String queryName, boolean allowNullProject) throws PipelineJobException
    {
        assert colNames.length >= invoicedItemsCols.length;

        try
        {
            String invoiceId = getOrCreateInvoiceRunRecord();

            TableInfo invoicedItems = ONPRC_BillingSchema.getInstance().getSchema().getTable(ONPRC_BillingSchema.TABLE_INVOICED_ITEMS);
            for (Map<String, Object> row : rows)
            {
                CaseInsensitiveHashMap<Object> toInsert = new CaseInsensitiveHashMap<>();
                toInsert.put("container", getJob().getContainer().getId());
                toInsert.put("createdby", getJob().getUser().getUserId());
                toInsert.put("created", new Date());
                toInsert.put("modifiedby", getJob().getUser().getUserId());
                toInsert.put("modified", new Date());
                toInsert.put("objectId", new GUID());
                toInsert.put("invoiceId", invoiceId);
                toInsert.put("transactionNumber", getNextTransactionNumber());

                int idx = 0;
                for (String field : invoicedItemsCols)
                {
                    String translatedKey = colNames[idx];
                    idx++;
                    if (translatedKey == null)
                        continue;

                    if (row.containsKey(translatedKey))
                    {
                        toInsert.put(field, row.get(translatedKey));
                    }
                }

                List<String> required = new ArrayList<>(Arrays.asList("date", "chargeId", "item", "servicecenter", "debitedaccount", "faid", "unitCost", "totalcost", "investigatorid"));
                if (!allowNullProject)
                {
                    required.add("project");
                }

                for (String field : required)
                {
                    if (toInsert.get(field) == null)
                    {
                        getJob().getLogger().warn("Missing value for field: {} for transactionNumber: {}", field, toInsert.get("transactionNumber"));
                    }
                }

                Table.insert(getJob().getUser(), invoicedItems, toInsert);
            }

            //update records in miscCharges to show proper invoiceId
            processMiscChargesRecords(rows, queryName);
        }
        catch (RuntimeSQLException e)
        {
            throw new PipelineJobException(e);
        }
    }

    private void leaseFeeProcessing(Container ehrContainer) throws PipelineJobException
    {
        getJob().getLogger().info("Caching Lease Fees");

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", getSupport().getStartDate());
        params.put("EndDate", getSupport().getEndDate());

        String[] colNames = new String[]{
                "Id",
                "date",
                "chargeId",
                "item",
                "chargeId/itemCode",
                "category",
                "serviceCenter",
                "project",
                "account",
                "investigatorId",
                "account/fiscalAuthority",
                "investigatorId/firstname",
                "investigatorId/lastname",
                "investigatorId/division",
                "investigatorId/phonenumber",
                "creditAccount",
                "quantity",
                "unitCost",
                "totalcost",
                null, //rateid
                "exemptionId",
                "creditAccountId",
                "comment",
                null, //transaction type
                "sourceRecord",
                "chargeCategory",
                "enddate", "projectedReleaseCondition", "releaseCondition", "assignCondition", "ageAtTime", "category", "leaseCharge1", "leaseCharge2",
            };

        String queryName = "leaseFeeRates";
        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", queryName, colNames, params);

        getJob().getLogger().info("{} rows found", rows.size());

        writeToInvoicedItems(rows, colNames, queryName, false);
        getJob().getLogger().info("Finished Caching Lease Fees");
    }

    private List<Map<String, Object>> getRowList(Container c, String schemaName, String queryName, String[] colNames, Map<String, Object> params)
    {
        UserSchema us = QueryService.get().getUserSchema(getJob().getUser(), c, schemaName);
        TableInfo ti = us.getTable(queryName);
        List<FieldKey> columns = new ArrayList<>();
        for (String col : colNames)
        {
            columns.add(FieldKey.fromString(col));
        }

        //also include isMiscCharge
        columns.add(FieldKey.fromString("isMiscCharge"));

        final Map<FieldKey, ColumnInfo> colKeys = QueryService.get().getColumns(ti, columns);
        for (FieldKey col : columns)
        {
            if (col == null)
                continue;

            if (!colKeys.containsKey(col))
            {
                getJob().getLogger().warn("Unable to find column with key: {} for table: {}", col, ti.getPublicName());
            }
        }

        TableSelector ts = new TableSelector(ti, colKeys.values(), null, null);
        ts.setNamedParameters(params);

        final List<Map<String, Object>> rows = new ArrayList<>();
        try (Results results = ts.getResults())
        {
            while (results.next())
            {
                Map<String, Object> ret = new HashMap<>();
                for (Map.Entry<FieldKey, ColumnInfo> entry: colKeys.entrySet())
                {
                    ret.put(entry.getKey().toString(), entry.getValue().getValue(results));
                }
                rows.add(ret);
            }
        }
        catch (SQLException e)
        {
            throw new RuntimeSQLException(e);
        }

        return rows;
    }

    private void perDiemProcessing(Container ehrContainer) throws PipelineJobException
    {
        getJob().getLogger().info("Caching Per Diem Fees");

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", getSupport().getStartDate());
        params.put("EndDate", getSupport().getEndDate());
        long numDays = Math.round(((Long)(getSupport().getEndDate().getTime() - getSupport().getStartDate().getTime())).doubleValue() / DateUtils.MILLIS_PER_DAY);
        numDays++;
        params.put("NumDays", (int) numDays);
        getJob().getLogger().info("Using start date: {}, end date: {}, with number of days: {}", _dateFormat.format(getSupport().getStartDate()), _dateFormat.format(getSupport().getEndDate()), (int) numDays);

        String[] colNames = new String[]{
                "Id",
                "date",
                "chargeId",
                "item",
                "chargeId/itemCode",
                "category",
                "serviceCenter",
                "project",
                "account",
                "investigatorId",
                "account/fiscalAuthority",
                "investigatorId/firstname",
                "investigatorId/lastname",
                "investigatorId/division",
                "investigatorId/phonenumber",
                "creditAccount",
                "quantity",
                "unitCost",
                "totalcost",
                "rateid",
                "exemptionId",
                "creditAccountId",
                "comment",
                null, //transaction type
                "sourceRecord", //source record
                "chargeCategory",

                "effectiveDays"};

        String queryName = "perDiemRates";
        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", queryName, colNames, params);
        getJob().getLogger().info("{} rows found", rows.size());

        writeToInvoicedItems(rows, colNames, queryName, false);
        getJob().getLogger().info("Finished Caching Per Diem Fees");
    }

    private void slaPerDiemProcessing() throws PipelineJobException
    {
        Container slaContainer = org.labkey.onprc_billing.ONPRC_BillingManager.get().getSLADataFolder(getJob().getContainer());
        if (slaContainer == null)
        {
            getJob().getLogger().error("Unable to find SLA container, skipping");
            return;
        }

        getJob().getLogger().info("Caching SLA Per Diem Fees");

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", getSupport().getStartDate());
        params.put("EndDate", getSupport().getEndDate());

        String[] colNames = new String[]{
                null, //no Id for SLA
                "date",
                "chargeId",
                "item",
                "chargeId/itemCode",
                "category",
                "chargeId/departmentCode",
                "project",
                "account",
                "investigatorId",
                "account/fiscalAuthority",
                "investigatorId/firstname",
                "investigatorId/lastname",
                "investigatorId/division",
                "investigatorId/phonenumber",
                "creditAccount",
                "quantity",
                "unitCost",
                "totalcost",
                "rateid",
                "exemptionId",
                "creditAccountId",
                "comment",
                null, //transaction type
                "sourceRecord",
                "chargeCategory",
                };

        String queryName = "slaPerDiemRates";
        List<Map<String, Object>> rows = getRowList(slaContainer, "onprc_billing", queryName, colNames, params);
        getJob().getLogger().info("{} rows found", rows.size());

        writeToInvoicedItems(rows, colNames, queryName, false);
        getJob().getLogger().info("Finished Caching Per Diem Fees");
    }

    private void proceduresProcessing(Container ehrContainer) throws PipelineJobException
    {
        getJob().getLogger().info("Caching Procedure Fees");

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", getSupport().getStartDate());
        params.put("EndDate", getSupport().getEndDate());
        String[] colNames = new String[]{
                "Id",
                "date",
                "chargeId",
                "item",
                "chargeId/itemCode",
                "category",
                "serviceCenter",
                "project",
                "account",
                "investigatorId",
                "account/fiscalAuthority",
                "investigatorId/firstname",
                "investigatorId/lastname",
                "investigatorId/division",
                "investigatorId/phonenumber",
                "creditAccount",
                "quantity",
                "unitCost",
                "totalcost",
                "rateid",
                "exemptionId",
                "creditAccountId",
                "comment",
                null, //transaction type
                "sourceRecord",
                "chargeCategory",

                "procedureId"
        };

        String queryName = "procedureFeeRates";
        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", queryName, colNames, params);
        getJob().getLogger().info("{} rows found", rows.size());

        writeToInvoicedItems(rows, colNames, queryName, false);
        getJob().getLogger().info("Finished Caching Procedure Fees");
    }

    private void labworkProcessing(Container ehrContainer) throws PipelineJobException
    {
        getJob().getLogger().info("Caching Labwork Fees");

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", getSupport().getStartDate());
        params.put("EndDate", getSupport().getEndDate());
        String[] colNames = new String[]{
                "Id",
                "date",
                "chargeId",
                "item",
                "chargeId/itemCode",
                "category",
                "serviceCenter",
                "project",
                "account",
                "investigatorId",
                "account/fiscalAuthority",
                "investigatorId/firstname",
                "investigatorId/lastname",
                "investigatorId/division",
                "investigatorId/phonenumber",
                "creditAccount",
                "quantity",
                "unitCost",
                "totalcost",
                "rateid",
                "exemptionId",
                "creditAccountId",
                "comment",
                null, //transaction type
                "sourceRecord",
                "chargeCategory",

                "servicerequested"
        };

        String queryName = "labworkFeeRates";
        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", queryName, colNames, params);
        getJob().getLogger().info("{} rows found", rows.size());

        writeToInvoicedItems(rows, colNames, queryName, false);
        getJob().getLogger().info("Finished Caching Labwork Fees");
    }

    private void miscChargesProcessing(Container ehrContainer) throws PipelineJobException
    {
        getJob().getLogger().info("Caching Other Charges");

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", getSupport().getStartDate());
        params.put("EndDate", getSupport().getEndDate());
        String[] colNames = new String[]{
                "Id",
                "date",
                "chargeId",
                "item",
                "chargeId/itemCode",
                "category",
                "serviceCenter",
                "project",
                "account",
                "investigatorId",
                "account/fiscalAuthority",
                "investigatorId/firstname",
                "investigatorId/lastname",
                "investigatorId/division",
                "investigatorId/phonenumber",
                "creditAccount",
                "quantity",
                "unitCost",
                "totalcost",
                "rateid",
                "exemptionId",
                "creditAccountId",
                "comment",
                null, //transaction type
                "sourceRecord",
                "chargeCategory"
        };

        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", MISC_CHARGES_QUERY, colNames, params);
        getJob().getLogger().info("{} rows found", rows.size());

        writeToInvoicedItems(rows, colNames, MISC_CHARGES_QUERY, true);

        getJob().getLogger().info("Finished Caching Other Charges");
    }

    private void processMiscChargesRecords(List<Map<String, Object>> rows, String queryName) throws PipelineJobException
    {
        try
        {
            getJob().getLogger().info("Potentially updating {} records in misc charges table for the query {}", rows.size(), queryName);
            TableInfo ti = DbSchema.get(ONPRC_BillingSchema.NAME).getTable(ONPRC_BillingSchema.TABLE_MISC_CHARGES);
            String invoiceId = getOrCreateInvoiceRunRecord();

            int updates = 0;
            int skipped = 0;
            for (Map<String, Object> row : rows)
            {
                //each query should have a flag to determine whether it is from miscCharges
                if (row.get("isMiscCharge") == null && !MISC_CHARGES_QUERY.equals(queryName))
                {
                    skipped++;
                    continue;
                }

                String objectId = (String)row.get("sourceRecord");
                if (objectId == null)
                {
                    getJob().getLogger().error("Misc Charges Record lacks objectid");
                    skipped++;
                    continue;
                }

                //we want to update this record set associate with this invoice
                Map<String, Object> toUpdate = new CaseInsensitiveHashMap<>();
                toUpdate.put("invoiceId", invoiceId);
                //NOTE: consider switching these changes into the current container?
                //i did not do this b/c it will be more difficult to re-run the miscChargesRates query retrospectively.
                //toUpdate.put("container", getJob().getContainer().getId());
                toUpdate.put("objectId", objectId);

                updates++;
                Table.update(getJob().getUser(), ti, toUpdate, objectId);
            }

            getJob().getLogger().info("updated {} records in misc charges table.  skipped {}", updates, skipped);
        }
        catch (RuntimeSQLException e)
        {
            throw new PipelineJobException(e);
        }
    }
}
