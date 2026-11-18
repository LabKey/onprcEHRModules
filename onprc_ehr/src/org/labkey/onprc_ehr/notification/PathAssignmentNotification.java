/*
 * Copyright (c) 2024-2026 LabKey Corporation
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
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.util.Date;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Created by kollil on 10/24/2019.
 */

public class PathAssignmentNotification extends ColonyAlertsNotification
{
    public PathAssignmentNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Pathology Assignemnt Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Animal assignment alerts for Pathology: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 9 ? * MON";

    }

    @Override
    public String getScheduleDescription()
    {
        return "every Monday at 9Am";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to send animal assignments data to pathology every Monday!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        pathAssignmentAlert(c, u, msg);

        return msg.toString();
    }

    /**
     * Kollil, 11/05/2024 : Ticket # 11319, listing assignments made with release condition as 'terminal' with the anticipated release date. It could look something like this:
     * a. Query:    Assignment date = within the last 35 days, with 'projected release condition' = Terminal
     * b. Report:   Table with columns as attached (I created a custom view as an example, but you can include whatever info is relevant)
     **/
    private void pathAssignmentAlert(Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "study") == null)
        {
            msg.append("<b>Warning: The study schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }
        //assignments query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("pathAssignmentData", ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, null);
        long count = ts.getRowCount();

        //Get num of rows
        if (count > 0)
        {
            msg.append("<b>" + count + " assignments found with projected release condition = Terminal in the last 35 days:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "pathAssignmentData", null) + "&query.containerFilterName=AllFolders'>Click here to view the assignments in PRIME</a></p>\n");
            msg.append("<hr>");
        }
        else
        {
            msg.append("<b> There are no assignments found with projected release condition = Terminal in the last 35 days </b>");
            msg.append("<hr>");
        }

        //Display the daily report in the email
        if (count > 0)
        {
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("Sex"));
            columns.add(FieldKey.fromString("AgeInYearsRounded"));
            columns.add(FieldKey.fromString("project"));
            columns.add(FieldKey.fromString("Investigator"));
            columns.add(FieldKey.fromString("Title"));
            columns.add(FieldKey.fromString("date"));
            columns.add(FieldKey.fromString("enddate"));
            columns.add(FieldKey.fromString("projectedRelease"));
            columns.add(FieldKey.fromString("projectedReleaseCondition"));
            columns.add(FieldKey.fromString("assignCondition"));
            columns.add(FieldKey.fromString("releaseCondition"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, null);

            msg.append("<hr><b>Assignments:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#FFD700" + '"' + "style='font-weight: bold;'>");
            msg.append("<td>Id </td><td>Sex </td><td>Age (Years, Rounded) </td><td>Center Project </td><td>Investigator </td><td>Title </td><td>Assign Date </td><td>Release Date </td><td>Projected Release Date </td><td>Projected Release Condition </td><td>Condition At Assignment </td><td>Condition At Release </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));

                msg.append("<tr bgcolor = " + '"' + "#FFFACD" + '"' + ">");
                msg.append("<td><b> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a> </b></td>\n");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Sex")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("AgeInYearsRounded")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("project")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Investigator")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Title")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("date")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("enddate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("projectedRelease")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("projectedReleaseCondition")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("assigncondition")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("releasecondition")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table>");
        }
    }
}
