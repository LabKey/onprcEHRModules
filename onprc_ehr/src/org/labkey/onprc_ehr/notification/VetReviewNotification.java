/*
 * Copyright (c) 2014-2016 LabKey Corporation
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

/*promoting to uat for verification*/
package org.labkey.onprc_ehr.notification;

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
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by bimber on 9/18/2014.
 */
public class VetReviewNotification extends ColonyAlertsNotification
{
    public VetReviewNotification (Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Vet Review Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Vet Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 15 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "daily at 3PM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed notify vets of any records needing review";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

       /* remarksWithoutAssignedVet(c, u, msg);*/
        DVMAlopeciaAlert(c,u,msg); //Added by Kolli, March 2026
        vetRecordsUnderReview(c, u, msg);
        animalsWithoutAssignedVet(c, u, msg);


        return msg.toString();
    }

    /* Added by Kollil 09/22/2025
    When BSU creates a case AND scores the alopecia at either 4 or 5 (only those scores)
    THEN the vet assigned to that animal should receive an alert. Show open cases in last 7 days
    Refer to old tkt # 12523, new tkt # 15401
    */
    private void DVMAlopeciaAlert(final Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("DVMAlertforAlopeciaCases");

        TableSelector ts = new TableSelector(ti, null, null);
        long total = ts.getRowCount();

        if (total > 0)
        {
            msg.append("<br><b>ALERT: <b> " + total + " animals found with alopecia score of 4 or 5 with open behavioral case for alopecia in the last 7 days. ");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "DVMAlertforAlopeciaCases", null)  + "'>Click here to view the data ina grid view</a>\n");
            msg.append("<hr>");

            //Display the report in the email
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("AlertObservationDate"));
            columns.add(FieldKey.fromString("AlopeciaScore"));
            columns.add(FieldKey.fromString("performedby"));
            columns.add(FieldKey.fromString("enteredSincevetReview"));
            columns.add(FieldKey.fromString("AssignedVet"));
            columns.add(FieldKey.fromString("BehaviorCaseOpenDate"));
            columns.add(FieldKey.fromString("VetReviewDueDate"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, new Sort("date"));

            // Table header
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'>");
            msg.append("<td> Id </td><td> Alert Observation Date </td><td> Alopecia Score </td><td> Performed by </td><td> Entered Since Vet Review </td><td> Assigned Vet </td><td> Behavior Case Open Date </td><td> Vet Review Due Date </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));

                msg.append("<td style='border: 1px solid black;'><b> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a> </b></td>\n");
                msg.append("<td style='border: 1px solid black;'>" + PageFlowUtil.filter(rs.getString("AlertObservationDate")) + "</td>");
                msg.append("<td style='border: 1px solid black;'>" + PageFlowUtil.filter(rs.getString("AlopeciaScore")) + "</td>");
                msg.append("<td style='border: 1px solid black;'>" + PageFlowUtil.filter(rs.getString("performedby")) + "</td>");
                msg.append("<td style='border: 1px solid black;'>" + PageFlowUtil.filter(rs.getString("enteredSincevetReview")) + "</td>");
                msg.append("<td style='border: 1px solid black;'>" + PageFlowUtil.filter(rs.getString("AssignedVet")) + "</td>");
                msg.append("<td style='border: 1px solid black;'>" + PageFlowUtil.filter(rs.getString("BehaviorCaseOpenDate")) + "</td>");
                msg.append("<td style='border: 1px solid black;'>" + PageFlowUtil.filter(rs.getString("VetReviewDueDate")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table><br><hr>");
        }

        else
        {
            msg.append("<b>WARNING: No animals found with alopecia score of 4 or 5 with open behavioral case for alopecia in last 7 days!</b><br><hr>\n");
        }


    }

    public void vetRecordsUnderReview(Container c, User u, final StringBuilder msg)
    {
        int duration = 7;
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("earliestRemarkSinceReview"), "-" + duration + "d", CompareType.DATE_LTE);
        doRemarkQuery(c, u, msg, filter, "ALERT: The following animals that have remarks entered at least " + duration + " days ago, but have not yet been reviewed.");
    }

    /*public void remarksWithoutAssignedVet(Container c, User u, final StringBuilder msg);
     {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/assignedVet/assignedVet"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("totalRemarksEnteredSinceReview"), 0, CompareType.GT);
        doRemarkQuery(c, u, msg, filter, "ALERT: The following animals that have remarks entered, but the animal is not currently assigned to a vet.");
    }*/

    public void doRemarkQuery(Container c, User u, final StringBuilder msg, SimpleFilter filter, String header)
    {
        //TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("demographics_AssignedVetNotification");
//        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("demographics_VetAssignment_Notification");
        //Changed by Kollil on 6/19/2019. Created a new query to get the vet assignment info
        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("demographics_Vet_Assignment_Alert");
        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, PageFlowUtil.set(
                FieldKey.fromString("Id"),
                FieldKey.fromString("calculated_status"),
                FieldKey.fromString("earliestRemarkSinceReview"),
                FieldKey.fromString("lastVetReview"),
                FieldKey.fromString("assignedVet")
        ));

        TableSelector ts = new TableSelector(ti, cols.values(), filter, new Sort("Id"));
        final List<String> rows = new ArrayList<>();
        final String urlBase = getExecuteQueryUrl(c, "study", "demographics", "Vet Review") + "&query.Id~eq=";
        ts.forEach(new Selector.ForEachBlock<>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                Results rs = new ResultsImpl(object, cols);

                rows.add("<tr><td>" +
                        "<a href='" + urlBase + rs.getString(FieldKey.fromString("Id")) + "'>" + rs.getString(FieldKey.fromString("Id")) + "</a></td>" +
                        "<td>" + (rs.getString(FieldKey.fromString("assignedVet")) == null ? "NONE" : rs.getString(FieldKey.fromString("assignedVet"))) + "</td>" +
                        "<td>" + getDateFormat(c).format(rs.getDate(FieldKey.fromString("earliestRemarkSinceReview"))) + "</td>" +
                        "<td>" + (rs.getDate(FieldKey.fromString("lastVetReview")) == null ? "Never" : getDateFormat(c).format(rs.getDate(FieldKey.fromString("lastVetReview")))) + "</td>" +
                        "<td>" + rs.getString(FieldKey.fromString("calculated_status")) + "</td>" +
                        "</tr>");
            }
        });

        if (!rows.isEmpty())
        {
            msg.append("<b>" + header + "</b><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'><tr><td>Id</td><td>Assigned Vet</td><td>Oldest Remark Needing Review</td><td>Last Vet Review</td><td>Status</td></tr>");
            for (String row : rows)
            {
                msg.append(row);
            }

            msg.append("</table><hr>\n\n");
        }
    }

    protected void animalsWithoutAssignedVet(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/assignedVet/assignedVet"), null, CompareType.ISBLANK);
        //TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("demographics_AssignedVetNotification"), filter, null);
//        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("demographics_VetAssignment_Notification"), filter, null);
        //Changed by Kollil on 6/19/2019. Created a new query to get the vet assignment info
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("demographics_Vet_Assignment_Alert"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " living animals that do not currently have an assigned vet.  Vet assignment is controlled by open cases, project assignment and housing.  This likely means the table governing which vets are assigned to the various locations/projects needs to be updated.</b><br>\n");

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "demographics", "By Location", filter) + "'>Click here to view the list of animals without an assigned vet</a></p>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "vet_assignment_summary", null) + "'>Click here to view or update the rules governing vet assignment</a></p>\n");
            msg.append("<hr>\n");
        }
    }
}
