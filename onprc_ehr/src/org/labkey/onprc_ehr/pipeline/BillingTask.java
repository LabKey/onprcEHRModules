/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
package org.labkey.onprc_ehr.pipeline;

import au.com.bytecode.opencsv.CSVWriter;
import org.apache.commons.lang3.time.DateUtils;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
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
import org.labkey.onprc_ehr.ONPRC_EHRSchema;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.ResultSet;
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

        public List<FileType> getInputTypes()
        {
            return Collections.emptyList();
        }

        public String getStatusName()
        {
            return "RUNNING";
        }

        public List<String> getProtocolActionNames()
        {
            return Arrays.asList("Calculating Billing Data");
        }

        public PipelineJob.Task createTask(PipelineJob job)
        {
            BillingTask task = new BillingTask(this, job);

            return task;
        }

        public boolean isJobComplete(PipelineJob job)
        {
            return false;
        }
    }

    public RecordedActionSet run() throws PipelineJobException
    {
        RecordedAction action = new RecordedAction();

        Container ehrContainer = getEHRContainer();
        if (ehrContainer == null)
            throw new PipelineJobException("EHRStudyContainer has not been set");

        getJob().getLogger().info("Beginning process to save monthly billing data");

        ExperimentService.get().ensureTransaction();

        try
        {
            if (getSupport().isTestOnly())
            {
                getJob().getLogger().info("Performed test run only.  No records will be saved in the DB");
            }
            else
            {
                getOrCreateInvoiceRunRecord();
            }

            loadTransactionNumber();
            leaseFeeProcessing(ehrContainer);
            perDiemProcessing(ehrContainer);
            proceduresProcessing(ehrContainer);
            labworkProcessing(ehrContainer);
            miscChargesProcessing(ehrContainer);

            ExperimentService.get().commitTransaction();
        }
        finally
        {
            ExperimentService.get().closeTransaction();
        }

        return new RecordedActionSet(Collections.singleton(action));
    }

    private int _lastTransactionNumber;

    private void loadTransactionNumber()
    {
        SqlSelector se = new SqlSelector(ONPRC_EHRSchema.getInstance().getSchema(), new SQLFragment("select max(cast(transactionNumber as integer)) as expr from " + ONPRC_EHRSchema.BILLING_SCHEMA_NAME+ "." + ONPRC_EHRSchema.TABLE_INVOICED_ITEMS + " WHERE ISNUMERIC(transactionNumber) = " + DbScope.getLabkeyScope().getSqlDialect().getBooleanTRUE()));
        Integer[] rows = se.getArray(Integer.class);

        if (rows.length == 1)
        {
            _lastTransactionNumber = rows[0];
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

    private void writeToTsv(String fileName, List<Map<String, Object>> rows, String[] headers, String[] colNames) throws PipelineJobException
    {
        File csvFile = new File(getSupport().getAnalysisDir(), fileName + ".txt");
        if (csvFile.exists())
            throw new PipelineJobException("There is already a file with path: " + csvFile.getPath());

        try
        {
            csvFile.createNewFile();

            try (CSVWriter csv = new CSVWriter(new FileWriter(csvFile), '\t'))
            {
                csv.writeNext(headers);

                if (rows.size() > 0)
                {
                    for (Map<String, Object> row : rows)
                    {
                        String[] toWrite = new String[colNames.length];
                        int i = 0;
                        for (String colName: colNames)
                        {
                            toWrite[i] = getString(row.get(colName));
                            i++;
                        }

                        csv.writeNext(toWrite);
                    }
                }
            }
        }
        catch (IOException e)
        {
            throw new PipelineJobException(e);
        }
    }

    private String _invoiceId = null;

    private String getOrCreateInvoiceRunRecord() throws PipelineJobException
    {
        if (_invoiceId != null)
            return _invoiceId;

        try
        {
            getJob().getLogger().info("Creating invoice run record");

            // first look for existing records overlapping the provided date range.  this should never get called on test runs,
            // so this should not be a problem
            TableInfo invoiceRunsUser = QueryService.get().getUserSchema(getJob().getUser(), getJob().getContainer(), ONPRC_EHRSchema.BILLING_SCHEMA_NAME).getTable(ONPRC_EHRSchema.TABLE_INVOICE_RUNS);
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


            TableInfo invoiceRuns = ONPRC_EHRSchema.getInstance().getBillingSchema().getTable(ONPRC_EHRSchema.TABLE_INVOICE_RUNS);

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
        catch (SQLException e)
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
            "rateId", "exemptionId", "creditaccountid", "comment", "transactionType", "sourceRecord"};

    private void writeToInvoicedItems(List<Map<String, Object>> rows, String category, String[] colNames) throws PipelineJobException
    {
        assert colNames.length >= invoicedItemsCols.length;

        try
        {
            String invoiceId = getOrCreateInvoiceRunRecord();

            TableInfo invoicedItems = ONPRC_EHRSchema.getInstance().getBillingSchema().getTable(ONPRC_EHRSchema.TABLE_INVOICED_ITEMS);
            for (Map<String, Object> row : rows)
            {
                CaseInsensitiveHashMap toInsert = new CaseInsensitiveHashMap();
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

                List<String> required = Arrays.asList("date", "chargeId", "item", "servicecenter", "project", "debitedaccount", "faid", "unitCost", "totalcost");
                for (String field : required)
                {
                    if (toInsert.get(field) == null)
                    {
                        getJob().getLogger().warn("Missing value for field: " + field + " for transactionNumber: " + toInsert.get("transactionNumber"));
                    }
                }

                Table.insert(getJob().getUser(), invoicedItems, toInsert);
            }
        }
        catch (SQLException e)
        {
            throw new PipelineJobException(e);
        }
    }

    private String getString(Object val)
    {
        if (val == null)
        {
            return "";
        }
        else if (val instanceof Date)
        {
            return _dateFormat.format(val);
        }
        else if (val instanceof Number)
        {
            return val.toString();
        }

        return val.toString();
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
                //TODO: need these in the query itself to deal w/ misc charges
                "chargeId/itemCode",
                "category",
                "chargeId/departmentCode",  //todo: servicecenter?
                "project",
                "project/account",
                "investigatorId",
                "project/account/fiscalAuthority",
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
                null,  //comment
                null, //transaction type
                "sourceRecord",
                "enddate", "projectedReleaseCondition", "releaseCondition", "assignCondition", "ageAtTime", "category", "leaseCharge1", "leaseCharge2",
            };

        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", "leaseFeeRates", colNames, params);

        getJob().getLogger().info(rows.size() + " rows found");

        if (!getSupport().isTestOnly())
        {
            writeToInvoicedItems(rows, "Lease Fees", colNames);
        }
        else
        {
            String[] headers = new String[]{"Id", "Date", "End Date", "ONPRC Project", "Projected Release Condition", "Actual Release Condition", "Assign Condition", "Age At Time", "Category", "Charge Id", "Lease Charge 1", "Lease Charge 2", "Unit Cost", "Debit Alias", "Credit Alias", "Is Exemption?"};
            writeToTsv("leaseFees", rows, headers, colNames);
        }

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
        final Map<FieldKey, ColumnInfo> colKeys = QueryService.get().getColumns(ti, columns);
        for (FieldKey col : columns)
        {
            if (col == null)
                continue;

            if (!colKeys.containsKey(col))
            {
                getJob().getLogger().warn("Unable to find column with key: " + col.toString() + " for table: " + ti.getPublicName());
            }
        }

        TableSelector ts = new TableSelector(ti, colKeys.values(), null, null);
        ts.setNamedParameters(params);

        final List<Map<String, Object>> rows = new ArrayList<>();
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                Results rs = new ResultsImpl(object, colKeys);
                Map<String, Object> ret = new HashMap<>();
                for (FieldKey fk : colKeys.keySet())
                {
                    ret.put(fk.toString(), rs.getObject(fk));
                }
                rows.add(ret);
            }
        });

        return rows;
    }

    private void perDiemProcessing(Container ehrContainer) throws PipelineJobException
    {
        getJob().getLogger().info("Caching Per Diem Fees");

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", getSupport().getStartDate());
        params.put("EndDate", getSupport().getEndDate());
        Long numDays = (getSupport().getEndDate().getTime() - getSupport().getStartDate().getTime()) / DateUtils.MILLIS_PER_DAY;
        params.put("NumDays", numDays.intValue() + 1);

        String[] colNames = new String[]{
                "Id",
                "date",
                "chargeId",
                "item",
                //TODO: need these values in the query itself
                "chargeId/itemCode",
                "category",
                "chargeId/departmentCode",  //todo: servicecenter?
                "project",
                "project/account",
                "investigatorId",
                "project/account/fiscalAuthority",
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
                null,  //comment
                null, //transaction type
                null, //source record

                "effectiveDays"};
        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", "perDiemRates", colNames, params);
        getJob().getLogger().info(rows.size() + " rows found");

        if (!getSupport().isTestOnly())
        {
            writeToInvoicedItems(rows, "Per Diems", colNames);
        }
        else
        {
            String[] headers = new String[]{"Id", "ONPRC Project", "Charge Id", "Effective Days", "Unit Cost", "Debit Alias", "Credit Alias", "Is Exemption?"};
            writeToTsv("perDiems", rows, headers, colNames);
        }

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
                //TODO: need these values in the query itself
                "chargeId/itemCode",
                "category",
                "chargeId/departmentCode",  //todo: servicecenter?
                "project",
                "project/account",
                "investigatorId",
                "project/account/fiscalAuthority",
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
                null,  //comment
                null, //transaction type
                "sourceRecord",

                "procedureId"
        };
        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", "procedureFeeRates", colNames, params);
        getJob().getLogger().info(rows.size() + " rows found");

        if (!getSupport().isTestOnly())
        {
            writeToInvoicedItems(rows, "Procedure Fees", colNames);
        }
        else
        {
            String[] headers = new String[]{"Id", "Date", "ONPRC Project", "procedureId", "Charge Id", "Unit Cost", "Debit Alias", "Credit Alias", "Is Exemption?"};
            writeToTsv("procedureFees", rows, headers, colNames);
        }

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
                //TODO: need these values in the query itself
                "chargeId/itemCode",
                "category",
                "chargeId/departmentCode",  //todo: servicecenter?
                "project",
                "project/account",
                "investigatorId",
                "project/account/fiscalAuthority",
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
                null,  //comment
                null, //transaction type
                "sourceRecord",

                "servicerequested"
        };

        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", "labworkFeeRates", colNames, params);
        getJob().getLogger().info(rows.size() + " rows found");

        if (!getSupport().isTestOnly())
        {
            writeToInvoicedItems(rows, "Labwork Fees", colNames);
        }
        else
        {
            String[] headers = new String[]{"Id", "Date", "ONPRC Project", "servicerequested", "Charge Id", "Unit Cost", "Debit Alias", "Credit Alias", "Is Exemption?"};
            writeToTsv("labworkFees", rows, headers, colNames);
        }

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
                "chargeId/departmentCode",  //todo: servicecenter?
                "project",
                "account",
                "investigatorId",
                "project/account/fiscalAuthority",
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
        };

        List<Map<String, Object>> rows = getRowList(ehrContainer, "onprc_billing", "miscChargesFeeRates", colNames, params);
        getJob().getLogger().info(rows.size() + " rows found");

        if (!getSupport().isTestOnly())
        {
            try
            {
                writeToInvoicedItems(rows, "Other Charges", colNames);

                //update records in miscCharges to show proper invoiceId
                TableInfo ti = DbSchema.get(ONPRC_EHRSchema.BILLING_SCHEMA_NAME).getTable(ONPRC_EHRSchema.TABLE_MISC_CHARGES);
                String invoiceId = getOrCreateInvoiceRunRecord();

                for (Map<String, Object> row : rows)
                {
                    String objectId = (String)row.get("sourceRecord");
                    if (objectId == null)
                    {
                        getJob().getLogger().error("Misc Charges Record lacks objectid");
                        continue;
                    }

                    Map<String, Object> toUpdate = new CaseInsensitiveHashMap<>();
                    toUpdate.put("invoiceId", invoiceId);
                    toUpdate.put("objectId", objectId);

                    Table.update(getJob().getUser(), ti, toUpdate, objectId);
                }
            }
            catch (SQLException e)
            {
                throw new PipelineJobException(e);
            }
        }
        else
        {
            String[] headers = new String[]{"Id", "Date", "ONPRC Project", "Charge Id", "Quantity", "Unit Cost", "Debit Alias", "Credit Alias", "Is Exemption?"};
            writeToTsv("miscCharges", rows, headers, colNames);
        }

        getJob().getLogger().info("Finished Caching Other Charges");
    }
}
