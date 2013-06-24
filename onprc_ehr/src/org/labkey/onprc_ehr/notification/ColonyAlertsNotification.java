/*
 * Copyright (c) 2012-2013 LabKey Corporation
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

import org.labkey.api.action.NullSafeBindException;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.RuntimeSQLException;
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
import org.labkey.api.query.QuerySettings;
import org.labkey.api.query.QueryView;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.ResultSetUtil;
import org.springframework.beans.MutablePropertyValues;
import org.springframework.validation.BindException;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * User: bbimber
 * Date: 7/14/12
 * Time: 3:16 PM
 */
public class ColonyAlertsNotification extends AbstractEHRNotification
{
    public String getName()
    {
        return "Colony Alerts";
    }

    public String getEmailSubject()
    {
        return "Daily Colony Alerts: " + AbstractEHRNotification._dateTimeFormat.format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 6 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 6AM";
    }

    public String getDescription()
    {
        return "The report is designed to identify potential problems with the colony, primarily related to weights, housing and assignments.";
    }

    public String getMessage(final Container c, User u)
    {
        final StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();
        msg.append("This email contains a series of automatic alerts about the colony.  It was run on: " + AbstractEHRNotification._dateFormat.format(now) + " at " + AbstractEHRNotification._timeFormat.format(now) + ".<p>");

        //housing
        //livingAnimalsWithoutWeight(c, u, msg);
        cagesWithoutDimensions(c, u, msg);
        cageReview(c, u, msg, true);
        roomsWithoutInfo(c, u, msg);
        multipleHousingRecords(c, u, msg);
        deadAnimalsWithActiveHousing(c, u, msg);
        livingAnimalsWithoutHousing(c, u, msg);
        housedInUnavailableCages(c, u, msg);
        roomsReportingNegativeCagesAvailable(c, u, msg);
        nonContiguousHousing(c, u, msg);
        roomsWithMixedViralStatus(c, u, msg);
        infantsNotWithMother(c, u, msg);

        //assignments
        doAssignmentChecks(c, u, msg);
        getU42Assignments(c, u, msg);

        //clinical
        deadAnimalsWithActiveCases(c, u, msg);
        deadAnimalsWithActiveDiet(c, u, msg);
        activeTreatmentsForDeadAnimals(c, u, msg);
        activeProblemsForDeadAnimals(c, u, msg);

        //blood draws
        bloodDrawsOnDeadAnimals(c, u, msg);
        bloodDrawsOverLimit(c, u, msg);
        findNonApprovedDraws(c, u, msg);

        //misc
        demographicsWithoutGender(c, u, msg);
        birthRecordsWithoutDemographics(c, u, msg);
        deathRecordsWithoutDemographics(c, u, msg);
        animalGroupsAcrossRooms(c, u, msg);
        duplicateGroupMembership(c, u, msg);
        duplicateFlags(c, u, msg);
        suspiciousMedications(c, u, msg);

        return msg.toString();
    }

    protected void doAssignmentChecks(final Container c, User u, final StringBuilder msg)
    {
        deadAnimalsWithActiveAssignments(c, u, msg);
        deadAnimalsWithActiveFlags(c, u, msg);
        deadAnimalsWithActiveNotes(c, u, msg);
        deadAnimalsWithActiveGroups(c, u, msg);
        assignmentsWithoutValidProtocol(c, u, msg);
        duplicateAssignments(c, u, msg);
        activeAssignmentsForDeadAnimals(c, u, msg);
        protocolsNearingLimit(c, u, msg);
        assignmentsProjectedToday(c, u, msg);
        assignmentsProjectedTomorrow(c, u, msg);
        protocolsWithAnimalsExpiringSoon(c, u, msg);
    }

