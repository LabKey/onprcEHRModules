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
import org.apache.commons.lang3.time.DateUtils;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Date;
import java.util.Map;
import java.util.List;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

/**
 * User: bimber
 * Date: 4/5/13
 * Time: 2:25 PM
 */
public class AdminNotifications extends ColonyAlertsNotification
{
    public AdminNotifications(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Admin Notifications";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Admin Notification: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 16 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 4:00PM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide admin notifications";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();
        msg.append("This email contains Admin alerts. It was run on: " + getDateFormat(c).format(now) + " at " + _timeFormat.format(now) + "<br><br><p>");

        MedsEndDateAlert(c, u, msg, new Date());
        return msg.toString();
    }

    private void MedsEndDateAlert(Container c, User u, final StringBuilder msg, final Date maxDate)
    {
        if (QueryService.get().getUserSchema(u, c, "onprc_ehr") == null) {
            msg.append("<b>Warning: The study schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }

        //Daily meds query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_ehr").getTable("MedsEndDateAlert", ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, new Sort("date"));
        long count = ts.getRowCount();
        if (count == 0) {
            msg.append("<b>There are no meds with missing enddate!</b><hr>");
        }
        else if (count > 0)
        {
            //Display the report link on the notification page
            msg.append("<br><b>Meds with missing end date:</b><br><br>");
            msg.append("<b>" + count + " meds found with missing end dates:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "MedsEndDateAlert", null) + "'>Click here to view the meds</a></p>\n");
            msg.append("<hr>");

            //Display the report in the email
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("date"));
            columns.add(FieldKey.fromString("enddate"));
            columns.add(FieldKey.fromString("frequency"));
            columns.add(FieldKey.fromString("treatmenttimes"));
            columns.add(FieldKey.fromString("project"));
            columns.add(FieldKey.fromString("code"));
            columns.add(FieldKey.fromString("volumewithunits"));
            columns.add(FieldKey.fromString("concentrationwithunits"));
            columns.add(FieldKey.fromString("amountwithunits"));
            columns.add(FieldKey.fromString("route"));
            columns.add(FieldKey.fromString("performedby"));
            columns.add(FieldKey.fromString("remark"));
            columns.add(FieldKey.fromString("reason"));
            columns.add(FieldKey.fromString("modifiedby"));
            columns.add(FieldKey.fromString("modified"));
            columns.add(FieldKey.fromString("category"));
            columns.add(FieldKey.fromString("taskid"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, new Sort("date"));

            // Table header
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr>");
            msg.append("<br><table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#00FF7F" + '"' + "style='font-weight: bold;'>");
            msg.append("<td> Id </td><td> Begin Date </td><td> End Date </td><td> Frequency </td><td> Times </td><td> Charge To </td><td> Treatment </td><td> Vomune </td><td> Concentration </td><td> Amount </td><td> Route </td><td> Ordered By </td><td> Remark </td><td> Reason </td><td> Modified By </td><td> Modified Date </td><td> Category </td><td> Task Id </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));

                msg.append("<td> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("date")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("enddate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("frequency")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("treatmentTimes")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("project")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("code")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("volumewithunits")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("concentrationwithunits")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("amountwithunits")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("route")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("performedby")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("remark")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("reason")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("modifiedby")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("modified")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("category")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("taskid")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table>");
        }

    }

}

