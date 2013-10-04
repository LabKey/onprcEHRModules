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
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
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
import java.util.List;
import java.util.Map;

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
            lastInvoiceDate = DateUtils.round(new Date(0), Calendar.DATE);

        perDiemSummary(c, u, msg, lastInvoiceDate);
        leaseFeeSummary(c, u, msg, lastInvoiceDate);
        procedureSummary(c, u, msg, lastInvoiceDate);
        labworkSummary(c, u, msg, lastInvoiceDate);
        miscChargesSummary(c, u, msg, lastInvoiceDate);

        miscChargesLackingProjects(c, u, msg);

        simpleAlert(c, u , msg, "onprc_billing", "invalidChargeRateEntries", " charge rate records with invalid or overlapping intervals");
        simpleAlert(c, u , msg, "onprc_billing", "invalidChargeRateExemptionEntries", " charge rate exemptions with invalid or overlapping intervals");
        simpleAlert(c, u , msg, "onprc_billing", "invalidCreditAccountEntries", " credit account records with invalid or overlapping intervals");
        simpleAlert(c, u , msg, "onprc_billing", "duplicateChargeableItems", " active chargeable item records with duplicate names or item codes");

        return msg.toString();
    }

    private void perDiemSummary(Container c, User u, final StringBuilder msg, Date lastInvoiceEnd)
    {
        UserSchema us = QueryService.get().getUserSchema(u, c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME);
        QueryDefinition qd = us.getQueryDefForTable("perDiemRates");
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);

        Map<String, Object> params = new HashMap<>();

        Calendar start = Calendar.getInstance();
        start.setTime(lastInvoiceEnd);
        start.add(Calendar.DATE, 1);

        Calendar endDate = Calendar.getInstance();
        endDate.setTime(new Date());
        endDate.add(Calendar.DATE, 1);

        Long numDays = ((DateUtils.round(new Date(), Calendar.DATE).getTime() - start.getTimeInMillis()) / DateUtils.MILLIS_PER_DAY) + 1;
        params.put("StartDate", start.getTime());
        params.put("EndDate", endDate.getTime());
        params.put("NumDays", numDays.intValue());

        SQLFragment sql = ti.getFromSQL("t");
        QueryService.get().bindNamedParameters(sql, params);

        sql = new SQLFragment("SELECT sum(t.totalcost) as totalCost, count(*) as total, " +
                "sum(COALESCE(CASE WHEN t.isExemption IS NULL THEN 0 ELSE 1 END, 0)) as totalExemptions, " +
                "sum(COALESCE(CASE WHEN (t.categories IS NOT NULL AND t.categories LIKE '%Multiple%') THEN 1 ELSE 0 END, 0)) as totalMultipleAssignments, " +
                "sum(COALESCE(CASE WHEN (t.lacksRate IS NOT NULL) THEN 1 ELSE 0 END, 0)) as totalLackingCost, " +
                "sum(COALESCE(CASE WHEN (t.project IS NULL) THEN 1 ELSE 0 END, 0)) as totalLackingProject, " +
                "sum(COALESCE(CASE WHEN (t.isMiscCharge = 'Y') THEN 1 ELSE 0 END, 0)) as totalMiscCharge, " +
                "sum(COALESCE(CASE WHEN (t.creditAccount IS NULL) THEN 1 ELSE 0 END, 0)) as totalLackingCreditAccount " +
                "FROM " + sql.getSQL(), sql.getParams());
        QueryService.get().bindNamedParameters(sql, params);
        SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
        List<Map<String, Object>> rows = new ArrayList<>(ss.getMapCollection());

        Long total = (rows.size() > 0) ? Long.parseLong(rows.get(0).get("total").toString()) : 0;
        Integer totalExemptions = (rows.size() > 0 && rows.get(0).get("totalExemptions") != null) ? (Integer)rows.get(0).get("totalExemptions") : 0;
        Integer totalMiscCharges = (rows.size() > 0 && rows.get(0).get("totalMiscCharge") != null) ? (Integer)rows.get(0).get("totalMiscCharge") : 0;
        Integer totalMultipleAssignments = (rows.size() > 0 && rows.get(0).get("totalMultipleAssignments") != null) ? (Integer)rows.get(0).get("totalMultipleAssignments") : 0;
        Integer totalLackingCost = (rows.size() > 0 && rows.get(0).get("totalLackingCost") != null) ? (Integer)rows.get(0).get("totalLackingCost") : 0;
        Integer totalLackingCreditAccount = (rows.size() > 0 && rows.get(0).get("totalLackingCreditAccount") != null) ? (Integer)rows.get(0).get("totalExemptions") : 0;
        Integer totalLackingProject = (rows.size() > 0 && rows.get(0).get("totalLackingProject") != null) ? (Integer)rows.get(0).get("totalLackingProject") : 0;

        Double totalCost = (rows.size() > 0 && rows.get(0).get("totalCost") != null) ? (Double)rows.get(0).get("totalCost") : 0.0;

        msg.append("<b>Per Diems:</b><p>");
        msg.append("There have been " + total + " items since the last invoice date of " + _dateFormat.format(lastInvoiceEnd) + ", for a total of " + _dollarFormat.format(totalCost) + ".");
        String url = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, "perDiemRates", null) + "&query.param.StartDate=" + _dateFormat.format(start.getTime()) + "&query.param.EndDate=" + _dateFormat.format(endDate.getTime()) + "&query.param.NumDays=" + numDays;

        StringBuilder specialMessages = new StringBuilder();
        if (totalLackingProject > 0)
            specialMessages.append("- <a href='" + url + "&query.project~isblank'>There are " + totalLackingProject + " items without a project.</a><br>");
        if (totalExemptions > 0)
            specialMessages.append("- <a href='" + url + "&query.isExemption~isnonblank'>There are " + totalExemptions + " items using special fees.</a><br>");
        if (totalLackingCost > 0)
            specialMessages.append("- <a href='" + url + "&query.lacksRate~isnonblank'>There are " + totalLackingCost + " items without a unit cost.  This probably means there is an issue with the rate or fee structure.</a><br>");
        if (totalMiscCharges > 0)
            specialMessages.append("- <a href='" + url + "&query.isMiscCharge~eq=Y'>There are " + totalMiscCharges + " items that are either adjustments or charges entered after the normal billing period.</a><br>");
        if (totalLackingCreditAccount > 0)
            specialMessages.append("- <a href='" + url + "&query.creditAccount~isblank'>There are " + totalLackingCreditAccount + " items without a credit alias.  This probably means there is an issue with the rate or fee structure.</a><br>");
        if (totalMultipleAssignments > 0)
            specialMessages.append("- <a href='" + url + "&query.categories~contains=Multiple'>There are " + totalMultipleAssignments + " items which include dual-assignments.</a><br>");

        if (specialMessages.length() > 0)
        {
            msg.append("<p>");
            msg.append(specialMessages);
            msg.append("<br>");
        }
        else
        {
            msg.append("<p>");
        }

        msg.append("<a href='" + url + "'>Click here to view all items</a><br><hr>");
    }

    private void leaseFeeSummary(Container c, User u, final StringBuilder msg, Date lastInvoiceEnd)
    {
        getSummary(c, u, msg, lastInvoiceEnd, "leaseFeeRates", "Lease Fees");
    }

    private void procedureSummary(Container c, User u, final StringBuilder msg, Date lastInvoiceEnd)
    {
        getSummary(c, u, msg, lastInvoiceEnd, "procedureFeeRates", "Procedure Charges");
    }

    private void labworkSummary(Container c, User u, final StringBuilder msg, Date lastInvoiceEnd)
    {
        getSummary(c, u, msg, lastInvoiceEnd, "labworkFeeRates", "Labwork Charges");
    }

    private void miscChargesSummary(Container c, User u, final StringBuilder msg, Date lastInvoiceEnd)
    {
        getSummary(c, u, msg, lastInvoiceEnd, "miscChargesFeeRates", "Other Charges");
    }

    private void getSummary(Container c, User u, final StringBuilder msg, Date lastInvoiceEnd, String queryName, String title)
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
        params.put("StartDate", start.getTime());
        params.put("EndDate", endDate.getTime());

        boolean hasMatchesProjectCol = ti.getColumn(FieldKey.fromString("matchesProject")) != null;
        boolean hasInvoicedItemIdCol = ti.getColumn(FieldKey.fromString("invoicedItemId")) != null;
        boolean hasMiscChargeCol = ti.getColumn(FieldKey.fromString("isMiscCharge")) != null;

        SQLFragment sql = ti.getFromSQL("t");
        QueryService.get().bindNamedParameters(sql, params);

        sql = new SQLFragment("SELECT sum(t.totalcost) as totalCost, count(*) as total, " +
                "sum(COALESCE(CASE WHEN t.isExemption IS NULL THEN 0 ELSE 1 END, 0)) as totalExemptions, " +
                "sum(COALESCE(CASE WHEN (t.lacksRate IS NOT NULL) THEN 1 ELSE 0 END, 0)) as totalLackingCost, " +
                "sum(COALESCE(CASE WHEN (t.project IS NULL) THEN 1 ELSE 0 END, 0)) as totalLackingProject, " +
                (hasMatchesProjectCol ? "sum(COALESCE(CASE WHEN t.matchesProject = " + ti.getSqlDialect().getBooleanFALSE() + " THEN 1 ELSE 0 END, 0)) as totalMismatchingProject, " : "") +
                (hasInvoicedItemIdCol ? "sum(COALESCE(CASE WHEN t.invoicedItemId IS NULL THEN 0 ELSE 1 END, 0)) as totalReversals, " : "") +
                (hasMiscChargeCol ? "sum(COALESCE(CASE WHEN (t.isMiscCharge = 'Y') THEN 1 ELSE 0 END, 0)) as totalMiscCharge, " : "") +
                "sum(COALESCE(CASE WHEN (t.creditAccount IS NULL) THEN 1 ELSE 0 END, 0)) as totalLackingCreditAccount " +
                "FROM " + sql.getSQL(), sql.getParams());
        QueryService.get().bindNamedParameters(sql, params);
        SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
        List<Map<String, Object>> rows = new ArrayList<>(ss.getMapCollection());

        Long total = (rows.size() > 0) ? Long.parseLong(rows.get(0).get("total").toString()) : 0;
        Integer totalExemptions = (rows.size() > 0 && rows.get(0).get("totalExemptions") != null) ? (Integer)rows.get(0).get("totalExemptions") : 0;
        Integer totalLackingCost = (rows.size() > 0 && rows.get(0).get("totalLackingCost") != null) ? (Integer)rows.get(0).get("totalLackingCost") : 0;
        Integer totalLackingCreditAccount = (rows.size() > 0 && rows.get(0).get("totalLackingCreditAccount") != null) ? (Integer)rows.get(0).get("totalExemptions") : 0;
        Integer totalLackingProject = (rows.size() > 0 && rows.get(0).get("totalLackingProject") != null) ? (Integer)rows.get(0).get("totalLackingProject") : 0;

        Double totalCost = (rows.size() > 0 && rows.get(0).get("totalCost") != null) ? (Double)rows.get(0).get("totalCost") : 0.0;

        Integer totalMismatchingProject = 0;
        if (hasMatchesProjectCol)
        {
            totalMismatchingProject = (rows.size() > 0 && rows.get(0).get("totalMismatchingProject") != null) ? (Integer)rows.get(0).get("totalMismatchingProject") : 0;
        }

        Integer totalReversals = 0;
        if (hasInvoicedItemIdCol)
        {
            totalReversals = (rows.size() > 0 && rows.get(0).get("totalReversals") != null) ? (Integer)rows.get(0).get("totalReversals") : 0;
        }

        Integer totalMiscCharges = 0;
        if (hasMiscChargeCol)
        {
            totalMiscCharges = (rows.size() > 0 && rows.get(0).get("totalMiscCharge") != null) ? (Integer)rows.get(0).get("totalMiscCharge") : 0;
        }

        msg.append("<b>" + title + ":</b><p>");
        msg.append("There have been " + total + " items since the last invoice date of " + _dateFormat.format(lastInvoiceEnd) + ", for a total of " + _dollarFormat.format(totalCost) + ".");
        String url = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, queryName, null) + "&query.param.StartDate=" + _dateFormat.format(start.getTime()) + "&query.param.EndDate=" + _dateFormat.format(endDate.getTime());

        StringBuilder specialMessages = new StringBuilder();
        if (totalLackingProject > 0)
            specialMessages.append("- <a href='" + url + "&query.project~isblank'>There are " + totalLackingProject + " items without a project.</a><br>");
        if (totalExemptions > 0)
            specialMessages.append("- <a href='" + url + "&query.isExemption~isnonblank'>There are " + totalExemptions + " items using special fees.</a><br>");
        if (totalLackingCost > 0)
            specialMessages.append("- <a href='" + url + "&query.lacksRate~isnonblank'>There are " + totalLackingCost + " items without a unit cost.  This probably means there is an issue with the rate or fee structure.</a><br>");
        if (totalMiscCharges > 0)
            specialMessages.append("- <a href='" + url + "&query.isMiscCharge~eq=Y'>There are " + totalMiscCharges + " items that are either adjustments or charges entered after the normal billing period.</a><br>");
        if (totalLackingCreditAccount > 0)
            specialMessages.append("- <a href='" + url + "&query.creditAccount~isblank'>There are " + totalLackingCreditAccount + " items without a credit alias.  This probably means there is an issue with the rate or fee structure.</a><br>");
        if (totalMismatchingProject > 0)
            specialMessages.append("- <a href='" + url + "&query.matchesProject~eq=false'>There are " + totalMismatchingProject + " items using a project that does not match the assignment on that date.</a><br>");
        if (totalReversals > 0)
            specialMessages.append("- <a href='" + url + "&query.invoicedItemId~isnonblank'>There are " + totalReversals + " items which are asjustments or reversals.</a><br>");

        if (specialMessages.length() > 0)
        {
            msg.append("<p>");
            msg.append(specialMessages);
            msg.append("<br>");
        }
        else
        {
            msg.append("<p>");
        }

        msg.append("<a href='" + url + "'>Click here to view all items</a><br><hr>");
    }

    private void miscChargesLackingProjects(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = QueryService.get().getUserSchema(u, c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME).getTable(ONPRC_EHRSchema.TABLE_MISC_CHARGES);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("invoiceId"), null);
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

        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("invoiceId"), null);
        filter2.addCondition(FieldKey.fromString("project/account"), null, CompareType.ISBLANK);
        TableSelector ts2 = new TableSelector(ti, PageFlowUtil.set("project"), filter2, null);
        long total2 = ts2.getRowCount();
        if (total2 > 0)
        {
            msg.append("<b>Warning: There are " + total2 + " charges listed that list a project without an alias</b><p>");
            String url2 = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, ONPRC_EHRSchema.TABLE_MISC_CHARGES, null) + "&query.project/account~isblank";
            msg.append("<a href='" + url2 + "&query.project~isblank'>Click here to view them</a>");
            msg.append("<hr>");
        }

        SimpleFilter filter3 = new SimpleFilter(FieldKey.fromString("invoiceId"), null);
        filter2.addCondition(FieldKey.fromString("project/enddateCoalesced"), new Date(), CompareType.DATE_GT);
        TableSelector ts3 = new TableSelector(ti, PageFlowUtil.set("project"), filter3, null);
        long total3 = ts3.getRowCount();
        if (total3 > 0)
        {
            msg.append("<b>Warning: There are " + total3 + " charges listed that list a project without an alias</b><p>");
            String url3 = getExecuteQueryUrl(c, ONPRC_EHRSchema.BILLING_SCHEMA_NAME, ONPRC_EHRSchema.TABLE_MISC_CHARGES, null) + "&query.project/enddateCoalesced~dategt=" + _dateFormat.format(new Date());
            msg.append("<a href='" + url3 + "&query.project~isblank'>Click here to view them</a>");
            msg.append("<hr>");
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
                    return r.getValue() == null ? null : DateUtils.round((Date)r.getValue(), Calendar.DATE);
                }
            }
        }

        return null;
    }
}
