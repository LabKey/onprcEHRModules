/*
 * Copyright (c) 2013 LabKey Corporation
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
package org.labkey.onprc_ehr.notification;

import org.apache.commons.lang3.time.DateUtils;
import org.json.JSONObject;
import org.labkey.api.data.Aggregate;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryDefinition;
import org.labkey.api.query.QueryException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ehr.ONPRC_EHRSchema;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 4/5/13
 * Time: 2:25 PM
 */
public class FinanceNotification extends AbstractEHRNotification
{
    private static final DecimalFormat _dollarFormat = new DecimalFormat("$###,##0.00");

    @Override
    public String getName()
    {
        return "Finance Notification";
    }

    @Override
    public String getEmailSubject()
    {
        return "Finance/Billing Alerts: " + _dateTimeFormat.format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 8 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 8:00AM";
    }

    @Override
    public String getDescription()
    {
        return "This report is designed to provide a daily summary of current or projected charges since the last invoice date.  It will summarize the total dollar amount, as well as flag suspicious or incomplete items.";
    }

    @Override
    public String getMessage(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        Date now = new Date();
        msg.append(getDescription() + "  It was run on: " + _dateFormat.format(now) + " at " + _timeFormat.format(now) + ".<p>");

        Date lastInvoiceDate = getLastInvoiceDate(c, u);
        //if we have no previous value, set to an arbitrary value
        if (lastInvoiceDate == null)
            lastInvoiceDate = DateUtils.truncate(new Date(0), Calendar.DATE);

        getProjectSummary(c, u, msg, lastInvoiceDate, "perDiemRates", "Per Diems");
        getProjectSummary(c, u, msg, lastInvoiceDate, "leaseFeeRates", "Lease Fees");
        getProjectSummary(c, u, msg, lastInvoiceDate, "procedureFeeRates", "Procedure Charges");
        getProjectSummary(c, u, msg, lastInvoiceDate, "labworkFeeRates", "Labwork Charges");
        getProjectSummary(c, u, msg, lastInvoiceDate, "miscChargesFeeRates", "Other Charges");

        miscChargesLackingProjects(c, u, msg);

        getExpiredAliases(c, u , msg);
        getProjectsWithoutAliases(c, u, msg);
        chargesMissingRates(c, u, msg);
        simpleAlert(c, u , msg, "onprc_billing", "invalidChargeRateEntries", " charge rate records with invalid or overlapping intervals.  This indicates a problem with how the records are setup in the system and may cause problems with the billing calculation.");
        simpleAlert(c, u , msg, "onprc_billing", "invalidChargeRateExemptionEntries", " charge rate exemptions with invalid or overlapping intervals.  This indicates a problem with how the records are setup in the system and may cause problems with the billing calculation.");
        simpleAlert(c, u , msg, "onprc_billing", "invalidCreditAccountEntries", " credit account records with invalid or overlapping intervals.  This indicates a problem with how the records are setup in the system and may cause problems with the billing calculation.");
        simpleAlert(c, u , msg, "onprc_billing", "duplicateChargeableItems", " active chargeable item records with duplicate names or item codes.  This indicates a problem with how the records are setup in the system and may cause problems with the billing calculation.");

        return msg.toString();
    }

    private class FieldDescriptor {
        private String _fieldName;
        private boolean _flagIfNonNull;
        private String _label;

        public FieldDescriptor(String fieldName, boolean flagIfNonNull, String label)
        {            
            _fieldName = fieldName;
            _flagIfNonNull = flagIfNonNull;
            _label = label;
        }

        public String getFieldName()
        {
            return _fieldName;
        }

        public FieldKey getFieldKey()
        {
            return FieldKey.fromString(_fieldName);
        }

        public String getLabel()
        {
            return _label;
        }

        public boolean shouldFlag(Object val)
        {
            return _flagIfNonNull ? val != null : val == null;
        }

        public String getFilter()
        {
            return "&query." + getFieldName() + "~" + (_flagIfNonNull ? "isnonblank" : "isblank");
        }
    }

