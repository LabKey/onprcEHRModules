/*
 * Copyright (c) 2013-2016 LabKey Corporation
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

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * User: bimber
 * Date: 4/5/13
 * Time: 2:25 PM
 */
public class RoutineClinicalTestsNotification extends ColonyAlertsNotification
{
    public RoutineClinicalTestsNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Routine Or Preventative Care Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Routine Or Preventative Care Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 15 10 ? * MON";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every Monday at 10:15AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a weekly summary of routine and preventative care due across the colony, such as TB tests, physical exams, and weights";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder sb = new StringBuilder();
        Date now = new Date();
        sb.append("This email contains a series of alerts and warnings about routine and preventative care due for the colony.  It was run on: " + getDateFormat(c).format(now) + " at " + AbstractEHRNotification._timeFormat.format(now) + ".<p>");

        getTbAlerts(sb, c, u);
        getPEAlerts(sb, c, u);
        getAnimalsNotWeightedInPast60Days(sb, c, u);

        //getVirologyAlerts(sb, c, u);

        return sb.toString();
    }

    protected void getTbAlerts(StringBuilder msg, Container c, User u)
    {
        msg.append("<b>TB Tests:</b><br><br>\n");

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("MonthsUntilDue"), 0, CompareType.LTE);
        filter.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("flags"), null, CompareType.ISBLANK);

        UserSchema us = getStudySchema(c, u);
        TableInfo ti = us.getTable("demographicsMostRecentTBDate");

        Set<ColumnInfo> cols = appendLocationCols(ti);
        TableSelector ts = new TableSelector(ti, cols, filter, null);
        long overdueCount = ts.getRowCount();
        if (overdueCount > 0)
        {
            String url = getExecuteQueryUrl(c, "study", "demographicsMostRecentTBDate", null) + "&query.MonthsUntilDue~lte=0&query.Id/demographics/calculated_status~eq=Alive&query.flags~isblank";
            msg.append("ALERT: There are " + overdueCount + " animals due for TB testing, and are not excluded from serologic testing.  <b><a href=\"" + url + "\">Click here to view them.</a></b><br><br>\n");
            msg.append("Summary by area:<br>\n");
            msg.append("<table>");
            Map<String, Integer> areaMap = getAreaMap(ts, cols);
            for (String area : areaMap.keySet())
            {
                String newUrl = url + "&query.Id/curLocation/area~eq=" + area;
                msg.append("<tr><td>" + area + ":</td><td><a href='" + newUrl + "'>" + areaMap.get(area) + "</a></td></tr>\n");
            }
            msg.append("</table>");
            msg.append("<br><br>");
        }

        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("MonthsUntilDue"), 1, CompareType.LTE);
        filter2.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive");
        filter2.addCondition(FieldKey.fromString("flags"), null, CompareType.ISBLANK);

        TableSelector ts2 = new TableSelector(ti, cols, filter2, null);
        long warnCount = ts2.getRowCount();
        if (warnCount > 0)
        {
            String url = getExecuteQueryUrl(c, "study", "demographicsMostRecentTBDate", null) + "&query.MonthsUntilDue~lte=1&query.Id/demographics/calculated_status~eq=Alive&query.flags~isblank";
            msg.append("WARNING: There are " + warnCount + " animals that will be due for TB testing within the next month, and are not excluded from serologic testing.  <b><a href=\"" + url + "\">Click here to view them.</a></b><br><br>\n");
            msg.append("Summary by area:<br>\n");
            msg.append("<table>");
            Map<String, Integer> areaMap = getAreaMap(ts2, cols);
            for (String area : areaMap.keySet())
            {
                String newUrl = url + "&query.Id/curLocation/area~eq=" + area;
                msg.append("<tr><td>" + area + ":</td><td><a href='" + newUrl + "'>" + areaMap.get(area) + "</a></td></tr>\n");
            }
            msg.append("</table>");
            msg.append("<br><br>");
        }

        msg.append("<hr>\n");
    }

    protected Map<String, Integer> getAreaMap(TableSelector ts, Set<ColumnInfo> cols)
    {
        final Map<String, Integer> areaMap = new TreeMap<>();
        final FieldKey areaKey = FieldKey.fromString("Id/curLocation/area");
        final Map<FieldKey, ColumnInfo> fieldKeyMap = new LinkedHashMap<>();
        for (ColumnInfo col : cols)
        {
            fieldKeyMap.put(col.getFieldKey(), col);
        }

        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                ResultsImpl rs = new ResultsImpl(object, fieldKeyMap);
                String area = rs.getString(areaKey);
                if (area != null)
                {
                    Integer count = areaMap.get(area);
                    if (count == null)
                        count = 0;

                    count++;

                    areaMap.put(area, count);
                }
            }
        });

        return areaMap;
    }

    protected Set<ColumnInfo> appendLocationCols(TableInfo ti)
    {
        Set<ColumnInfo> cols = new LinkedHashSet<>();
        cols.addAll(ti.getColumns());

        Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, PageFlowUtil.set(FieldKey.fromString("Id/curLocation/area"), FieldKey.fromString("Id/curLocation/room"), FieldKey.fromString("Id/curLocation/cage")));
        cols.addAll(colMap.values());

        return cols;
    }

    protected void getPEAlerts(StringBuilder msg, Container c, User u)
    {
        msg.append("<b>Physical Exams:</b><br><br>\n");

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysUntilNextExam"), 0, CompareType.LTE);
        filter.addCondition(FieldKey.fromString("Id/age/AgeInYears"), 1.0, CompareType.GTE);

        UserSchema us = getStudySchema(c, u);
        TableInfo ti = us.getTable("demographicsPE");

        Set<ColumnInfo> cols = appendLocationCols(ti);
        TableSelector ts = new TableSelector(ti, cols, filter, null);

        long overdueCount = ts.getRowCount();
        if (overdueCount > 0)
        {
            String url = getExecuteQueryUrl(c, "study", "demographicsPE", null) + "&query.daysUntilNextExam~lte=0&query.Id/age/ageInYears~gte=1";
            msg.append("ALERT: There are " + overdueCount + " animals over 1 yr. old due for Physical Exams.  <b><a href=\"" + url + "\">Click here to view them.</a></b><br><br>\n");
            msg.append("Summary by area:<br>\n");
            msg.append("<table>");
            Map<String, Integer> areaMap = getAreaMap(ts, cols);
            for (String area : areaMap.keySet())
            {
                String newUrl = url + "&query.Id/curLocation/area~eq=" + area;
                msg.append("<tr><td>" + area + ":</td><td><a href='" + newUrl + "'>" + areaMap.get(area) + "</a></td></tr>\n");
            }
            msg.append("</table>");
            msg.append("<br><br>");
        }

        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("daysUntilNextExam"), 30, CompareType.LTE);
        filter2.addCondition(FieldKey.fromString("Id/age/AgeInYears"), 1.0, CompareType.GTE);

        TableSelector ts2 = new TableSelector(ti, cols, filter2, null);
        long warnCount = ts2.getRowCount();
        if (warnCount > 0)
        {
            String url = getExecuteQueryUrl(c, "study", "demographicsPE", null) + "&query.daysUntilNextExam~lte=30&query.Id/age/ageInYears~gte=1";
            msg.append("WARNING: There are " + warnCount + " animals over 1 yr. old that will be due for Physical Exams within the next 30 days.  <b><a href=\"" + url + "\">Click here to view them.</a></b><br><br>\n");
            msg.append("Summary by area:<br>\n");
            msg.append("<table>");
            Map<String, Integer> areaMap = getAreaMap(ts2, cols);
            for (String area : areaMap.keySet())
            {
                String newUrl = url + "&query.Id/curLocation/area~eq=" + area;
                msg.append("<tr><td>" + area + ":</td><td><a href='" + newUrl + "'>" + areaMap.get(area) + "</a></td></tr>\n");
            }
            msg.append("</table>");
            msg.append("<br><br>");
        }

        msg.append("<hr>\n");
    }

    /**
     * find animals not weighed in the past 60 days
     * @param msg
     */
    protected void getAnimalsNotWeightedInPast60Days(StringBuilder msg, Container c, User u)
    {
        msg.append("<b>Weights:</b><br><br>\n");

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/MostRecentWeight/DaysSinceWeight"), 60, CompareType.GT);
        filter.addCondition(FieldKey.fromString("Id/curLocation/Room/housingType/value"), "Cage Location", CompareType.EQUAL);

        TableInfo ti = getStudySchema(c, u).getTable("demographics");

        Set<ColumnInfo> cols = appendLocationCols(ti);
        TableSelector ts = new TableSelector(ti, cols, filter, null);

        long count = ts.getRowCount();

        if (count > 0)
        {
            msg.append("WARNING: There are " + count + " animals in cage locations and have not been weighed in the past 60 days: ");
            String url = getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.Id/MostRecentWeight/DaysSinceWeight~gt=60&query.calculated_status~eq=Alive&query.Id/curLocation/Room/housingType/value~eq=Cage Location";
            msg.append("<b><a href='" + url + "'>Click here to view them.</a></b><br><br>\n");

            msg.append("Summary by area:<br>\n");
            msg.append("<table>");
            Map<String, Integer> areaMap = getAreaMap(ts, cols);
            for (String area : areaMap.keySet())
            {
                String newUrl = url + "&query.Id/curLocation/area~eq=" + area;
                msg.append("<tr><td>" + area + ":</td><td><a href='" + newUrl + "'>" + areaMap.get(area) + "</a></td></tr>\n");
            }
            msg.append("</table>");
            msg.append("<br><br>");
        }
        else
        {
            msg.append("There are no weight alerts");
        }

        msg.append("<hr>\n");
    }
}
