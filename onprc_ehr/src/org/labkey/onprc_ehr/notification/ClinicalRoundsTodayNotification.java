/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

//Created: 8-22-2016 R.blasa

public class ClinicalRoundsTodayNotification extends AbstractEHRNotification
{
    public ClinicalRoundsTodayNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Clinical Rounds Process Alerts";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Clinical Alerts: " + DateUtil.formatDateTime(c);
    }

    @Override
    public String getCronString()
    {
        return "0 0 16 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 4PM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to alert for Clinical rounds observations entered today, and not entered recently..";
    }

    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        animalsWithRounds(c, u, msg);         //Added: 8-22-2016 R.Blasa

        animalsWithoutRounds(c, u, msg);       //Added 8-29-2016

        return msg.toString();
    }

    protected void animalsWithoutRounds(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysSinceLastRounds"), 0, CompareType.GT);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("category"), "Clinical", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive", CompareType.EQUAL);

        TableInfo ti = getStudySchema(c, u).getTable("cases");
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("Id/curLocation/room"));
        keys.add(FieldKey.fromString("Id/curLocation/cage"));
        keys.add(FieldKey.fromString("daysSinceLastRounds"));
        keys.add(FieldKey.fromString("assignedvet/DisplayName"));
        keys.add(FieldKey.fromString("allProblemCategories"));
        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, keys);

        TableSelector ts = new TableSelector(ti, cols.values(), filter, new Sort("Id/curLocation/room_sortValue,Id/curLocation/cage_sortValue"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active cases that do not have obs entered today.</b><br>");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'><td>Room</td><td>Cage</td><td>Id</td><td>Assigned Vet</td><td>Problem(s)</td><td>Days Since Last Rounds</td></tr>");

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, cols);
                    msg.append("<tr>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("Id/curLocation/room")), "None") + "</td>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("Id/curLocation/cage")), "") + "</td>");
                    msg.append("<td>" + rs.getString(FieldKey.fromString("Id")) + "</td>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("assignedvet/DisplayName")), "None") + "</td>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("allProblemCategories")), "None") + "</td>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("daysSinceLastRounds")), "") + "</td>");
                    msg.append("</tr>");
                }
            });

            msg.append("</table>");
            msg.append("<hr>\n");
        }
    }


    private String safeAppend(String val, String emptyText)
    {
        return val == null ? emptyText : val;
    }


    //Modified: 8-15-2016  R.Blasa     Show Clinical open cases that were entered
    protected void animalsWithRounds(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysSinceLastRounds"), 0, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("category"), "Clinical", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive", CompareType.EQUAL);

        TableInfo ti = getStudySchema(c, u).getTable("cases");
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("Id/curLocation/room"));
        keys.add(FieldKey.fromString("Id/curLocation/cage"));
        keys.add(FieldKey.fromString("daysSinceLastRounds"));
        keys.add(FieldKey.fromString("assignedvet/DisplayName"));
        keys.add(FieldKey.fromString("allProblemCategories"));
        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, keys);

        TableSelector ts = new TableSelector(ti, cols.values(), filter, new Sort("Id/curLocation/room_sortValue,Id/curLocation/cage_sortValue"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>CONFIRMATION: There are " + count + " active cases that have their obs entered today.</b><br>");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'><td>Room</td><td>Cage</td><td>Id</td><td>Assigned Vet</td><td>Problem(s)</td></tr>");

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, cols);
                    msg.append("<tr>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("Id/curLocation/room")), "None") + "</td>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("Id/curLocation/cage")), "") + "</td>");
                    msg.append("<td>" + rs.getString(FieldKey.fromString("Id")) + "</td>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("assignedvet/DisplayName")), "None") + "</td>");
                    msg.append("<td>" + safeAppend(rs.getString(FieldKey.fromString("allProblemCategories")), "None") + "</td>");

                    msg.append("</tr>");
                }
            });

            msg.append("</table>");
            msg.append("<hr>\n");
        }

    }

}