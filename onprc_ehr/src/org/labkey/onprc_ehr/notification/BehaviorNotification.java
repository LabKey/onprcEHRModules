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

import org.apache.commons.lang3.time.DateUtils;
import org.json.JSONObject;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryDefinition;
import org.labkey.api.query.QueryException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 4/5/13
 * Time: 2:25 PM
 */
public class BehaviorNotification extends ColonyAlertsNotification
{
    public BehaviorNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Behavior Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Behavior Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 5 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 5:00AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a daily summary of issues related to behavior management, such as housing, pairing, and behavior cases";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        Map<String, String> saved = getSavedValues(c);
        Map<String, String> toSave = new HashMap<>();

        StringBuilder msg = new StringBuilder();

        msg.append(getDescription()).append("<hr>");

        colonyHousingSummary(c, u, msg, saved, toSave);
        behaviorCaseSummary(c, u, msg);
        getFlaggedPairs(c, u, msg);
        changedPairs(c, u, msg);
        singleHousedAnimals(c, u, msg);
        transfersYesterday(c, u, msg);
        surgeryCasesRecentlyClosed(c, u, msg);
        pairIdConflicts(c, u , msg);
        NHPTraining_BehaviorAlert(c, u , msg);
        AlopeciaScoreAlert(c, u , msg);
        dcmNotesAlert(c, u , msg);
         //Added by Kollil, Nov 2025
        //Refer to tkt # 13618
        assignmentsCreatedInPast1Day(c,u,msg);
        assignmentsReleasedInPast1Day(c,u,msg);
        assignmentsStartingNext1to14Days(c,u,msg);
        assignmentsStartedPast1to7Days(c,u,msg);

        notesEndingToday(c, u, msg, Arrays.asList("BSU Notes"), null);
        saveValues(c, toSave);

