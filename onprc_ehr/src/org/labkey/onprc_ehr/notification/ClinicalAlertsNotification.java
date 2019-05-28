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

import org.apache.commons.lang3.StringUtils;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryDefinition;
import org.labkey.api.query.QueryException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.util.ResultSetUtil;

import java.sql.SQLException;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 4/26/13
 * Time: 9:09 AM
 */
public class ClinicalAlertsNotification extends ColonyAlertsNotification
{
    public ClinicalAlertsNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Clinical Alerts Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Clinical Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 30 5 ? * MON";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every Monday at 5:30AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed alert for any rooms or animals groups with high incidence of clinical problems";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        hospitalAnimalsOver30Days(c, u, msg);
        hospitalAnimalsWithoutCase(c, u, msg);
        groupProblemSummary(c, u, msg, 7, 5);
        groupProblemSummary(c, u, msg, 30, 10);
        roomProblemSummary(c, u, msg, 7, 5);
        roomProblemSummary(c, u, msg, 30, 10);
        duplicateCases(c, u, msg);

        return msg.toString();
    }

    protected void groupProblemSummary(final Container c, User u, final StringBuilder msg, int interval, double threshold)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, (-1 * interval));

        UserSchema us = getStudySchema(c, u);
        QueryDefinition qd = us.getQueryDefForTable("animalGroupProblemSummary");
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);
        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", cal.getTime());
        params.put("EndDate", new Date());
        Set<FieldKey> fieldKeys = new HashSet<>();
        fieldKeys.add(FieldKey.fromString("Id"));
        fieldKeys.add(FieldKey.fromString("groupId"));
        fieldKeys.add(FieldKey.fromString("groupId/name"));
        fieldKeys.add(FieldKey.fromString("groupId/majorityLocation/majorityLocation"));
        fieldKeys.add(FieldKey.fromString("category"));
        fieldKeys.add(FieldKey.fromString("totalIds"));
        fieldKeys.add(FieldKey.fromString("totalIdWithProblems"));
        fieldKeys.add(FieldKey.fromString("pctWithProblem"));
        Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, fieldKeys);

        Results rs = null;
        try
        {
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("pctWithProblem"), threshold, CompareType.GT);
            filter.addCondition(FieldKey.fromString("category"), "Routine", CompareType.DOES_NOT_CONTAIN);
            filter.addCondition(FieldKey.fromString("category"), "Other", CompareType.DOES_NOT_CONTAIN);

            rs = QueryService.get().select(ti, cols.values(), filter, new Sort("groupId/name"), params, true);
            int idx = 0;
            while (rs.next())
            {
                String url = getExecuteQueryUrl(c, "study", "animalGroupProblemSummary", null) + " &query.param.StartDate=" + getDateFormat(c).format(cal.getTime())+ "&query.param.EndDate=" + getDateFormat(c).format(new Date()) + "&query.pctWithProblem~gte=10&query.category~doesnotcontain=Routine&query.category~doesnotcontain=Other";
                if (idx == 0)
                {
                    msg.append("<b>WARNING: The following animal groups have a high incidence of clinical problems (>" + threshold + "% of animals) in the past " + interval + " days:</b><br>\n");
                    msg.append("<p><a href='" + url + "'>Click here to view them</a><br><br>\n\n");
                    msg.append("<table border=1 style='border-collapse: collapse;'>");
                    msg.append("<tr style='font-weight: bold;'><td>Group</td><td>Majority Location</td><td>Problem Category</td><td>Distinct Animals In Group</td><td>Distinct Animals With Problem</td><td>Percent With Problem</td></tr>");
                }
                idx++;

                String groupName = rs.getString(FieldKey.fromString("groupId/name"));
                String groupLocation = rs.getString(FieldKey.fromString("groupId/majorityLocation/majorityLocation"));
                String category = rs.getString(FieldKey.fromString("category"));
                String url2 = url + "&query.groupId/name~eq=" + groupName + "&query.category~eq=" + category;
                msg.append("<tr><td>").append(groupName).append("</td><td>").append(StringUtils.trimToEmpty(groupLocation)).append("</td><td>").append("<a href='" + url2 + "'>" + category + "</a>").append("</td><td>").append(rs.getInt("totalIds")).append("</td><td>").append(rs.getInt(FieldKey.fromString("totalIdWithProblems"))).append("</td><td>").append("<a href='" + url2 + "'>").append(NumberFormat.getInstance().format(rs.getDouble(FieldKey.fromString("pctWithProblem"))) + "%").append("</a>").append("</td></tr>");
            }

            if (idx > 0)
            {
                msg.append("</table>\n");
                msg.append("<hr>\n\n");
            }
        }
        catch (SQLException e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            ResultSetUtil.close(rs);
        }
    }

    protected void roomProblemSummary(final Container c, User u, final StringBuilder msg, int interval, double threshold)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, (-1 * interval));

        UserSchema us = getStudySchema(c, u);
        QueryDefinition qd = us.getQueryDefForTable("roomProblemSummary");
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);
        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", cal.getTime());
        params.put("EndDate", new Date());
        Set<FieldKey> fieldKeys = new HashSet<>();
        fieldKeys.add(FieldKey.fromString("Id"));
        fieldKeys.add(FieldKey.fromString("room"));
        fieldKeys.add(FieldKey.fromString("category"));
        fieldKeys.add(FieldKey.fromString("totalIds"));
        fieldKeys.add(FieldKey.fromString("totalIdWithProblems"));
        fieldKeys.add(FieldKey.fromString("pctWithProblem"));
        Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, fieldKeys);

        Results rs = null;
        try
        {
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("pctWithProblem"), threshold, CompareType.GT);
            filter.addCondition(FieldKey.fromString("category"), "Routine", CompareType.DOES_NOT_CONTAIN);
            filter.addCondition(FieldKey.fromString("category"), "Other", CompareType.DOES_NOT_CONTAIN);
            filter.addCondition(FieldKey.fromString("room/area"), "Hospital", CompareType.NEQ);
            filter.addCondition(FieldKey.fromString("totalIdWithProblems"), 2, CompareType.GT);

            rs = QueryService.get().select(ti, cols.values(), filter, new Sort("room/sort_order"), params, true);
            int idx = 0;
            while (rs.next())
            {
                String url = getExecuteQueryUrl(c, "study", "roomProblemSummary", null) + "&query.param.StartDate=" + getDateFormat(c).format(cal.getTime())+ "&query.param.EndDate=" + getDateFormat(c).format(new Date()) + "&query.pctWithProblem~gte=10&query.category~doesnotcontain=Routine&query.category~doesnotcontain=Other&query.room/area~neq=Hospital&query.totalIdWithProblems~gt=2";
                if (idx == 0)
                {
                    msg.append("<b>WARNING: The following non-hospital rooms have a high incidence of clinical problems (>" + threshold + "% of animals, with at least 2 animals afflicted) in the past " + interval + " days:</b><br>\n");
                    msg.append("<p><a href='" + url + "'>Click here to view them</a><br><br>\n\n");
                    msg.append("<table border=1 style='border-collapse: collapse;'>");
                    msg.append("<tr style='font-weight: bold;'><td>Room</td><td>Problem Category</td><td>Distinct Animals In Room</td><td>Distinct Animals With Problem</td><td>Percent With Problem</td></tr>");
                }
                idx++;

                String room = rs.getString(FieldKey.fromString("room"));
                String category = rs.getString(FieldKey.fromString("category"));
                String url2 = url + "&query.room~eq=" + room + "&query.category~eq=" + category;
                msg.append("<tr><td>").append(room).append("</td><td>").append("<a href='" + url2 + "'>" + category + "</a>").append("</td><td>").append(rs.getInt("totalIds")).append("</td><td>").append(rs.getInt(FieldKey.fromString("totalIdWithProblems"))).append("</td><td>").append("<a href='" + url2 + "'>").append(NumberFormat.getInstance().format(rs.getDouble(FieldKey.fromString("pctWithProblem"))) + "%").append("</a>").append("</td></tr>");
            }

            if (idx > 0)
            {
                msg.append("</table>\n");
                msg.append("<hr>\n\n");
            }
        }
        catch (SQLException e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            ResultSetUtil.close(rs);
        }
    }

    protected void hospitalAnimalsOver30Days(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/curLocation/area"), "Hospital", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room/housingType/value"), "Cage Location", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("daysInArea"), 30, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);

        TableInfo ti = getStudySchema(c, u).getTable("Housing");

        TableSelector ts = new TableSelector(ti, Collections.singleton(ti.getColumn("Id")), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals that have been housed in a cage location in the hospital for more than 30 days</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Housing", "Active Housing") + "&query.Id/curLocation/area~eq=Hospital&query.Id/curLocation/room/housingType/value~eq=Cage Location&query.enddate~isblank&query.daysInArea~gte=30'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }
}