    private FieldDescriptor[] _fields = new FieldDescriptor[]
    {
        new FieldDescriptor("project", false, "Missing Project"),
        new FieldDescriptor("isMissingAccount", true, "Missing Alias"),
        new FieldDescriptor("isExpiredAccount", true, "Expired Alias"),
        new FieldDescriptor("isMultipleProjects", true, "Multiple Research Projects"),
        new FieldDescriptor("lacksRate", true, "Lacks Rate"),
        new FieldDescriptor("isExemption", true, "Non-standard Rate"),
        new FieldDescriptor("creditAccount", false, "Missing Credit Alias"),
        new FieldDescriptor("matchesProject", true, "Project Does Not Match Assignment"),
        //new FieldDescriptor("chargeType", true),
        new FieldDescriptor("isMiscCharge", true, "Manually Entered")
    };

    private void getProjectSummary(Container c, User u, final StringBuilder msg, Date lastInvoiceEnd, String queryName, String title)
    {
        UserSchema us = QueryService.get().getUserSchema(u, c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME);
        QueryDefinition qd = us.getQueryDefForTable(queryName);
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);

        Calendar start = Calendar.getInstance();
        start.setTime(lastInvoiceEnd);
        start.add(Calendar.DATE, 1);

        Calendar endDate = Calendar.getInstance();
        endDate.setTime(new Date());
        endDate.add(Calendar.DATE, 1);

        Map<String, Object> params = new HashMap<>();
        Long numDays = ((DateUtils.truncate(new Date(), Calendar.DATE).getTime() - start.getTimeInMillis()) / DateUtils.MILLIS_PER_DAY) + 1;
        params.put("StartDate", start.getTime());
        params.put("EndDate", endDate.getTime());
        params.put("NumDays", numDays.intValue());