        return msg.toString();
    }

    /* Added by Kollil Nov, 2025
    Priority 4: Add links to grids 3 and 4 in daily Behavior Alerts email (do not need to display full grid in email)
                     - for grid 3 - "There are __ assignments starting in the Next 1-14 days" with a link
    Refer to tkt # 13618
    */
    private void assignmentsStartingNext1to14Days(final Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("AssignmentsStartingNext1to14Days");

        TableSelector ts = new TableSelector(ti, null, null);
        long total = ts.getRowCount();

        if (total > 0)
        {
            msg.append("<b>Assignments starting in the next 1-14 days:</b><p>");
            msg.append( total + " entries found. ");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "AssignmentsStartingNext1to14Days", null)  + "'>Click here to view them</a>\n");
            msg.append("<hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: No assignments starting in the next 1-14 days!</b><br><hr>\n");
        }
    }

    /* Added by Kollil Nov, 2025
        Priority 4: Add links to grids 3 and 4 in daily Behavior Alerts email (do not need to display full grid in email)
                     - for grid 4 - "There were __ assignments started in the past 1-7 days" with a link
    Refer to tkt # 13618
    */
    private void assignmentsStartedPast1to7Days(final Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("AssignmentsStartedPast1to7Days");

        TableSelector ts = new TableSelector(ti, null, null);
        long total = ts.getRowCount();

        if (total > 0)
        {
            msg.append("<b>Assignments started in the past 1-7 days:</b><p>");
            msg.append( total + " entries found. ");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "AssignmentsStartedPast1to7Days", null)  + "'>Click here to view them</a>\n");
            msg.append("<hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: No assignments started in the past 1-7 days!</b><br><hr>\n");
        }
    }

    /* Added by Kollil Nov, 2025
     List of assignment records created by R&L in past 24hrs (this is the most important grid)
           a.    Replaces current grid “Assignments Modified in Past 1 Day” which captures any modifications to records in the last 24hrs
           b.    To clarify, not the same as records with the “assign date” within the past day
           c.    Include Day Leases
    Refer to tkt # 13618
    */
    private void assignmentsCreatedInPast1Day(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "study") == null) {
            msg.append("<b>Warning: The study schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }
        //assignments query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("AssignmentsCreatedInPast1Day", ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, null);
        long count = ts.getRowCount();

        //Get num of rows
        if (count > 0) {
            msg.append("<b>Assignments created in the past 24hrs:</b><p>");
            msg.append( count + " entries found. ");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "AssignmentsCreatedInPast1Day", null)  + "'>Click here to view them in a separate window</a>\n");
            msg.append("<hr>\n\n");

            //Display the daily report in the email
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("Sex"));
            columns.add(FieldKey.fromString("Room"));
            columns.add(FieldKey.fromString("Cage"));
            columns.add(FieldKey.fromString("project"));
            columns.add(FieldKey.fromString("Protocol"));
            columns.add(FieldKey.fromString("Title"));
            columns.add(FieldKey.fromString("ProjectInvestigator"));
            columns.add(FieldKey.fromString("AssignDate"));
            columns.add(FieldKey.fromString("ReleaseDate"));
            columns.add(FieldKey.fromString("ProjectedReleaseDate"));
            columns.add(FieldKey.fromString("assignmentType"));
            columns.add(FieldKey.fromString("assignCondition"));
            columns.add(FieldKey.fromString("projectedReleaseCondition"));
            columns.add(FieldKey.fromString("ConditionAtRelease"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, null);

//            msg.append("<hr><b>Assignments created in past 24hrs:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#FFD700" + '"' + "style='font-weight: bold;'>");
            msg.append("<td>Id </td><td>Sex </td><td>Room </td><td>Cage </td><td>Project </td><td>Protocol </td><td>Title </td><td>Project Investigator </td><td>Assign Date </td><td>Release Date </td><td>Projected Release Date </td><td>Assignment Type </td><td>Assign Condition </td><td>Projected Release Condition </td><td>Condition At Release </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));

                msg.append("<tr bgcolor = " + '"' + "#FFFACD" + '"' + ">");
                msg.append("<td><b> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a> </b></td>\n");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Sex")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Room")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Cage")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("project")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Protocol")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Title")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ProjectInvestigator")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("AssignDate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ReleaseDate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ProjectedReleaseDate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("assignmentType")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("assignCondition")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("projectedReleaseCondition")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ConditionAtRelease")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table><br>");
        }
        else {
            msg.append("<b>WARNING: No assignments created in past 24hrs!</b><br><hr>\n");
        }
    }

    /* Added by Kollil Nov, 2025
    Grid 2: List of records with new “Release date” added within the last 24hrs
           a. Omit Day Leases
    Refer to tkt # 13618
    */
    private void assignmentsReleasedInPast1Day(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "study") == null) {
            msg.append("<b>Warning: The study schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }

        //assignments query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("AssignmentsReleasedInPast1Day", ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, null);
        long count = ts.getRowCount();

        //Get num of rows
        if (count > 0) {
            msg.append("<b>Assignments with new \"Release date\" added in the last 24hrs:</b><p>");
            msg.append( count + " entries found. ");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "AssignmentsReleasedInPast1Day", null)  + "'>Click here to view them in a separate window</a>\n");
            msg.append("\n\n");

        //Display the daily report in the email
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("Sex"));
            columns.add(FieldKey.fromString("Room"));
            columns.add(FieldKey.fromString("Cage"));
            columns.add(FieldKey.fromString("project"));
            columns.add(FieldKey.fromString("Protocol"));
            columns.add(FieldKey.fromString("Title"));
            columns.add(FieldKey.fromString("ProjectInvestigator"));
            columns.add(FieldKey.fromString("AssignDate"));
            columns.add(FieldKey.fromString("ReleaseDate"));
            columns.add(FieldKey.fromString("ProjectedReleaseDate"));
            columns.add(FieldKey.fromString("assignmentType"));
            columns.add(FieldKey.fromString("assignCondition"));
            columns.add(FieldKey.fromString("projectedReleaseCondition"));
            columns.add(FieldKey.fromString("ConditionAtRelease"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, null);

//            msg.append("<hr><b>Assignments with new \"Release date\" added within the last 24hrs:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#FFD700" + '"' + "style='font-weight: bold;'>");
            msg.append("<td>Id </td><td>Sex </td><td>Room </td><td>Cage </td><td>Project </td><td>Protocol </td><td>Title </td><td>Project Investigator </td><td>Assign Date </td><td>Release Date </td><td>Projected Release Date </td><td>Assignment Type </td><td>Assign Condition </td><td>Projected Release Condition </td><td>Condition At Release </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));

                msg.append("<tr bgcolor = " + '"' + "#FFFACD" + '"' + ">");
                msg.append("<td><b> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a> </b></td>\n");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Sex")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Room")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Cage")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("project")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Protocol")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Title")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ProjectInvestigator")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("AssignDate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ReleaseDate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ProjectedReleaseDate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("assignmentType")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("assignCondition")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("projectedReleaseCondition")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ConditionAtRelease")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table><br>");
        }
        else {
            msg.append("<b>WARNING: No assignments released in past 24hrs!</b><br><hr>\n");
        }
    }

    /* Added by Kollil 08/22/2025
    New alert/notification for when an animal receives an alopecia score of 4 or 5, but does not have an open behavioral case for alopecia.
    Refer to tkt # 12145
    */
    private void AlopeciaScoreAlert(final Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("AlopeciaScoreMissingBehaviorCases");

        TableSelector ts = new TableSelector(ti, null, null);
        long total = ts.getRowCount();
        msg.append("<b>Animals with alopecia score of 4 or 5, but does not have an open behavioral case for alopecia:</b><p>");
        if (total > 0)
        {
            msg.append( total + " entries found. ");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "AlopeciaScoreMissingBehaviorCases", null)  + "'>Click here to view them</a>\n");
            msg.append("<hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: No animals found with alopecia score of 4 or 5, but does not have an open behavioral case for alopecia!</b><br><hr>\n");
        }
   }

    // Added by Kollil 11/04/2020
    private void NHPTraining_BehaviorAlert(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "onprc_ehr") == null) {
            msg.append("<b>Warning: The onprc_ehr schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }
        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_ehr").getTable("NHP_Training_BehaviorAlert",ContainerFilter.Type.AllFolders.create(c, u));
//        ((ContainerFilterable) ti).setContainerFilter(ContainerFilter.Type.AllFolders.create(u);
        TableSelector ts = new TableSelector(ti, null, null);

        long total = ts.getRowCount();
        msg.append("<b>NHP_Training entries where \"Training Result = In-Progress\" for over 60 days:</b><p>");
        if (total > 0)
        {
            msg.append("There are " + total + " entries found. ");
            msg.append("<a href='" + getExecuteQueryUrl(c, "onprc_ehr", "NHP_Training_BehaviorAlert", null)  + "'>Click here to view them</a>\n");
            msg.append("<hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: There are no NHP_Training entries where \"Training Result = In Progress\" for over 60 days!</b><br><hr>\n");
        }
    }

    /*
     Kollil, Created: 11/18/20, Modified: 04/07/2021
       1. New alert for DCM notes (category = notes pertaining to DAR) added the previous day.
       2. New alert for DCM notes (category = notes pertaining to DAR) removed the previous day.
       3. New alert for Flags added the previous day.
       4. New alert for Flags removed the previous day.
    */
    /**
     * Modified: 12-9-2021  R.Blasa using Lakshmi's original code
     */
    @Override
    protected void dcmNotesAlert(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("actiondate"), new Date(), CompareType.DATE_EQUAL);
        filter.addCondition(FieldKey.fromString("category"), "Notes Pertaining to DAR", CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Notes_WithLocation"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " DCM action items. </b><br>\n");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "Notes_WithLocation", null) + "&query.actiondate~dateeq="+ getDateFormat(c).format(new Date()) + "&query.category~eq=Notes Pertaining to DAR'>Click here to view them</a><br>\n\n");
            msg.append("<br><hr>");
        }
        else
        {
            msg.append("<b>WARNING: There are no DCM action items!</b><br><hr>");
        }

        //Added by Kollil on 11/04/2020
        //New alert for DCM notes (category = notes pertaining to DAR) added the previous day.

        //Get yesterday date
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -1);
        String formatted = getDateFormat(c).format(cal.getTime());

        SimpleFilter filter1 = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_EQUAL);
        filter1.addCondition(FieldKey.fromString("category"), "Notes Pertaining to DAR", CompareType.EQUAL);
        TableSelector ts1 = new TableSelector(getStudySchema(c, u).getTable("Notes_WithLocation"), filter1, null);
        long count1 = ts1.getRowCount();
        msg.append("<b>DCM Alerts:</b><br><hr>");
        if (count1 > 0) {
            msg.append("<b>" + count1 + " DCM notes entries added yesterday where \"Category = Notes pertaining to DAR\". </b><br>\n");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "Notes_WithLocation", null) + "&query.date~dateeq="+ formatted + "&query.category~eq=Notes Pertaining to DAR'>Click here to view them</a><br>\n\n");
            msg.append("<br><hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: No DCM notes added yesterday where \"Category = Notes pertaining to DAR\"!</b><br><hr>");
        }

        /*  Added by Kollil on 10/12/2023
            New alert for DCM notes (category = notes pertaining to DAR) removed the previous day.
            Refer to tkt #9977
        */
        SimpleFilter filter4 = new SimpleFilter(FieldKey.fromString("enddate"), cal.getTime(), CompareType.DATE_EQUAL);
        filter4.addCondition(FieldKey.fromString("category"), "Notes Pertaining to DAR", CompareType.EQUAL);
        TableSelector ts4 = new TableSelector(getStudySchema(c, u).getTable("Notes_WithLocation"), filter4, null);
        long count4 = ts4.getRowCount();

        if (count4 > 0) {
            msg.append("<b>" + count4 + " DCM notes entries removed yesterday where \"Category = Notes pertaining to DAR\". </b><br>\n");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "Notes_WithLocation", null) + "&query.enddate~dateeq="+ formatted + "&query.category~eq=Notes Pertaining to DAR'>Click here to view them</a><br>\n\n");
            msg.append("<br><hr>\n\n");
        }
        else {
            msg.append("<b>WARNING: No DCM notes ended yesterday where \"Category = Notes pertaining to DAR\"!</b><br><hr>");
        }

        //Added by Kollil on 11/04/2020
        //New alert for Flags added the previous day.
        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_EQUAL);
        TableSelector ts2 = new TableSelector(getStudySchema(c, u).getTable("Flags_WithLocation"), filter2, null);
        long count2 = ts2.getRowCount();
        if (count2 > 0)
        {
            msg.append("<b>There are " + count2 + " flag(s) added yesterday. </b><br>\n");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "Flags_WithLocation", null) + "&query.date~dateeq="+ formatted + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>");
        }
        else
        {
            msg.append("<b>WARNING: There are no flags added yesterday!</b><br><hr>");
        }

        //Added by Kollil on 1/04/2021
        //New alert for Flags removed the previous day.
        SimpleFilter filter3 = new SimpleFilter(FieldKey.fromString("enddate"), cal.getTime(), CompareType.DATE_EQUAL);
        TableSelector ts3 = new TableSelector(getStudySchema(c, u).getTable("Flags_WithLocation"), filter3, null);
        long count3 = ts3.getRowCount();
        if (count3 > 0) {
            msg.append("<b>" + count3 + " flag(s) removed yesterday. </b><br>\n");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "Flags_WithLocation", null) + "&query.enddate~dateeq="+ formatted + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>");
        }
        else {
            msg.append("<b>WARNING: There are no flags removed yesterday!</b><br><hr>");
        }

    }

    //    Modified: 9-7-2018  R.Blasa
    private void behaviorCaseSummary(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("mostRecentObservationsBehavior");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("isActive"), true);

        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("Id"), filter, null);
        long total = ts.getRowCount();
        msg.append("<b>Behavior Cases:</b><p>");
        msg.append("There are " + total + " active behavior cases (this does not include cases closed for review).  ");
        String url = getExecuteQueryUrl(c, "study", "mostRecentObservationsBehavior", "Open Behavior Case") + "&query.isActive~eq=true";
        msg.append("<a href='" + url + "'>Click here to view them</a>");
        msg.append("<hr>");
    }

    private void pairIdConflicts(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("pairingIdConflicts");
        TableSelector ts = new TableSelector(ti);
        long total = ts.getRowCount();
        if (total > 0)
        {
            msg.append("<b>Conflicting Pair IDs:</b><p>");
            msg.append("There are " + total + " pairing records with conflicting pairIds.  If this occurs, there is a bug in data entry which could cause unusual results when viewing the data.  If you see this, please contact the site administrator.  ");
            String url = getExecuteQueryUrl(c, "study", "pairingIdConflicts", null);
            msg.append("<a href='" + url + "'>Click here to view them</a>");
            msg.append("<hr>");
        }
    }

    private void singleHousedAnimals(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("demographicsDaysAlone");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("cagemates"), 0, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("daysAlone"), 30, CompareType.GT);

        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("Id"), filter, null);
        long total = ts.getRowCount();
        msg.append("<b>Single Housed Animals:</b><p>");
        msg.append("There are " + total + " animals that have been single housed for at least 30 days.  ");
        String url = getExecuteQueryUrl(c, "study", "demographicsDaysAlone", null, filter) + "&query.sort=-DaysAlone";
        msg.append("<a href='" + url + "'>Click here to view them</a>");
        msg.append("<hr>");
    }

    private void getFlaggedPairs(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("pairingSeparations");
        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("Id"));
        long total = ts.getRowCount();
        if (total > 0)
        {
            msg.append("<b>There are " + total + " animals with temporary separations, but there is no subsequent pairing observation to indicate a reunite, permanent separation, new pair formation, etc.  These may need attention.</b><p>");
            String url = getExecuteQueryUrl(c, "study", "pairingSeparations", null);
            msg.append("<a href='" + url + "'>Click here to view them</a>");
            msg.append("<hr>");
        }
    }

    private void changedPairs(Container c, User u, final StringBuilder msg)
    {
        Calendar date1 = Calendar.getInstance();
        date1.setTime(new Date());
        date1 = DateUtils.truncate(date1, Calendar.DATE);

        Calendar date2 = Calendar.getInstance();
        date2.setTime(new Date());
        date2 = DateUtils.truncate(date2, Calendar.DATE);
        date2.add(Calendar.DATE, -1);

        UserSchema us = getStudySchema(c, u);
        QueryDefinition qd = us.getQueryDefForTable("pairDifferences");
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);
        Map<String, Object> params = new HashMap<>();
        params.put("Date1", date1.getTime());
        params.put("Date2", date2.getTime());

        SQLFragment sql = ti.getFromSQL("t");
        QueryService.get().bindNamedParameters(sql, params);

        sql = new SQLFragment("SELECT * FROM " + sql.getSQL() + " WHERE (t.changeType IS NOT NULL AND t.changeType != 'Group Members Changed') ORDER BY ldk.naturalize(t.room1), ldk.naturalize(t.cage1)", sql.getParams());
        QueryService.get().bindNamedParameters(sql, params);
        SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
        Collection<Map<String, Object>> rows = ss.getMapCollection();

        if (!rows.isEmpty())
        {
            msg.append("<b>There are " + rows.size() + " animals with differences in pairing since the previous day.  Note, this considers full pairs vs. non-full pairs only (ie. grooming contact is treated as non-paired).  It considers housing at midnight of the days in question.</b>  ");
            String url = getExecuteQueryUrl(c, "study", "pairDifferences", null) + "&query.changeType~isnonblank&query.changeType~neq=Group Members Changed&query.param.Date1=" + getDateFormat(c).format(date1.getTime()) + "&query.param.Date2=" + getDateFormat(c).format(date2.getTime());

            msg.append("<a href='" + url + "'>Click here to view them</a><p>");

            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'><td>Id</td><td>Animals In Cage</td><td>Current Room</td><td>Current Cage</td><td>Change Type</td><td>Previous Room</td><td>Previous Cage</td><td>Pair Observations Entered On Date</td></tr>");

            for (Map<String, Object> row : rows)
            {
                String animalUrl = getParticipantURL(c, (String)row.get("Id"));
                msg.append("<tr><td><a href='" + animalUrl + "'>" + row.get("Id") + "</a></td><td>" + (row.get("animalsInCage1") == null ? "" : row.get("animalsInCage1")) + "</td><td>" + row.get("room1") + "</td><td>" + (row.get("cage1") == null ? "" : row.get("cage1")) + "</td><td>" + row.get("changeType") + "</td><td>" + (row.get("room2") == null ? "" : row.get("room2")) + "</td><td>" + (row.get("cage2") == null ? "" : row.get("cage2")) + "</td><td>" + row.get("pairObservations") + "</td></tr>");
            }

            msg.append("</table>");
        }
        else
        {
            msg.append("<b>No pairs changed yesterday</b>");
        }

        msg.append("<hr>");
    }

    private void colonyHousingSummary(final Container c, User u, final StringBuilder msg, Map<String, String> saved, Map<String, String> toSave)
    {
        final String colonyHousingSummary = "colonyHousingSummary";
        final JSONObject oldValueMap = saved.containsKey(colonyHousingSummary) ? new JSONObject(saved.get(colonyHousingSummary)) : new JSONObject();
        final JSONObject newValueMap = new JSONObject();
        Date lastRunDate = saved.containsKey(lastSave) ? new Date(Long.parseLong(saved.get(lastSave))) : null;

        TableInfo ti = getStudySchema(c, u).getTable("housingPairingSummary");
        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("category", "totalAnimals"), null, new Sort("category"));
        msg.append("<b>Housing summary:</b><p>");
        msg.append("<table border=1 style='border-collapse: collapse;'>");
        msg.append("<tr style='font-weight: bold;'><td>Category</td><td># Animals</td><td>Previous Value " + (lastRunDate == null ? "" : "(" + getDateFormat(c).format(lastRunDate) + ")") + "</td></tr>");
        final String urlBase = getExecuteQueryUrl(c, "study", "demographics", "By Location");

        ts.forEach(rs -> {
            String category = rs.getString("category");
            msg.append("<tr><td>").append(category).append("</td><td><a href='").append(urlBase).append("&query.Id/numPaired/category~eq=").append(category).append("'>").append(rs.getInt("totalAnimals")).append("</a></td><td>");
            if (oldValueMap.has(category))
            {
                msg.append(oldValueMap.get(category));
            }
            msg.append("</td></tr>");

            newValueMap.put(category, rs.getInt("totalAnimals"));
        });

        msg.append("</table>");
        msg.append("<hr>");

        toSave.put(colonyHousingSummary, newValueMap.toString());
    }
}
