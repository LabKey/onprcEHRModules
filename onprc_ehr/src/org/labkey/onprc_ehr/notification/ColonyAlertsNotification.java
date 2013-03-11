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
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.gwt.client.util.StringUtils;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryDefinition;
import org.labkey.api.query.QueryException;
import org.labkey.api.query.QueryHelper;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QuerySettings;
import org.labkey.api.query.QueryView;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.ResultSetUtil;
import org.springframework.beans.MutablePropertyValues;
import org.springframework.validation.BindException;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by IntelliJ IDEA.
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

        livingAnimalsWithoutWeight(c, u, msg);
        cagesWithoutDimensions(c, u, msg);
        cageReview(c, u, msg);
        roomsWithoutInfo(c, u, msg);
        multipleHousingRecords(c, u, msg);
        deadAnimalsWithActiveHousing(c, u, msg);
        livingAnimalsWithoutHousing(c, u, msg);

        deadAnimalsWithActiveAssignments(c, u, msg);
        deadAnimalsWithActiveCases(c, u, msg);
        deadAnimalsWithActiveDiet(c, u, msg);
        deadAnimalsWithActiveFlags(c, u, msg);
        deadAnimalsWithActiveNotes(c, u, msg);
        assignmentsWithoutValidProtocol(c, u, msg);
        duplicateAssignments(c, u, msg);
        activeTreatmentsForDeadAnimals(c, u, msg);
        activeProblemsForDeadAnimals(c, u, msg);
        activeAssignmentsForDeadAnimals(c, u, msg);
        nonContiguousHousing(c, u, msg);

        //birthWithoutGender(c, u, msg);  //NOTE: ONPRC doesnt capture gender here so we ignore this
        demographicsWithoutGender(c, u, msg);
        deathWeightCheck(c, u, msg);
        protocolsNearingLimit(c, u, msg);

        //TODO
        //protocolsExpiringSoon(c, u, msg);
        birthRecordsWithoutDemographics(c, u, msg);
        deathRecordsWithoutDemographics(c, u, msg);
        assignmentsProjectedToday(c, u, msg);
        assignmentsProjectedTomorrow(c, u, msg);
        roomsReportingNegativeCagesAvailable(c, u, msg);
        housedInUnavailableCages(c, u, msg);

        //summarize events in last 5 days:
        eventsInLast5Days(c, u, msg);

        finalizedRecordsWithFutureDates(c, u, msg);

        return msg.toString();
    }
    
    /**
     * Finds all occupied cages without dimensions
     */
    protected void cagesWithoutDimensions(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("missingCages"), Table.ALL_COLUMNS, null, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following cages have animals, but do not have known dimensions:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString("room") + "/" + rs.getString("cage") + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=ehr&query.queryName=missingCages'>Click here to view the problem cages</a></p>\n");
            //msg.append("<a href='" + getBaseUrl(c) + "schemaName=ehr_lookups&query.queryName=cage'>Click here to edit the cage list and fix the problem</a></p>\n");
            msg.append("<hr>\n");
        }

    }

    /**
     * Finds all rooms reporting a negative number for available cages
     */
    protected void roomsReportingNegativeCagesAvailable(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("CagesEmpty"), 0, CompareType.LT);
        TableSelector ts = new TableSelector(getEHRLookupsSchema(c, u).getTable("roomUtilization"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following rooms reports a negative number for available cages.  This probably means there is a problem in the room/cage configuration:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString("room") + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=ehr_lookups&query.queryName=roomUtilization&query.CagesEmpty~lt=0'>Click here to view the problem rooms</a></p>\n");
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
     * Finds all occupied rooms without a record in ehr_lookups.rooms
     */
    protected void roomsWithoutInfo(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("missingRooms"), Table.ALL_COLUMNS, null, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following rooms have animals, but do not have a record in the rooms table:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString("room") + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=ehr&query.queryName=missingRooms'>Click here to view the problem rooms</a></p>\n");
            //msg.append("<a href='" + getBaseUrl(c) + "schemaName=ehr_lookups&query.queryName=cage'>Click here to edit the room list and fix the problem</a></p>\n");
            msg.append("<hr>\n");
        }

    }

    protected void livingAnimalsWithoutWeight(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/MostRecentWeight/MostRecentWeightDate"), null, CompareType.ISBLANK);
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());

        TableInfo ti = getStudySchema(c, u).getTable("Demographics");
        List<FieldKey> colKeys = new ArrayList<FieldKey>();
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

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Demographics&query.calculated_status~eq=Alive&query.Id/MostRecentWeight/MostRecentWeightDate~isblank'>Click here to view these animals</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    protected void multipleHousingRecords(final Container c, User u, final StringBuilder msg)
    {
        //then we find all living animals with multiple active housing records:
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("housingProblems"), Table.ALL_COLUMNS, null, sort);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " animals with multiple active housing records:</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=housingProblems'>Click here to view these animals</a></p>\n");
//            msg.append("<a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Housing&query.Id~in=");
//
//            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
//                public void exec(ResultSet rs) throws SQLException
//                {
//                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + ";");
//                }
//            });
//
//            msg.append("&query.enddate~isblank'>Click here to view the problem records</a><p>");
//            msg.append("<hr>\n");
        }
    }

    protected void deadAnimalsWithActiveHousing(final Container c, User u, final StringBuilder msg)
    {
        //we find open housing records where the animal is not alive
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Housing"), Table.ALL_COLUMNS, filter, sort);

        if (ts.getRowCount() > 0)
        {
	        msg.append("<b>WARNING: There are " + ts.getRowCount() + " active housing records where the animal is not alive:</b><br>\n");

            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Housing&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void livingAnimalsWithoutHousing(final Container c, User u, final StringBuilder msg)
    {
        //we find living animals without an active housing record
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/curLocation/room/room"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), Table.ALL_COLUMNS, filter, sort);
        exampleData:
        if (ts.getRowCount() > 0)
        {
	        msg.append("<b>WARNING: There are " + ts.getRowCount() + " living animals without an active housing record:</b><br>\n");

            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Demographics&query.Id/curLocation/room/room~isblank&query.Id/Dataset/Demographics/calculated_status~eq=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * find all living animals without active assignments
     */
    protected void animalsLackingAssignments(final Container c, User u, final StringBuilder msg)
    {
        QueryHelper qh = new QueryHelper(c, u, "study", "Demographics", "No Active Assignments");
        Results rs = null;
        try
        {
            rs = qh.select();
            int count = 0;
            StringBuilder tmpHtml = new StringBuilder();
            Set<String> ids = new HashSet<String>();

            while (rs.next())
            {
                ids.add(rs.getString(getStudy(c).getSubjectColumnName()));
                count++;
            }

            tmpHtml.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Demographics&query.viewName=No Active Assignments'>Click here to view these animals</a></p>\n");
            tmpHtml.append("<hr>\n");

            if (count > 0)
            {
                msg.append("<b>WARNING: There are " + count + " living animals without any active assignments:</b><br>\n");
                msg.append(StringUtils.join(new ArrayList<String>(ids), ",<br>"));
                msg.append(tmpHtml);
            }
        }
        catch (SQLException e)
        {
            throw new RuntimeSQLException(e);
        }
        finally
        {
            ResultSetUtil.close(rs);
        }
    }

    protected void deadAnimalsWithActiveAssignments(final Container c, User u, final StringBuilder msg)
    {
        //then we find all records with problems in the calculated_status field
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active assignments for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Assignment&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveCases(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Cases"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active cases for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Cases&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * find any active assignment where the project lacks a valid protocol
     */
    protected void assignmentsWithoutValidProtocol(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("project/protocol"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active assignments to a project without a valid protocol.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Assignment&query.enddate~isblank&query.project/protocol~isblank'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void duplicateAssignments(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("duplicateAssignments"), Table.ALL_COLUMNS, null, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " animals double assigned to the same project.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=duplicateAssignments'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("StudyData"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " finalized records with future dates.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=StudyData&query.date~dategt=" + AbstractEHRNotification._dateFormat.format(date) + "&query.qcstate/PublicData~eq=true&query.dataset/label~notin=" + datasets + "'>Click here to view them</a><br>\n\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Deaths"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("Deaths since " + AbstractEHRNotification._dateFormat.format(cal.getTime()) + ":<br><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Deaths&query.date~dategte=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view them</a><p>\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Birth"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("Births since " + AbstractEHRNotification._dateFormat.format(cal.getTime()) + ":<br><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Birth&query.date~dategte=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view them</a><p>\n");
        }
    }

    protected void assignmentsProjectedTomorrow(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, 1);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("projectedRelease"), cal.getTime(), CompareType.DATE_EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>ALERT: There are " + ts.getRowCount() + " assignments with a projected release date for tomorrow.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Assignment&query.projectedRelease~dateeq=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view and update them</a><br>\n\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>ALERT: There are " + ts.getRowCount() + " assignments with a projected release date for today that have not already been ended.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Assignment&query.projectedRelease~dateeq=" + AbstractEHRNotification._dateFormat.format(date) + "'>Click here to view them</a><br>\n\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Deaths"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " death records without a corresponding demographics record.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "/executeQuery.view?schemaName=study&query.queryName=Deaths&query.Id/Dataset/Demographics/Id~isblank&query.notAtCenter~neqornull=true'>Click here to view and update them</a><br>\n\n");
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
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " birth records without a corresponding demographics record.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Birth&query.Id/Dataset/Demographics/Id~isblank'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find protocols expiring soon.  this is based on protocols having a 3-year window
     */
    protected void protocolsExpiringSoon(final Container c, User u, final StringBuilder msg)
    {
        int days = 14;
        int dayValue = (365 * 3) - days;

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Approve"), "-" + dayValue + "d", CompareType.DATE_LTE);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("protocol"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " protocols that will expire within the next " + days + " days.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=ehr&query.queryName=protocol&query.Approve~datelte=-" + dayValue + "d'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find protocols nearing the animal limit, based on number and percent
     */
    protected void protocolsNearingLimit(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("TotalRemaining"), 5, CompareType.LT);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("protocolTotalAnimalsBySpecies"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " protocols with fewer than 5 remaining animals.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=ehr&query.queryName=protocolTotalAnimalsBySpecies&query.TotalRemaining~lt=5'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }

        filter = new SimpleFilter(FieldKey.fromString("PercentUsed"), 95, CompareType.GTE);
        ts = new TableSelector(getEHRSchema(c, u).getTable("protocolTotalAnimalsBySpecies"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " protocols with fewer than 5% of their animals remaining.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=ehr&query.queryName=protocolTotalAnimalsBySpecies&query.PercentUsed~gte=95'>Click here to view them</a><br>\n\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("validateFinalWeights"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        Long total = ts.getRowCount();

        if (total > 0)
        {
            msg.append("<b>WARNING: There are " + total + " animals that are dead, but do not have a weight within the previous 7 days:</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=validateFinalWeights&query.death~dategte=-90d'>Click here to view them</a></p>\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
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
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Demographics&query.gender~isblank=&query.created~dategte=-90d'>Click here to view these animals</a></p>\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Birth"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following birth records were entered in the last 90 days, but are missing a gender:</b><br>\n");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + " (" + AbstractEHRNotification._dateFormat.format(rs.getDate("date"))+ ")" + "<br>\n");
                }
            });

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Birth&query.gender~isblank=&query.date~dategte=-90d'>Click here to view these animals</a></p>\n");
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
        List<QueryException> errors = new ArrayList<QueryException>();
        TableInfo ti = qd.getTable(us, errors, true);
        SQLFragment sql = ti.getFromSQL("t");
        sql = new SQLFragment("SELECT * FROM " + sql.getSQL(), cal.getTime(), cal.getTime(), cal.getTime());
        SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
        long total = ss.getRowCount();

        if (total > 0)
        {
            msg.append("<b>WARNING: There are " + total + " housing records since " + AbstractEHRNotification._dateFormat.format(cal.getTime()) + " that do not have a contiguous previous or next record.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=HousingCheck&query.param.MINDATE=" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find open assignments where the animal is not alive
     */
    protected void activeAssignmentsForDeadAnimals(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active assignments for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Assignment&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find open ended problems where the animal is not alive
     */
    protected void activeProblemsForDeadAnimals(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Problem List"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " unresolved problems for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Problem List&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find open ended treatments where the animal is not alive
     */
    protected void activeTreatmentsForDeadAnimals(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Treatment Orders"), Table.ALL_COLUMNS, filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active treatments for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Treatment Orders&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * then we find all animals with cage size problems
     * @param msg
     */
    protected void cageReview(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("cageStatus"), "ERROR", CompareType.EQUAL);
        TableSelector ts = new TableSelector(getEHRLookupsSchema(c, u).getTable("cageReview"), Table.ALL_COLUMNS, filter, null);
        Map<String, Object>[] rows = ts.getArray(Map.class);

        if (rows.length > 0)
        {
            msg.append("<b>WARNING: The following cages are too small for the animals currently in them:</b><br>");
            for (Map<String, Object> row : rows)
            {
                String room = (String)row.get("room");
                String cage = (String)row.get("cage");

                if (room != null)
                    msg.append("Room: ").append(room);

                if (cage != null)
                    msg.append(" ").append(cage);

                msg.append("<br>");
            }

            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=ehr_lookups&query.queryName=cageReview&query.viewName=Problem Cages'>Click here to view these cages</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    protected void housedInUnavailableCages(final Container c, User u, final StringBuilder msg)
    {
        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        TableInfo ti = us.getTable("housedInUnavailableCages");
        TableSelector ts = new TableSelector(ti);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " animals housed in cages that should not be available, based on the cage/divider configuration.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=housedInUnavailableCages'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveDiet(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Diet"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active diets for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Diet&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveFlags(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Flags"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active flags for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Flags&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void deadAnimalsWithActiveNotes(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Notes"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " active notes for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Notes&query.enddate~isblank&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view and update them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }
}