        List<FieldKey> fieldKeys = new ArrayList<>();
        for (ColumnInfo col : ti.getColumns())
        {
            fieldKeys.add(col.getFieldKey());
        }
        fieldKeys.add(FieldKey.fromString("project/displayName"));
        fieldKeys.add(FieldKey.fromString("project/investigatorId/financialAnalyst/lastName"));

        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, fieldKeys);
        TableSelector ts = new TableSelector(ti, cols.values(), null, null);
        ts.setNamedParameters(params);

        final Map<String, String> financialAnalystMap = new HashMap<>();

        final Map<String, Map<String, Integer>> projectMap = new TreeMap<>();
        final Set<FieldDescriptor> foundCols = new LinkedHashSet<>();
        final Map<String, Double> totalsMap = new HashMap<>();

        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                Results rs = new ResultsImpl(object, cols);

                Double totalCost = rs.getDouble(FieldKey.fromString("totalCost"));
                if (totalCost != null)
                {
                    Double t = totalsMap.containsKey("totalCost") ? totalsMap.get("totalCost") : 0.0;
                    t += totalCost;
                    totalsMap.put("totalCost", t);
                }

                Double quantity = rs.getDouble(FieldKey.fromString("quantity"));
                if (quantity != null)
                {
                    Double t = totalsMap.containsKey("total") ? totalsMap.get("total") : 0.0;
                    t += quantity;
                    totalsMap.put("total", t);
                }

                String projectDisplay = rs.getString(FieldKey.fromString("project/displayName"));
                if (projectDisplay == null)
                {
                    projectDisplay = "None";
                }

                String financialAnalyst = rs.getString(FieldKey.fromString("project/investigatorId/financialAnalyst/lastName"));
                if (financialAnalyst == null)
                {
                    financialAnalyst = "Not Assigned";
                }

                financialAnalystMap.put(projectDisplay, financialAnalyst);

                for (FieldDescriptor fd : _fields)
                {
                    if (!rs.hasColumn(fd.getFieldKey()))
                    {
                        continue;
                    }

                    Object val = rs.getObject(fd.getFieldKey());
                    if (fd.shouldFlag(val))
                    {
                        Map<String, Integer> values = projectMap.get(projectDisplay);
                        if (values == null)
                            values = new HashMap<>();


                        Integer count = values.containsKey(fd.getFieldName()) ? values.get(fd.getFieldName()) : 0;
                        count++;
                        values.put(fd.getFieldName(), count);

                        projectMap.put(projectDisplay, values);
                        if (!foundCols.contains(fd))
                            foundCols.add(fd);
                    }
                }
            }
        });

        msg.append("<b>" + title + ":</b><p>");
        msg.append("There have been " + totalsMap.get("total") + " items since the last invoice date of " + _dateFormat.format(lastInvoiceEnd) + ", for a total of " + _dollarFormat.format(totalsMap.get("totalCost")) + ".  ");
        final String baseUrl = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, queryName, null) + "&query.param.StartDate=" + _dateFormat.format(start.getTime()) + "&query.param.EndDate=" + _dateFormat.format(endDate.getTime());
        msg.append("<a href='" + baseUrl + "'>Click here to view all items</a><br>");

        msg.append("<table border=1 style='border-collapse: collapse;'><tr style='font-weight: bold;'><td>Project</td><td>Financial Analyst</td>");
        for (FieldDescriptor fd : _fields)
        {
            if (!foundCols.contains(fd))
            {
                continue;
            }

            msg.append("<td>" + fd.getLabel() + "</td>");
        }
        msg.append("</tr>");

        for (String projectDisplay : projectMap.keySet())
        {
            Map<String, Integer> totals = projectMap.get(projectDisplay);
            String projUrl = baseUrl + "&query.project/displayName~eq=" + projectDisplay;
            msg.append("<tr><td><a href='" + projUrl + "'>" + projectDisplay + "</a></td>");
            msg.append("<td>" + financialAnalystMap.get(projectDisplay) + "</td>");

            for (FieldDescriptor fd : _fields)
            {
                if (!foundCols.contains(fd))
                {
                    continue;
                }

                if (totals.containsKey(fd.getFieldName()))
                {
                    String url = projUrl + fd.getFilter();
                    msg.append("<td><a href='" + url + "'>" + totals.get(fd.getFieldName()) + "</a></td>");
                }
                else
                {
                    msg.append("<td></td>");
                }
            }

            msg.append("</tr>");

        }

        msg.append("</table><p><hr><p>");
    }

    private void miscChargesLackingProjects(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = QueryService.get().getUserSchema(u, c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME).getTable(ONPRC_EHRSchema.TABLE_MISC_CHARGES);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("invoiceId"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("project"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("project"), filter, null);
        long total = ts.getRowCount();
        if (total > 0)
        {
            msg.append("<b>Warning: There are " + total + " charges listed that lack a project</b><p>");
            String url = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, ONPRC_EHRSchema.TABLE_MISC_CHARGES, null) + "&query.project~isblank";
            msg.append("<a href='" + url + "&query.project~isblank'>Click here to view them</a>");
            msg.append("<hr>");
        }

        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("invoiceId"), null, CompareType.ISBLANK);
        filter2.addCondition(FieldKey.fromString("project/account"), null, CompareType.ISBLANK);
        TableSelector ts2 = new TableSelector(ti, PageFlowUtil.set("project"), filter2, null);
        long total2 = ts2.getRowCount();
        if (total2 > 0)
        {
            msg.append("<b>Warning: There are " + total2 + " charges listed that list a project without an alias</b><p>");
            String url2 = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, ONPRC_EHRSchema.TABLE_MISC_CHARGES, null) + "&" + filter2.toQueryString("query");
            msg.append("<a href='" + url2 + "'>Click here to view them</a>");
            msg.append("<hr>");
        }

        SimpleFilter filter3 = new SimpleFilter(FieldKey.fromString("invoiceId"), null, CompareType.ISBLANK);
        filter3.addCondition(FieldKey.fromString("project/enddateCoalesced"), new Date(), CompareType.DATE_GT);
        TableSelector ts3 = new TableSelector(ti, PageFlowUtil.set("project"), filter3, null);
        long total3 = ts3.getRowCount();
        if (total3 > 0)
        {
            msg.append("<b>Warning: There are " + total3 + " charges listed without a project</b><p>");
            String url3 = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, ONPRC_EHRSchema.TABLE_MISC_CHARGES, null) + "&" + filter3.toQueryString("query");
            msg.append("<a href='" + url3 + "'>Click here to view them</a>");
            msg.append("<hr>");
        }
    }

    private void chargesMissingRates(Container c, User u, StringBuilder msg)
    {
        Map<String, Object> params = Collections.<String, Object>singletonMap("date", new Date());
        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_billing").getTable("chargesMissingRate");
        if (params != null)
        {
            SQLFragment sql = ti.getFromSQL("t");
            QueryService.get().bindNamedParameters(sql, params);
            sql = new SQLFragment("SELECT * FROM " + sql);
            QueryService.get().bindNamedParameters(sql, params);

            SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
            long count = ss.getRowCount();

            if (count > 0)
            {
                msg.append("<b>Warning: there are " + count + " active charge items missing either a default rate or a default credit alias.  This may cause problems with the billing calculation.</b><p>");
                String url = getExecuteQueryUrl(c, "onprc_billing", "chargesMissingRate", null);
                url += "&query.param.Date=" + _dateFormat.format(new Date());

                msg.append("<a href='" + url + "'>Click here to view them</a>");
                msg.append("<hr>");
            }
        }
    }

    private void simpleAlert(Container c, User u, StringBuilder msg, String schemaName, String queryName, String message)
    {
        TableInfo ti = QueryService.get().getUserSchema(u, c, schemaName).getTable(queryName);
        TableSelector ts = new TableSelector(ti);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>Warning: there are " + count + " " + message + ".</b><p>");
            msg.append("<a href='" + getExecuteQueryUrl(c, schemaName, queryName, null) + "'>Click here to view them</a>");
            msg.append("<hr>");
        }
    }

    private Date getLastInvoiceDate(Container c, User u)
    {
        TableInfo ti = QueryService.get().getUserSchema(u, c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME).getTable(ONPRC_EHRSchema.TABLE_INVOICE_RUNS);
        TableSelector ts = new TableSelector(ti);
        Map<String, List<Aggregate.Result>> aggs = ts.getAggregates(Collections.singletonList(new Aggregate(FieldKey.fromString("billingPeriodEnd"), Aggregate.Type.MAX)));
        for (List<Aggregate.Result> ag : aggs.values())
        {
            for (Aggregate.Result r : ag)
            {
                if (r.getValue() instanceof Date)
                {
                    return r.getValue() == null ? null : DateUtils.truncate((Date)r.getValue(), Calendar.DATE);
                }
            }
        }

        return null;
    }

    private void getExpiredAliases(Container c, User u, StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "onprc_billing_public") == null)
        {
            msg.append("<b>Warning: the ONPRC billing schema has not been enabled in this folder, so the expired alias alert cannot run<p><hr>");
            return;
        }

        TableInfo ti = QueryService.get().getUserSchema(u, c, "ehr").getTable("project");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddateCoalesced"), "-0d", CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("account/aliasEnabled"), "Y", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("account"), null, CompareType.NONBLANK);
        TableSelector ts = new TableSelector(ti, filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>Warning: there are " + count + " active ONPRC projects with expired aliases.</b><p>");
            msg.append("<a href='" + getExecuteQueryUrl(c, "ehr", "project", "Alias Info") + "&" + filter.toQueryString("query") + "'>Click here to view them</a>");
            msg.append("<hr>");
        }

    }

    private void getProjectsWithoutAliases(Container c, User u, StringBuilder msg)
    {
        TableInfo ti = QueryService.get().getUserSchema(u, c, "ehr").getTable("project");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddateCoalesced"), "-0d", CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("account"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(ti, filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>Warning: there are " + count + " active ONPRC projects without an alias.</b><p>");
            msg.append("<a href='" + getExecuteQueryUrl(c, "ehr", "project", "Alias Info") + "&" + filter.toQueryString("query") + "'>Click here to view them</a>");
            msg.append("<hr>");
        }

    }
}