    /**
     * Finds all occupied cages without dimensions, or cages lacking row/col classification
     */
    protected void cagesWithoutDimensions(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("missingCages"));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following cages have animals, but do not have known dimensions:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString("room") + "/" + rs.getString("cage") + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "missingCages", null) + "'>Click here to view the problem cages</a></p>\n");
            msg.append("<hr>\n");
        }

        TableSelector ts2 = new TableSelector(getEHRLookupsSchema(c, u).getTable("cagesMissingColumn"));
        if (ts2.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following cages do have have their row/column specified:</b><br>\n");
            ts2.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString("cage") + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "cagesMissingColumn", null) + "'>Click here to view the problem cages</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * Finds all rooms reporting a negative number for available cages
     */
    protected void roomsReportingNegativeCagesAvailable(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("CagesEmpty"), 0, CompareType.LT);
        TableSelector ts = new TableSelector(getEHRLookupsSchema(c, u).getTable("roomUtilization"), filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following rooms report a negative number for available cages.  This probably means there is a problem in the cage divider configuration, or an animal is listed as being housed in the higher-numbered cage of a joined pair:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString("room") + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr_lookups", "roomUtilization", null) + "&query.CagesEmpty~lt=0'>Click here to view the problem rooms</a></p>\n");
            msg.append("<hr>\n");
        }

    }


    protected void eventsInLast5Days(Container c, User u, StringBuilder msg)
    {
        msg.append("<b>Colony events in the past 5 days:</b><p>");
        birthsInLast5Days(c, u, msg);
        msg.append("<br><br>\n");
        deathsInLast5Days(c, u, msg);
        msg.append("<hr>\n");
    }

    /**
     * Finds all rooms with animals of mixed viral status
     */
    protected void roomsWithMixedViralStatus(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("distinctStatuses"), 1 , CompareType.GT);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("housingMixedViralStatus"), filter, new Sort("room"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: The following " + count + " rooms have animals with mixed viral statuses:</b><p></p>\n");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "housingMixedViralStatus", null) + "&query.distinctStatuses~gt=1'>Click here to view this list</a><p></p>\n");

            msg.append("<table border=1 style='border-collapse: collapse;'>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>()
            {
                public void exec(ResultSet rs) throws SQLException
                {
                    String status = rs.getString("viralStatuses");
                    if (status != null)
                    {
                        status = status.replaceAll("\\)\n", ")<br>");
                        status = status.replaceAll("\n", " / ");
                    }

                    String room = rs.getString("room");
                    String url = getExecuteQueryUrl(c, "study", "demographics", "By Location") + "&query.Id/curLocation/room~eq=" + room;
                    msg.append("<tr><td style='vertical-align:top;'><a href='" + url + "'>" + room + ":</a></td><td><a href='" + url + "'>" + status + "</a></td></tr>\n");
                }
            });
            msg.append("</table>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * Finds all occupied rooms without a record in ehr_lookups.rooms
     */
    protected void roomsWithoutInfo(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("missingRooms"));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following rooms have animals, but do not have a record in the rooms table:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString("room") + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "missingRooms", null) + "'>Click here to view the problem rooms</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    protected void livingAnimalsWithoutWeight(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/MostRecentWeight/MostRecentWeightDate"), null, CompareType.ISBLANK);
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());

        TableInfo ti = getStudySchema(c, u).getTable("Demographics");
        List<FieldKey> colKeys = new ArrayList<>();
        colKeys.add(FieldKey.fromString(getStudy(c).getSubjectColumnName()));
        colKeys.add(FieldKey.fromString("Id/age/AgeFriendly"));
        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, sort);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following animals do not have a weight:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    Results results = new ResultsImpl(rs, columns);
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()));
                    String age = results.getString(FieldKey.fromString("Id/age/AgeFriendly"));
                    if (age != null)
                        msg.append(" (Age: " + age + ")");

                    msg.append("<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", null) + "&query.calculated_status~eq=Alive&query.Id/MostRecentWeight/MostRecentWeightDate~isblank'>Click here to view these animals</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    protected void multipleHousingRecords(final Container c, User u, final StringBuilder msg)
    {
        //then we find all living animals with multiple active housing records:
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("housingProblems"), null, sort);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals with multiple active housing records:</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "housingProblems", null) + "'>Click here to view these animals</a></p>\n");
        }
    }

    protected void deadAnimalsWithActiveHousing(final Container c, User u, final StringBuilder msg)
    {
        //we find open housing records where the animal is not alive
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Housing"), filter, sort);
        long count = ts.getRowCount();
        if (count > 0)
        {
	        msg.append("<b>WARNING: There are " + count + " active housing records where the animal is not alive:</b><br>\n");

            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Housing", null) + "&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void livingAnimalsWithoutHousing(final Container c, User u, final StringBuilder msg)
    {
        //we find living animals without an active housing record
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/curLocation/room/room"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), filter, sort);
        long count = ts.getRowCount();
        if (count > 0)
        {
	        msg.append("<b>WARNING: There are " + count + " living animals without an active housing record:</b><br>\n");

            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", null) + "&query.Id/curLocation/room/room~isblank&query.Id/Dataset/Demographics/calculated_status~eq=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * find all living animals without active assignments
     */
    protected void animalsLackingAssignments(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/activeAssignments/numActiveAssignments"), 0, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/Demographics/calculated_status"), "Alive", CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), Collections.singleton("Id"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " living animals without any active assignments:</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", null) + "&query.Id/activeAssignments/numActiveAssignments~eq=0&query.Id/Demographics/calculated_status~eq=Alive'>Click here to view them</a><br>\n\n");
        }
    }

    protected void deadAnimalsWithActiveAssignments(final Container c, User u, final StringBuilder msg)
    {
        //then we find all records with problems in the calculated_status field
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active assignments for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Assignment", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveCases(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Cases"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active cases for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Cases", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * find any active assignment where the project lacks a valid protocol
     */
    protected void assignmentsWithoutValidProtocol(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("project/protocol"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active assignments to a project without a valid protocol.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Assignment", null) + "&query.isActive~eq=true&query.project/protocol~isblank'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void duplicateAssignments(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("duplicateAssignments"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals double assigned to the same project.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "duplicateAssignments", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * find records created within the past 7 days, which have a date more than 7 days before then
     */
    protected void recordsEnteredMoreThan7DaysAfter(final Container c, User u, final StringBuilder msg)
    {
        int offset = 7;



    }


    /**
     * find the total finalized records with future dates
     */
    protected void finalizedRecordsWithFutureDates(final Container c, User u, final StringBuilder msg)
    {
        String datasets = "Treatment Orders;Assignment";
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("qcstate/PublicData"), true);
        Date date = new Date();
        filter.addCondition(FieldKey.fromString("date"), date, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("dataset/label"), datasets, CompareType.NOT_IN);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("StudyData"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " finalized records with future dates.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "StudyData", null) + "&query.date~dategt=" + AbstractEHRNotification._dateFormat.format(date) + "&query.qcstate/PublicData~eq=true&query.dataset/label~notin=" + datasets + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * deaths in the last 5 days
     */
    protected void deathsInLast5Days(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -5);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Deaths"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("Deaths since " + AbstractEHRNotification._dateFormat.format(cal.getTime()) + ":<br><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Deaths", null) + "&query.date~dategte=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view them</a><p>\n");
        }
    }

    /**
     * births in the last 5 days
     */
    protected void birthsInLast5Days(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -5);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Birth"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("Births since " + AbstractEHRNotification._dateFormat.format(cal.getTime()) + ":<br><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Birth", null) + "&query.date~dategte=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view them</a><p>\n");
        }
    }

    protected void assignmentsProjectedTomorrow(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, 1);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("projectedRelease"), cal.getTime(), CompareType.DATE_EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>ALERT: There are " + count + " assignments with a projected release date for tomorrow.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Assignment", null) + "&query.projectedRelease~dateeq=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find assignments with projected releases today
     */
    protected void assignmentsProjectedToday(final Container c, User u, final StringBuilder msg)
    {
        Date date = new Date();
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("projectedRelease"), date, CompareType.DATE_EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>ALERT: There are " + count + " assignments with a projected release date for today that have not already been ended.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Assignment", null) + "&query.projectedRelease~dateeq=" + AbstractEHRNotification._dateFormat.format(date) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * protocols with active animals that expire in next 30 days
     */
    protected void protocolsWithAnimalsExpiringSoon(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysUntilRenewal"), 30, CompareType.LTE);
        filter.addCondition(FieldKey.fromString("activeAnimals/totalActiveAnimals"), 0, CompareType.GT);

        TableInfo ti = getEHRSchema(c, u).getTable("protocol");

        List<FieldKey> colKeys = new ArrayList<>();
        colKeys.add(FieldKey.fromString("displayName"));
        colKeys.add(FieldKey.fromString("daysUntilrenewal"));
        colKeys.add(FieldKey.fromString("activeAnimals/totalActiveAnimals"));
        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>ALERT: There are " + count + " protocols with active assignments set to expire within the next 30 days.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "protocol", null) + "&query.daysUntilRenewal~lte=30&query.activeAnimals/totalActiveAnimals~gt=0'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find death records without a corresponding demographics record
     */
    protected void deathRecordsWithoutDemographics(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/Id"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("notAtCenter"), true, CompareType.NEQ_OR_NULL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Deaths"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " death records without a corresponding demographics record.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Deaths", null) + "&query.Id/Dataset/Demographics/Id~isblank&query.notAtCenter~neqornull=true'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find birth records without a corresponding demographics record
     */
    protected void birthRecordsWithoutDemographics(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/Id"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Birth"), Collections.singleton(getStudy(c).getSubjectColumnName()), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " birth records without a corresponding demographics record.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Birth", null) + "&query.Id/Dataset/Demographics/Id~isblank'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find protocols expiring soon.  this is based on protocols having a 3-year window
     */
    protected void protocolsExpiringSoon(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysUntilRenewal"), 14, CompareType.DATE_LTE);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("protocol"), Collections.singleton("protocol"), filter, new Sort("displayName"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " protocols that will expire within the next 14 days.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "protocol", null) + "&query.daysUntilRenewal~lte=14'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find protocols nearing the animal limit, based on number and percent
     */
    protected void protocolsNearingLimit(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("TotalRemaining"), 5, CompareType.LT);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("protocolTotalAnimalsBySpecies"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " protocols with fewer than 5 remaining animals.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "protocolTotalAnimalsBySpecies", null) + "&query.TotalRemaining~lt=5'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }

        filter = new SimpleFilter(FieldKey.fromString("PercentUsed"), 95, CompareType.GTE);
        ts = new TableSelector(getEHRSchema(c, u).getTable("protocolTotalAnimalsBySpecies"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count2 = ts.getRowCount();
        if (count2 > 0)
        {
            msg.append("<b>WARNING: There are " + count2 + " protocols with fewer than 5% of their animals remaining.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "protocolTotalAnimalsBySpecies", null) + "&query.PercentUsed~gte=95'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find all animals that died in the past 90 days where there isnt a weight within 7 days of death:
     */
    protected void deathWeightCheck(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -90);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("death"), cal.getTime(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("validateFinalWeights"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        Long total = ts.getRowCount();

        if (total > 0)
        {
            msg.append("<b>WARNING: There are " + total + " animals that are dead, but do not have a weight within the previous 7 days:</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "validateFinalWeights", null) + "&query.death~dategte=-90d'>Click here to view them</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * we find demographics records in the past 90 days missing a gender
     */
    protected void demographicsWithoutGender(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("death"), "-90d", CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("gender"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following demographics records were entered in the last 90 days, but are missing a gender:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>()
            {
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()));
                    if (rs.getDate("birth") == null)
                        msg.append(" (" + AbstractEHRNotification._dateFormat.format(rs.getDate("birth")) + ")");

                    msg.append("<br>\n");
                }
            });
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", null) + "&query.gender~isblank=&query.created~dategte=-90d'>Click here to view these animals</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * we find birth records in the past 90 days missing a gender
     */
    protected void birthWithoutGender(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), "-90d", CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("gender"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Birth"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following birth records were entered in the last 90 days, but are missing a gender:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + " (" + AbstractEHRNotification._dateFormat.format(rs.getDate("date"))+ ")" + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Birth", null) + "&query.gender~isblank=&query.date~dategte=-90d'>Click here to view these animals</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * we find non-continguous housing records
     */
    protected void nonContiguousHousing(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.YEAR, -1);

        //TODO: discuss w/ Josh
        UserSchema us = getStudySchema(c, u);
        QueryDefinition qd = us.getQueryDefForTable("HousingCheck");
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);
        SQLFragment sql = ti.getFromSQL("t");
        sql = new SQLFragment("SELECT * FROM " + sql.getSQL(), cal.getTime(), cal.getTime(), cal.getTime());
        SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
        long total = ss.getRowCount();

        if (total > 0)
        {
            msg.append("<b>WARNING: There are " + total + " housing records since " + AbstractEHRNotification._dateFormat.format(cal.getTime()) + " that do not have a contiguous previous or next record.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "HousingCheck", null) + "&query.param.MINDATE=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find open assignments where the animal is not alive
     */
    protected void activeAssignmentsForDeadAnimals(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active assignments for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Assignment", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find open ended problems where the animal is not alive
     */
    protected void activeProblemsForDeadAnimals(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Problem List"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " unresolved problems for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Problem List", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find open ended treatments where the animal is not alive
     */
    protected void activeTreatmentsForDeadAnimals(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Treatment Orders"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active treatments for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Treatment Orders", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * then we find all animals with cage size problems
     * @param msg
     */
    protected void cageReview(final Container c, User u, final StringBuilder msg, boolean notifyOnNone)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("cageStatus"), "ERROR", CompareType.STARTS_WITH);
        TableSelector ts = new TableSelector(getEHRLookupsSchema(c, u).getTable("cageReview"), filter, null);
        Map<String, Object>[] rows = ts.getMapArray();

        if (rows.length > 0)
        {
            msg.append("<b>WARNING: The following cages are too small for the animals currently in them:</b><br>");
            for (Map<String, Object> row : rows)
            {
                String room = (String)row.get("room");
                String cage = (String)row.get("cage");
                String status = (String)row.get("cageStatus");

                if (room != null)
                    msg.append("Room: ").append(room);

                if (cage != null)
                    msg.append(" ").append(cage);

                if (status != null)
                    msg.append(": ").append(status);

                msg.append("<br>");
            }

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr_lookups", "cageReview", "Problem Cages") + "'>Click here to view these cages</a></p>\n");
            msg.append("<hr>\n");
        }
        else if (notifyOnNone)
        {
            msg.append("<b>Cage Size Review:</b><br><br>All cages are within size limits<br><hr>");
        }

//        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("sqftPct"), 97.0, CompareType.GTE);
//        TableSelector ts2 = new TableSelector(getEHRLookupsSchema(c, u).getTable("cageReview"), filter2, null);
//        Map<String, Object>[] warningRows = ts2.getMapArray();
//        DecimalFormat format = new DecimalFormat("0.#");
//
//        if (warningRows.length > 0)
//        {
//            msg.append("<b>WARNING: The following cages are approaching the size limit for the animals currently in them:</b><br>");
//
//            msg.append("<table border=1><tr><td>Room</td><td>Cage</td><td># Animals</td><td>Total Weight (kg)</td><td>Required Sq. Ft.</td><td>Available Sq. Ft.</td><td>% Used</td><td>Height Required</td><td>Height Available</td></tr>");
//            for (Map<String, Object> row : warningRows)
//            {
//                msg.append("<tr>");
//                msg.append("<td>" + ((String)row.get("room")) + "</td>");
//                msg.append("<td>" + ((String)row.get("cage")) + "</td>");
//
//                msg.append("<td>" + ((Integer)row.get("totalAnimals")) + "</td>");
//                msg.append("<td>" + DecimalFormat.getNumberInstance().format((Double) row.get("totalWeight")) + "</td>");
//
//                msg.append("<td>" + DecimalFormat.getNumberInstance().format((Double) row.get("requiredSqFt")) + "</td>");
//                msg.append("<td>" + ((Double)row.get("totalCageSqFt")) + "</td>");
//                msg.append("<td>" + DecimalFormat.getNumberInstance().format((Double) row.get("sqftPct")) + "</td>");
//
//                msg.append("<td>" + DecimalFormat.getNumberInstance().format((Double) row.get("requiredHeight")) + "</td>");
//                msg.append("<td>").append(row.get("minCageHeight") == null ? "" : ((Double)row.get("minCageHeight"))).append("</td>");
//
//                msg.append("</tr>");
//            }
//            msg.append("</table>");
//
//            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr_lookups", "cageReview", null) + "&query.sqftPct~gte=98.0'>Click here to view all problems and warnings</a></p>\n");
//            msg.append("<hr>\n");
//        }
    }

    protected void housedInUnavailableCages(final Container c, User u, final StringBuilder msg)
    {
        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        TableInfo ti = us.getTable("housedInUnavailableCages");
        TableSelector ts = new TableSelector(ti);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals housed in cages that should not be available, based on the cage/divider configuration.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "housedInUnavailableCages", null) + "'>Click here to view them</a><br>\n\n");

            final Map<String, String> locations = new TreeMap<>();
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    locations.put(object.getString("room"), object.getString("room") + " / " + object.getString("cage"));
                }
            });

            msg.append("<br>");
            for (String room : locations.keySet())
            {
                String url = AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath() + "/cageDetails.view?room=" + room;
                msg.append("<a href='" + url + "'>" + locations.get(room) + "</a><br>");
            }

            msg.append("<br><hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveDiet(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Diet"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active diets for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Diet", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveFlags(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Flags"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active flags for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Flags", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveNotes(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Notes"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active notes for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Notes", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveGroups(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("animal_group_members"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals assigned to groups, where the animal is currently at the housed center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "animal_group_members", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void transfersYesterday(final Container c, User u, final StringBuilder msg)
    {
        msg.append("<b>Transfers yesterday:</b><br><br>");

        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -1);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_EQUAL);
        Sort sort = new Sort("room");
        sort.appendSortColumn(FieldKey.fromString("cage"), Sort.SortDirection.ASC, false);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Housing"), PageFlowUtil.set("Id", "room", "cage"), filter, sort);
        Map<String, Object>[] rows = ts.getMapArray();
        if (rows.length > 0)
        {
            final Map<String, Integer> roomMap = new TreeMap<>();
            for (Map<String, Object> row : rows)
            {
                String room = (String)row.get("room");
                Integer count = roomMap.get(room);
                if (count == null)
                    count = 0;

                count++;

                roomMap.put(room, count);
            }

            String formatted = _dateFormat.format(cal.getTime());
            msg.append("The following transfers took place on " + formatted + ".  <a href='" + (getExecuteQueryUrl(c, "study", "Housing", null) + "&query.date~dateeq=" + formatted) + "'>click here to view them</a><br>");
            msg.append("<table border=1 style='border-collapse: collapse;'><tr><td>Room</td><td>Total</td></tr>");
            for (String room : roomMap.keySet())
            {
                msg.append("<tr><td>").append(room).append("</td><td>").append("<a href='" + (getExecuteQueryUrl(c, "study", "Housing", null) + "&query.date~dateeq=-1d&query.room~eq=" + room) + "'>" + roomMap.get(room) + "</a>").append("</td></tr>");
            }
            msg.append("</table><br>");
        }
        else
        {
            msg.append("No transfers took place yesterday");
        }
        msg.append("<hr>\n\n");
    }

    /**
     * we find any blood draws over the allowable limit
     */
    protected void bloodDrawsOverLimit(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -3);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Request: Denied", CompareType.NEQ);

        filter.addCondition(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("BloodRemaining/availableBlood"), 0, CompareType.LT);

        TableInfo ti = getStudySchema(c, u).getTable("Blood Draws");
        Set<FieldKey> colKeys = new HashSet<>();
        colKeys.add(FieldKey.fromString("BloodRemaining/availableBlood"));
        colKeys.add(FieldKey.fromString("date"));
        colKeys.add(FieldKey.fromString("Id"));
        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " blood draws within the past 3 days exceeding the allowable volume. Click the IDs below to see more information:</b><br><br>");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>()
            {
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, columns);

                    StringBuilder text = new StringBuilder();
                    text.append(rs.getString(getStudy(c).getSubjectColumnName()));
                    Double amount = -1.0 * rs.getDouble(FieldKey.fromString("BloodRemaining/availableBlood"));
                    text.append(": ").append(DecimalFormat.getNumberInstance().format(amount)).append(" mL overdrawn on ").append(_dateFormat.format(rs.getDate(FieldKey.fromString("date"))));

                    //String url = getParticipantURL(c, rs.getString(getStudy(c).getSubjectColumnName()));
                    String url = getExecuteQueryUrl(c, "study", "Blood Draws", "With Blood Volume") + "&query.Id~eq=" + rs.getString(getStudy(c).getSubjectColumnName());
                    msg.append("<a href='" + url + "'>" + text.toString() + "</a><br>\n");
                }
            });

            msg.append("<hr>\n");
        }
    }

    /**
     * we find any blood draws where the animal is not assigned to that project
     */
    protected void bloodDrawsNotAssignedToProject(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Request: Denied", CompareType.NEQ);
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("projectStatus"), null, CompareType.NONBLANK);

        MutablePropertyValues mpv = new MutablePropertyValues();
        mpv.addPropertyValue("schemaName", "study");
        mpv.addPropertyValue("query.queryName", "BloodSchedule");

        BindException errors = new NullSafeBindException(new Object(), "command");
        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        QuerySettings qs = us.getSettings(mpv, "query");
        qs.setBaseFilter(filter);
        QueryView view = new QueryView(us, qs, errors);
        Results rs = null;
        try
        {
            rs = view.getResults();
            int total = 0;
            //calculate row count
            while (rs.next())
            {
                total++;
            }

            if (total > 0)
            {

                msg.append("<b>WARNING: There are " + total + " blood draws scheduled today or in the future where the animal is not assigned to the project.</b><br>");

                do
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
                while (rs.next());

                msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "BloodSchedule", null) + "&query.projectStatus~isnonblank&query.Id/DataSet/Demographics/calculated_status~eq=Alive&query.date~dategte=" + AbstractEHRNotification._dateFormat.format(new Date()) + "'>Click here to view them</a><br>\n");
                msg.append("<hr>\n");
            }
            else
            {
                msg.append("All blood draws today and in the future have a valid project for the animal.<br>");
                msg.append("<hr>\n");
            }
        }
        catch (SQLException e)
        {
            throw new RuntimeSQLException(e);
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            ResultSetUtil.close(rs);
        }
    }

    /**
     * find any blood draws not yet approved
     */
    protected void findNonApprovedDraws(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Request: Pending");
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Blood Draws"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " blood draws requested that have not been approved or denied yet.</b><br>");
            msg.append("<p><a href='" + AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath() + "/dataEntry.view#topTab:Requests&activeReport:BloodDrawRequests'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * we find any blood draws not yet assigned to either SPI or animal care
     */
    protected void drawsNotAssigned(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Request: Denied", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("billedby"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Blood Draws"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " blood draws requested that have not been assigned to SPI or Animal Care.</b><br>");
            msg.append("<p><a href='" + AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath() + "/dataEntry.view#topTab:Requests&activeReport:BloodDrawRequests'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
        else {
            msg.append("All requested blood draws have been assigned to a group to perform them.<br>");
            msg.append("<hr>\n");
        }
    }

//    /**
//     * NOTE: requests are auto-generated, so this is not necessary
//     * we find any current blood draws with clinpath, but lacking a request
//     */
//    protected void drawsWithServicesAndNoRequest(final StringBuilder msg)
//    {
//        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("path_lsid"), null, CompareType.ISBLANK);
//        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_EQUAL);
//        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("ValidateBloodDrawClinpath"), filter, null);
//        if (ts.getRowCount() > 0)
//        {
//            msg.append("<b>WARNING: There are " + ts.getRowCount() + " blood draws scheduled today that request clinpath services, but lack a corresponding clinpath request.</b><br>");
//            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "ValidateBloodDrawClinpath", "Lacking Clinpath Request") + "&query.date~dateeq=" + _dateFormat.format(new Date()) + "'>Click here to view them</a><br>\n");
//            msg.append("<hr>\n");
//        }
//    }

    /*
     * we find any incomplete blood draws scheduled today, by area
     */
    protected void incompleteDraws(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Request: Denied", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_EQUAL);
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Completed", CompareType.NEQ_OR_NULL);

        MutablePropertyValues mpv = new MutablePropertyValues();
        mpv.addPropertyValue("schemaName", "study");
        mpv.addPropertyValue("query.queryName", "BloodSchedule");
        mpv.addPropertyValue("query.columns", "drawStatus,daterequested,project,date,project/protocol,taskid,projectStatus,tube_vol,tube_type,billedby,billedby/title,num_tubes,Id/curLocation/area,Id/curLocation/room,Id/curLocation/cage,additionalServices,remark,Id,quantity,qcstate,qcstate/Label,requestid");

        BindException errors = new NullSafeBindException(new Object(), "command");
        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        QuerySettings qs = us.getSettings(mpv, "query");
        qs.setBaseFilter(filter);
        QueryView view = new QueryView(us, qs, errors);
        Results rs = null;
        try
        {
            rs = view.getResults();
            if (!rs.next())
            {
                msg.append("There are no blood draws scheduled for " + AbstractEHRNotification._dateFormat.format(new Date()) + ".\n");
            }
            else
            {
                Integer complete = 0;
                Integer incomplete = 0;

                Map<String, Map<String, Map<String, Object>>> summary = new HashMap<>();

                do
                {
                    if(rs.getString(FieldKey.fromString("qcstate/Label")) != null && rs.getString(FieldKey.fromString("qcstate/Label")).equals("Completed")){
                        complete++;
                    }
                    else
                    {
                        String area = rs.getString(FieldKey.fromParts("Id/curLocation/area"));
                        String room = rs.getString(FieldKey.fromParts("Id/curLocation/room"));

                        Map<String, Map<String, Object>> areaNode = summary.get(area);
                        if (areaNode == null)
                            areaNode = new HashMap<>();

                        Map<String, Object> roomNode = areaNode.get(room);
                        if (roomNode == null)
                        {
                            roomNode = new HashMap<>();
                            roomNode.put("complete", 0);
                            roomNode.put("incomplete", 0);
                            roomNode.put("cagesHtml", new StringBuilder());
                        }

                        roomNode.put("incomplete", ((Integer)roomNode.get("incomplete") + 1));

                        StringBuilder b = (StringBuilder)roomNode.get("cagesHtml");
                        b.append("<tr><td>" + AbstractEHRNotification._dateTimeFormat.format(rs.getDate("daterequested")) + "</td><td>" +  rs.getString("Id") + "</td><td>" + (rs.getString("tube_vol")==null ? "" : rs.getString("tube_vol") + " mL") + "</td><td>" + (rs.getString("tube_type")==null ? "" : rs.getString("tube_type")) + "</td><td>" + (rs.getString("num_tubes")==null ? "" : rs.getString("num_tubes")) + "</td><td>" + (rs.getString("quantity")==null ? "" : rs.getString("quantity") + " mL") + "</td><td>" + (rs.getString("additionalServices")==null ? "" : rs.getString("additionalServices")) + "</td><td>" + (rs.getString(FieldKey.fromString("billedby/title"))==null ? "" : rs.getString(FieldKey.fromString("billedby/title"))) + "</td></tr>\n");

                        areaNode.put(room, roomNode);
                        summary.put(area, areaNode);
                    }
                }
                while (rs.next());

                String url = "<a href='" + getExecuteQueryUrl(c, "study", "BloodSchedule", null) + "&query.date~dateeq=$datestr&query.Id/DataSet/Demographics/calculated_status~eq=Alive'>Click here to view them</a></p>\n";
                msg.append("There are " + (incomplete + complete) + " scheduled blood draws for $datestr.  " + complete + " have been completed.  " + url + "<p>\n");

                if(incomplete == 0)
                {
                    msg.append("All scheduled blood draws have been marked complete as of $datetimestr.<p>\n");
                }
                else
                {
                    msg.append("The following blood draws have not been marked complete as of $datetimestr:<p>\n");

                    for (String area : summary.keySet())
                    {
                        msg.append("<b>" + area + ":</b><br>\n");
                        Map<String, Map<String, Object>> areaNode = summary.get(area);

                        for (String room: areaNode.keySet())
                        {
                            Map<String, Object> roomNode = areaNode.get(room);
                            msg.append(room + ": " + (Integer)roomNode.get("incomplete") + "<br>\n");
                            msg.append("<table border=1 style='border-collapse: collapse;'><tr><td>Time Requested</td><td>Id</td><td>Tube Vol</td><td>Tube Type</td><td># Tubes</td><td>Total Quantity</td><td>Additional Services</td><td>Assigned To</td></tr>\n");
                            msg.append((StringBuilder)roomNode.get("cageHtml"));
                            msg.append("</table><p>\n");
                        }

                        msg.append("<p>\n");
                    }
                }
            }
            msg.append("<hr>\n");
        }
        catch (SQLException e)
        {
            throw new RuntimeSQLException(e);
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            ResultSetUtil.close(rs);
        }
    }

    /**
     * we find any current or future blood draws where the animal is not alive
     */
    protected void bloodDrawsOnDeadAnimals(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Request: Denied", CompareType.NEQ);
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Blood Draws"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " current or scheduled blood draws for animals not currently at the center.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Blood Draws", null) + "&query.date~dategte=$datestr&query.Id/DataSet/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * Displays any animal groups with members in multiple rooms, excluding the hospital
     */
    protected void animalGroupsAcrossRooms(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("totalRooms"), 1, CompareType.GT);

        TableInfo ti = getStudySchema(c, u).getTable("animalGroupLocationSummary");
        List<FieldKey> colKeys = new ArrayList<>();
        colKeys.add(FieldKey.fromString("groupId"));
        colKeys.add(FieldKey.fromString("groupId/name"));
        colKeys.add(FieldKey.fromString("roomSummary"));
        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animal groups with members located in more than 1 room, excluding hospital rooms.  This may indicate that group designations need to be updated for some of the animals.</b><br>");
            final String url = getExecuteQueryUrl(c, "study", "animalGroupLocationSummary", null) + "&query.totalRooms~gt=1";
            msg.append("<p><a href='" + url + "'>Click here to view them</a><br><br>\n");

            msg.append("<table border=1 style='border-collapse: collapse;'>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>()
            {
                public void exec(ResultSet object) throws SQLException
                {
                    ResultsImpl rs = new ResultsImpl(object, columns);
                    String summary = rs.getString(FieldKey.fromString("roomSummary"));
                    if (summary != null)
                    {
                        summary = summary.replaceAll("\\)\n", ")<br>");
                        summary = summary.replaceAll("\n", " / ");
                    }

                    String group = rs.getString(FieldKey.fromString("groupId/name"));
                    String url2 = url + "&query.groupId/name~eq=" + group;
                    msg.append("<tr><td style='vertical-align:top;'><a href='" + url2 + "'>" + group + ":</a></td><td><a href='" + url2 + "'>" + summary + "</a></td></tr>\n");
                }
            });
            msg.append("</table>\n");
            msg.append("<hr>\n");
       }
    }

    /**
     * Displays any animals with duplicate flags, where duplicates are enforced
     */
    protected void duplicateFlags(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("flagDuplicates");
        TableSelector ts = new TableSelector(ti);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals with duplicate active flags from the same category.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "flagDuplicates", null) + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * Displays any animals double-assigned to animal groups
     */
    protected void duplicateGroupMembership(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("animalGroupMemberDuplicates");
        TableSelector ts = new TableSelector(ti, Collections.singleton("Id"), null, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals actively assigned to multiple animal groups.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "animalGroupMemberDuplicates", null) + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    protected void getU42Assignments(Container c, User u, final StringBuilder msg)
    {
        String U42 = "0492-02";
        TableInfo ti = getStudySchema(c, u).getTable("assignment");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("project/name"), U42, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room/housingType/value"), "Cage Location", CompareType.EQUAL);

        TableSelector ts = new TableSelector(ti, Collections.singleton("Id"), filter, null);
        long count = ts.getRowCount();
        String level = null;
        if (count > 75)
        {
            level = "ALERT";
        }
        else if (count > 65)
        {
            level = "WARNING";
        }
        else if (count == 0)
        {
            msg.append("<b>WARNING: this alert did not find any animals assigned to U42 (" + U42 + ") in caged locations.</b>  This probably indicates a problem with the alert, or perhaps the U42 project # has changed.<p><hr>");
            return;
        }

        if (level != null)
        {
            msg.append("<b>" + level + ": There are " + count + " animals assigned to U42 (" + U42 + ") that are housed in cage locations.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.Id/curLocation/room/housingType/value~eq=Cage Location&query.Id/utilization/use~contains=" + U42 + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * Displays any infants not housed with the dam
     */
    protected void infantsNotWithMother(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/age/ageInDays"), 180, CompareType.LTE);
        filter.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "ASB RM 191", CompareType.NEQ);
        filter.addCondition(FieldKey.fromString("withMother"), 0, CompareType.EQUAL);

        TableInfo ti = getStudySchema(c, u).getTable("infantsSeparateFromMother");

        Set<FieldKey> fieldKeys = new HashSet<>();
        fieldKeys.add(FieldKey.fromString("Id"));
        fieldKeys.add(FieldKey.fromString("Id/curLocation/room"));
        fieldKeys.add(FieldKey.fromString("Id/curLocation/cage"));
        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, fieldKeys);

        TableSelector ts = new TableSelector(ti, cols.values(), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals under 180 days old not housed with their dam or foster dam, excluding animals in ASB RM 191</b><br><br>");
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    ResultsImpl rs = new ResultsImpl(object, cols);
                    String subjectId = rs.getString(getStudy(c).getSubjectColumnName());
                    String location = rs.getString(FieldKey.fromString("Id/curLocation/room"));
                    String cage = rs.getString(FieldKey.fromString("Id/curLocation/cage"));
                    if (cage != null)
                        location += " " + cage;

                    String url = getParticipantURL(c, subjectId);
                    msg.append("<a href='" + url + "'>" + subjectId + " (" + location + ")</a><br>\n");
                }
            });
            msg.append("<hr>\n");
        }
    }

    /**
     * Displays any suspicious drug entries in the last 4 days
     */
    protected void suspiciousMedications(Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -4);

        int minValue = 5;
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("created"), cal.getTime(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("qcstate/PublicData"), true);
        filter.addCondition(FieldKey.fromString("code/meaning"), "ketamine;telazol", CompareType.CONTAINS_ONE_OF);
        filter.addCondition(FieldKey.fromString("amount"), minValue, CompareType.LT);
        filter.addCondition(FieldKey.fromString("amount_units"), "mg", CompareType.CONTAINS);

        TableInfo ti = getStudySchema(c, u).getTable("Drug Administration");

        TableSelector ts = new TableSelector(ti, PageFlowUtil.set(ti.getColumn("Id"), ti.getColumn("date"), ti.getColumn("amount"), ti.getColumn("amount_units")), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " drug entries since " + _dateFormat.format(cal.getTime()) + " for ketamine or telazol using mgs listing an amount less than " + minValue +"</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Drug Administration", null) + "&query.created~dategte=" + _dateFormat.format(cal.getTime()) + "&query.code/meaning~containsoneof=ketamine;telazol&query.amount_units~contains=mg&query.qcstate/PublicData~eq=true&query.amount~lt=" + minValue + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }


        int maxValue = 300;
        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("created"), cal.getTime(), CompareType.DATE_GTE);
        filter2.addCondition(FieldKey.fromString("qcstate/PublicData"), true);
        filter.addCondition(FieldKey.fromString("code/meaning"), "ketamine;telazol", CompareType.CONTAINS_ONE_OF);
        filter2.addCondition(FieldKey.fromString("amount"), maxValue, CompareType.GT);
        filter2.addCondition(FieldKey.fromString("amount_units"), "mg", CompareType.CONTAINS);

        TableSelector ts2 = new TableSelector(ti, PageFlowUtil.set(ti.getColumn("Id"), ti.getColumn("date"), ti.getColumn("amount"), ti.getColumn("amount_units")), filter2, null);
        long count2 = ts2.getRowCount();
        if (count2 > 0)
        {
            msg.append("<b>WARNING: There are " + count2 + " drug entries since " + _dateFormat.format(cal.getTime()) + " for ketamine or telazol using mgs listing an amount greater than " + maxValue + "</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Drug Administration", null) + "&query.created~dategte=" + _dateFormat.format(cal.getTime()) + "&query.code/meaning~containsoneof=ketamine;telazol&query.amount_units~contains=mg&query.qcstate/PublicData~eq=true&query.amount~gt=" + maxValue + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    protected String getParticipantURL(Container c, String id)
    {
        return AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath() + "/participantView.view?participantId=" + id;
    }
}
