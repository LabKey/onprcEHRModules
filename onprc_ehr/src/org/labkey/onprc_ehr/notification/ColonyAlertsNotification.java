/*
 * Copyright (c) 2012-2018 LabKey Corporation
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
import org.labkey.api.data.Aggregate;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.notification.AbstractEHRNotification;
import org.labkey.api.module.Module;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryDefinition;
import org.labkey.api.query.QueryException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ehr.ONPRC_EHRManager;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

/**
 * User: bbimber
 * Date: 7/14/12
 * Time: 3:16 PM
 */
public class ColonyAlertsNotification extends AbstractEHRNotification
{
    public ColonyAlertsNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Colony Alerts";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Daily Colony Alerts: " + getDateTimeFormat(c).format(new Date());
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

    @Override
    public String getDescription()
    {
        return "The report is designed to identify potential problems with the colony, primarily related to weights, housing and assignments.";
    }

    @Override
    public String getMessageBodyHTML(final Container c, User u)
    {
        final StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();
        msg.append("This email contains a series of automatic alerts about the colony.  It was run on: " + getDateFormat(c).format(now) + " at " + AbstractEHRNotification._timeFormat.format(now) + ".<p>");

        //assignments
        doAssignmentChecks(c, u, msg);
        assignmentsWithoutReleaseCondition(c, u, msg);
        getU42Assignments(c, u, msg);
        doDuplicateResourceCheck(c, u, msg);
        doCandidateChecks(c, u, msg);

        //housing
        roomsWithMixedViralStatus(c, u, msg);
        livingAnimalsWithoutHousing(c, u, msg);
        livingAnimalsBornDead(c, u, msg);
        nonContiguousHousing(c, u, msg);
        roomsWithoutInfo(c, u, msg);
        multipleHousingRecords(c, u, msg);
        deadAnimalsWithActiveHousing(c, u, msg);

        //clinical
        deadAnimalsWithActiveCases(c, u, msg);
        deadAnimalsWithActiveFlags(c, u, msg);
        deadAnimalsWithActiveNotes(c, u, msg);
        deadAnimalsWithActiveGroups(c, u, msg);
        deadAnimalsWithActiveTreatments(c, u, msg);
        deadAnimalsWithActiveProblems(c, u, msg);
        hospitalAnimalsWithoutCase(c, u, msg);

        //blood draws
        bloodDrawsOnDeadAnimals(c, u, msg);
        bloodDrawsOverLimit(c, u, msg, 3);

        //misc
        demographicsWithoutGender(c, u, msg);
        getGeographicOriginConflicts(c, u, msg);

        incompleteBirthRecords(c, u, msg);
        birthRecordsWithoutDemographics(c, u, msg);
        deathRecordsWithoutDemographics(c, u, msg);
        demographicsDeathMismatch(c, u, msg);
        demographicsBirthMismatch(c, u, msg);
        demographicsBirthDetailsMismatch(c, u, msg);
        infantsNotAssignedToDamGroup(c, u, msg);
        infantsNotAssignedToDamSPF(c, u, msg);
        birthRecordsNotMatchingHousing(c, u, msg);
        duplicateGroupMembership(c, u, msg);
        suspiciousMedications(c, u, msg);

        //Flags
        duplicateFlags(c, u, msg);
        // Added by Kollil 9/5/23
        BCGVaccineFlags(c,u,msg);

        //notes
        notesEndingToday(c, u, msg, null, null);



        return msg.toString();
    }

    protected void doHousingChecks(final Container c, User u, final StringBuilder msg)
    {
        cagesWithoutDimensions(c, u, msg);
        cageReviewErrors(c, u, msg, true, "The Guide");
        cageReviewWarnings(c, u, msg, false, "The Guide");
        roomsWithoutInfo(c, u, msg);
        multipleHousingRecords(c, u, msg);
        deadAnimalsWithActiveHousing(c, u, msg);
        livingAnimalsWithoutHousing(c, u, msg);
        housedInUnavailableCages(c, u, msg);
        roomsReportingNegativeCagesAvailable(c, u, msg);

        animalGroupsAcrossRooms(c, u, msg);
        nonContiguousHousing(c, u, msg);
        infantsNotWithMother(c, u, msg);
    }

    protected void doAssignmentChecks(final Container c, User u, final StringBuilder msg)
    {
        deadAnimalsWithActiveAssignments(c, u, msg);
        assignmentsWithoutValidProtocol(c, u, msg);
        assignmentsWithEndedProject(c, u, msg);
        projectsWithExpiredProtocol(c, u, msg);
        duplicateAssignments(c, u, msg);
        protocolsWithFutureApproveDates(c, u, msg);
//        protocolsOverLimit(c, u, msg); Kollil, 2/12/2023: This warning is removed as per Tkt #9095 request
//        assignmentsProjectedToday(c, u, msg); Kollil, 2/12/2023: This warning is removed as per Tkt #9095 request
//        assignmentsProjectedTomorrow(c, u, msg); Kollil, 2/12/2023: This warning is removed as per Tkt #9095 request
        protocolsWithAnimalsExpiringSoon(c, u, msg);
    }

    protected void doDuplicateResourceCheck(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/activeAssignments/numResourceAssignments"), 1, CompareType.GT);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("demographics"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals assigned to more than 1 center resource.  This will cause problems for lease fees and per diems.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "demographics", null) + "&" + filter.toQueryString("query") + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void doCandidateChecks(final Container c, User u, final StringBuilder msg)
    {
        candidatesWithAssignments(c, u, msg);
        candidatesWithGroups(c, u, msg);
        candidatesForLongTime(c, u, msg);
    }

    protected void candidatesForLongTime(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("daysElapsed"), 30, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("flag/category"), "Assign Alias", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("flag/value"), ONPRC_EHRManager.AUC_RESERVED, CompareType.NEQ_OR_NULL);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("flags"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " flags for assignment aliases/candidates that have been active for more than 30 days.  This may indicate these flags should be ended.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "flags", null) + "&" + filter.toQueryString("query") + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void candidatesWithAssignments(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/activeAssignments/projects"), ONPRC_EHRManager.AUC_RESERVED + ";" + ONPRC_EHRManager.PENDING_ASSIGNMENT, CompareType.CONTAINS_ONE_OF);
        filter.addCondition(FieldKey.fromString("Id/activeAssignments/numActiveAssignments"), 0, CompareType.GT);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("demographics"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals which are flagged as " + ONPRC_EHRManager.AUC_RESERVED + " or " + ONPRC_EHRManager.PENDING_ASSIGNMENT + ", yet they are actively assigned to another project.  This may indicate the assignment candidate flags need to be removed.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "demographics", "By Location") + "&" + filter.toQueryString("query") + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void candidatesWithGroups(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/activeAnimalGroups/groups"), ONPRC_EHRManager.PENDING_SOCIAL_GROUP, CompareType.CONTAINS);
        filter.addCondition(FieldKey.fromString("Id/activeAnimalGroups/totalGroups"), 0, CompareType.GT);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("demographics"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals which are flagged as " + ONPRC_EHRManager.PENDING_SOCIAL_GROUP + ", yet they are actively assigned to an animal group.  This may indicate the assignment candidate flags need to be removed.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "demographics", "By Location") + "&" + filter.toQueryString("query") + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
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
            ts.forEach(rs -> msg.append(rs.getString("room") + "/" + rs.getString("cage") + "<br>\n"));

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "missingCages", null) + "'>Click here to view the problem cages</a></p>\n");
            msg.append("<hr>\n");
        }

        TableSelector ts2 = new TableSelector(getEHRLookupsSchema(c, u).getTable("cagesMissingColumn"));
        if (ts2.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following cages do have have their row/column specified:</b><br>\n");
            ts2.forEach(rs -> msg.append(rs.getString("cage") + "<br>\n"));

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
            ts.forEach(rs -> msg.append(rs.getString("room") + "<br>\n"));

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr_lookups", "roomUtilization", null) + "&query.CagesEmpty~lt=0'>Click here to view the problem rooms</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * Finds all rooms with animals of mixed viral status
     * Modified by Kollil, 2/17/2023
     */
    protected void roomsWithMixedViralStatus(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("distinctStatuses"), 1 , CompareType.GT);
        //Removing the filter as per the user request, Refer tkt #8418
        //As per ticket the techs want to see all the locations without exclusion in the email notification.
        //filter.addCondition(FieldKey.fromString("room/housingCondition/value"), "ABSL2+;Sequester/Containment;ABSL3", CompareType.CONTAINS_NONE_OF);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("housingMixedViralStatus"), filter, new Sort("area,room"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            //commenting out this line,
            //msg.append("<b>WARNING: The following " + count + " room(s) have animals with mixed viral statuses, excluding ABSL2+,Sequester/Containment, and ABSL3 rooms:</b><p></p>\n");
            msg.append("<b>WARNING: The following " + count + " room(s) have animals with mixed viral statuses.</b><p></p>\n");
            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "housingMixedViralStatus", null) + "&query.distinctStatuses~gt=1'>Click here to view this list</a><p/>\n");

            msg.append("<table border=1 style='border-collapse: collapse;'>\n");
            ts.forEach(rs -> {
                String status = rs.getString("viralStatuses");
                if (status != null)
                {
                    status = status.replaceAll("\\)\n", ")<br>");
                    status = status.replaceAll("\n", " / ");
                }

                String area = rs.getString("area");
                String room = rs.getString("room");
                String url = getExecuteQueryUrl(c, "study", "demographics", "By Location") + "&query.Id/curLocation/room~eq=" + room;
                msg.append("<tr><td style='vertical-align:top;'>" + area + "</td><td style='vertical-align:top;'><a href='" + url + "'>" + room + ":</a></td><td><a href='" + url + "'>" + status + "</a></td></tr>\n");
            });
            msg.append("</table>\n");
            msg.append("<hr>\n");
        }
    }

//    /**
//     * Finds all rooms with animals of mixed viral status
//     */
//    protected void roomsWithMixedViralStatus(final Container c, User u, final StringBuilder msg)
//    {
//        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("distinctStatuses"), 1 , CompareType.GT);
//        filter.addCondition(FieldKey.fromString("room/housingCondition/value"), "ABSL2+;Sequester/Containment;ABSL3", CompareType.CONTAINS_NONE_OF);
//
//        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("housingMixedViralStatus"), filter, new Sort("area,room"));
//        long count = ts.getRowCount();
//        if (count > 0)
//        {
//            msg.append("<b>WARNING: The following " + count + " rooms have animals with mixed viral statuses, excluding ABSL2+,Sequester/Containment, and ABSL3 rooms:</b><p></p>\n");
//            msg.append("<a href='" + getExecuteQueryUrl(c, "study", "housingMixedViralStatus", null) + "&query.distinctStatuses~gt=1'>Click here to view this list</a><p/>\n");
//
//            msg.append("<table border=1 style='border-collapse: collapse;'>\n");
//            ts.forEach(new TableSelector.ForEachBlock<ResultSet>()
//            {
//                @Override
//                public void exec(ResultSet rs) throws SQLException
//                {
//                    String status = rs.getString("viralStatuses");
//                    if (status != null)
//                    {
//                        status = status.replaceAll("\\)\n", ")<br>");
//                        status = status.replaceAll("\n", " / ");
//                    }
//
//                    String area = rs.getString("area");
//                    String room = rs.getString("room");
//                    String url = getExecuteQueryUrl(c, "study", "demographics", "By Location") + "&query.Id/curLocation/room~eq=" + room;
//                    msg.append("<tr><td style='vertical-align:top;'>" + area + "</td><td style='vertical-align:top;'><a href='" + url + "'>" + room + ":</a></td><td><a href='" + url + "'>" + status + "</a></td></tr>\n");
//                }
//            });
//            msg.append("</table>\n");
//            msg.append("<hr>\n");
//        }
//    }

    /**
     * Finds all occupied rooms without a record in ehr_lookups.rooms
     */
    protected void roomsWithoutInfo(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("missingRooms"));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following rooms have animals, but do not have a record in the rooms table:</b><br>\n");
            ts.forEach(rs -> msg.append(rs.getString("room") + "<br>\n"));

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "missingRooms", null) + "'>Click here to view the problem rooms</a></p>\n");
            msg.append("<hr>\n");
        }
    }

    protected void livingAnimalsWithoutWeight(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/MostRecentWeight/MostRecentWeightDate"), null, CompareType.ISBLANK);
        //Added by Kolli1, 6/11. Excluding the Guinea pigs & Rabbits and showing only primates
        //filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG+;RABBIT", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG", CompareType.NEQ);

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
            ts.forEach(rs -> {
                Results results = new ResultsImpl(rs, columns);
                msg.append(rs.getString(getStudy(c).getSubjectColumnName()));
                String age = results.getString(FieldKey.fromString("Id/age/AgeFriendly"));
                if (age != null)
                    msg.append(" (Age: " + age + ")");

                msg.append("<br>\n");
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
        //Added by Kolli1, 6/11. Excluding the Guinea pigs & Rabbits and showing only primates
        //filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG+;RABBIT", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG", CompareType.NEQ);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Housing"), filter, sort);
        long count = ts.getRowCount();
        if (count > 0)
        {
	        msg.append("<b>WARNING: There are " + count + " active housing records where the animal is not alive:</b><br>\n");

            ts.forEach(rs -> msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n"));

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
        //Added by Kolli1, 6/11. Excluding the Guinea pigs & Rabbits and showing only primates
        //filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG+;RABBIT", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG", CompareType.NEQ);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), filter, sort);
        long count = ts.getRowCount();
        if (count > 0)
        {
	        msg.append("<b>WARNING: There are " + count + " living animals without an active housing record:</b><br>\n");

            ts.forEach(rs -> msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n"));

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", null) + "&query.Id/curLocation/room/room~isblank&query.Id/Dataset/Demographics/calculated_status~eq=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void livingAnimalsBornDead(final Container c, User u, final StringBuilder msg)
    {
        Sort sort = new Sort(getStudy(c).getSubjectColumnName());
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/birth/birth_condition/alive"), false, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), filter, sort);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals listed as living, but have a birth type indicating they were born dead:</b><br>\n");

            ts.forEach(rs -> msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + "<br>\n"));

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", null, filter) + "'>Click here to view them</a><br>\n\n");
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
        filter.addCondition(FieldKey.fromString("isOpen"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Cases"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active cases or cases under review for animals not currently at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Cases", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void infantsNotAssignedToDamGroup(final Container c, User u, final StringBuilder msg)
    {
        int duration = 30;
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("matchesDamGroup"), false, CompareType.EQUAL);
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -1 * duration);
        filter.addCondition(FieldKey.fromString("birth"), cal.getTime(), CompareType.DATE_GTE);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("animalGroupInfantsNotAssigned"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " infants born within the last " + duration + " days that are not assigned to the same group as their dam on the date of birth.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "animalGroupInfantsNotAssigned", null) + "&query.matchesDamGroup~eq=false&query.birth~dategte=-" + duration + "d'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void birthRecordsNotMatchingHousing(final Container c, User u, final StringBuilder msg)
    {
        int duration = 30;
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -1 * duration);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_GTE);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("birthHousingDiscrepancies"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " birth records within the last " + duration + " days that list a room, but the housing record does not match this.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "birthHousingDiscrepancies", null, filter) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void infantsNotAssignedToDamSPF(final Container c, User u, final StringBuilder msg)
    {
        int duration = 30;
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("matchesDamStatus"), false, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("dam"), null, CompareType.NONBLANK);

//        Added: 6-21-2017  R.Blasa
        filter.addCondition(FieldKey.fromString("dam"), "", CompareType.NEQ);

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -1 * duration);
        filter.addCondition(FieldKey.fromString("birth"), cal.getTime(), CompareType.DATE_GTE);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("infantSPFStatusDiscrepancies"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " infants born within the last " + duration + " days that do not have the same SPF status as their dam.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "infantSPFStatusDiscrepancies", null, filter) + "'>Click here to view them</a><br>\n\n");
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

    protected void assignmentsWithEndedProject(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("activeAssignments/activeAssignments"), 0, CompareType.GT);
        filter.addCondition(FieldKey.fromString("enddateCoalesced"), "-0d", CompareType.DATE_LT);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("project"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " projects with active assignments that list an end date.  This is either an error in that project, or indicates these monkeys should be reassigned.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "project", null, filter) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * find any active assignment where the project lacks a valid protocol
     */
    protected void projectsWithExpiredProtocol(final Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getEHRSchema(c, u).getTable("project");
        if (!ti.getSqlDialect().isSqlServer())
        {
            return;
        }

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddateCoalesced"), "+0d", CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("protocol/renewalDate"), new Date(), CompareType.DATE_LTE);
        TableSelector ts = new TableSelector(ti, filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " active projects associated with an expired IACUC protocol.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "project", null, filter) + "'>Click here to view them</a><br>\n\n");
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

    protected void duplicateCases(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("duplicateCases"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals with multiple active cases of the same category. One of the duplicates should be closed or set for review</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "duplicateCases", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }


    protected void protocolsWithFutureApproveDates(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, 7);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("approve"), cal.getTime(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("protocol"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " IACUC protocols with approve dates listed more than 7 days in the future.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "protocol", null) + "&query.approve~dategte=%2B7d'>Click here to view them</a>\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find assignments with projected releases tomorrow
     * Kollil, 2/12/2023: This warning is removed as per Tkt #9095 request
     */
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
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Assignment", null) + "&query.projectedRelease~dateeq=" + getDateFormat(c).format(cal.getTime()) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find assignments with projected releases today
     * Kollil, 2/12/2023: This warning is removed as per Tkt #9095 request
     */
    protected void assignmentsProjectedToday(final Container c, User u, final StringBuilder msg)
    {
        Date date = new Date();
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("projectedRelease"), date, CompareType.DATE_LTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Assignment"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>ALERT: There are " + count + " assignments with a projected release date for today or earlier that have not already been ended.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Assignment", null) + "&query.projectedRelease~datelte=" + getDateFormat(c).format(date) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * protocols with active animals that expire in next 30 days
     */
    protected void protocolsWithAnimalsExpiringSoon(final Container c, User u, final StringBuilder msg)
    {
        if (!DbScope.getLabKeyScope().getSqlDialect().isSqlServer())
        {
            return;
        }

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
            msg.append("<b>WARNING: There are " + count + " protocols with active assignments set to expire within the next 30 days.</b><br>\n");
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
        filter.addCondition(FieldKey.fromString("qcstate/PublicData"), true, CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Birth"), Collections.singleton(getStudy(c).getSubjectColumnName()), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " finalized birth records without a corresponding demographics record.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Birth", null) + "&query.Id/Dataset/Demographics/Id~isblank'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void pedigreeIssues(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("parentsYoungerThanOffspring"), Collections.singleton(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " parentage records where the parent is younger than the offspring.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "parentsYoungerThanOffspring", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }

        ts = new TableSelector(getStudySchema(c, u).getTable("parentsWrongGenderOrSpecies"), Collections.singleton(getStudy(c).getSubjectColumnName()));
        count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " parentage records listed with the wrong gender or species.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "parentsWrongGenderOrSpecies", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void incompleteBirthRecords(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(new SimpleFilter.OrClause(
                //new CompareType.CompareClause(FieldKey.fromString("species"), CompareType.ISBLANK, null),
                new CompareType.CompareClause(FieldKey.fromString("Id/demographics/gender"), CompareType.ISBLANK, null),
                new CompareType.CompareClause(FieldKey.fromString("Id/demographics/species"), CompareType.ISBLANK, null),
                new CompareType.CompareClause(FieldKey.fromString("Id/demographics/geographic_origin"), CompareType.ISBLANK, null)
        ));
        filter.addCondition(FieldKey.fromString("date"), "-30d", CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("qcstate/PublicData"), true, CompareType.EQUAL);

        TableInfo ti = getStudySchema(c, u).getTable("Birth");
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("Id/demographics/gender/meaning"));
        keys.add(FieldKey.fromString("Id/demographics/species"));
        keys.add(FieldKey.fromString("Id/demographics/calculated_status"));
        keys.add(FieldKey.fromString("Id/demographics/geographic_origin"));

//        Modified: 2-20-2020 R. Blasa
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("remark"));


        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, keys);
        TableSelector ts = new TableSelector(ti, cols.values(), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " finalized birth records within the past 30 days lacking information:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr><td>Id</td><td>Status</td><td>Birth Date</td><td>Remarks</td><td>Gender</td><td>Species</td><td>Geographic Origin</td></tr>");
            ts.forEach(object -> {
                Results rs = new ResultsImpl(object, cols);
                String url = getExecuteQueryUrl(c, "study", "demographics", null);
                url = url.replaceAll("executeQuery.view", "updateQuery.view");
                url = url.replaceAll("/query/", "/ehr/");

                msg.append("<tr>");
                msg.append("<td><a href=\"" + url + "&query.Id~eq=" + rs.getString("Id") + "\">" + rs.getString("Id") + "</a></td>");
                msg.append("<td>" + (rs.getString(FieldKey.fromString("Id/demographics/calculated_status")) == null ? "Unknown" : rs.getString(FieldKey.fromString("Id/demographics/calculated_status"))) + "</td>");

             //Added: 2-20-2020  R.Blasa
                msg.append("<td>" + (rs.getString("date") == null ? "Unknown" : rs.getDate("date")) + "</td>");
                msg.append("<td>" + (rs.getString("remark") == null ? " " : rs.getString("remark")) + "</td>");

                msg.append("<td>" + (rs.getString(FieldKey.fromString("Id/demographics/gender/meaning")) == null ? "MISSING" : rs.getString(FieldKey.fromString("Id/demographics/gender/meaning"))) + "</td>");
                msg.append("<td>" + (rs.getString(FieldKey.fromString("Id/demographics/species")) == null ? "MISSING" : rs.getString(FieldKey.fromString("Id/demographics/species"))) + "</td>");
                msg.append("<td>" + (rs.getString(FieldKey.fromString("Id/demographics/geographic_origin")) == null ? "MISSING" : rs.getString(FieldKey.fromString("Id/demographics/geographic_origin"))) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table>");
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
     * Kollil : Find the pregnant NHPs whose gestation time is past 30 days
     */
    protected void checkPregnantGestation(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("thirty_days_pastGestation_date"), new Date(), CompareType.DATE_LTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("pregnancyGestationOverdue"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>Pregnant NHPs whose gestation time is past 30 days:</b><br>\n");
            msg.append("There are " + count + " pregnant animals 30 days past the gestation period.<br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "pregnancyGestationOverdue", null) + "&query.thirty_days_pastGestation_date~datelte="+ getDateTimeFormat(c).format(new Date()) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: There are no pregnant animals 30 days past the gestation period.</b><br>\n");
        }
    }

    /**
     * Kollil : Monkeys needing pregnancy checks
     * June 2023
     */
    protected void pregnancyChecks(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "study") == null) {
            msg.append("<b>Warning: The study schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }
        //Pregnancy checks query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("pregnancyChecks", ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, null);
        long count = ts.getRowCount();

        //Get num of rows
        if (count > 0) {
            msg.append("<b>Monkeys needing pregnancy checks:</b><br>\n");
            msg.append("There are " + count + " monkey(s) need pregnancy checks.<br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "pregnancyChecks", null) + "&query.containerFilterName=AllFolders'>Click here to view the list of monkeys,</a></p>\n");
            msg.append("<hr>");
        }
        else {
            msg.append("<b>WARNING: There are no monkeys that needs pregnancy checks! </b>");
            msg.append("<hr>");
        }

    }

    /**
     * Kollil, 5/12/2017 : Send DCM Notes notification on the action date
     * Modified by Kollil in Nov, 2021: Added animal Location to the alerts
     */
    protected void dcmNotesAlert(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("actiondate"), new Date(), CompareType.DATE_EQUAL);
        filter.addCondition(FieldKey.fromString("category"), "Notes Pertaining to DAR", CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Notes_WithLocation"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " DCM action items.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Notes_WithLocation", null) + "&query.actiondate~dateeq="+ getDateFormat(c).format(new Date()) + "&query.category~eq=Notes Pertaining to DAR'>Click here to view them</a><br>\n\n");
            msg.append("</p><br><hr>");
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
        if (count1 > 0)
        {
            msg.append("<b>There are " + count1 + " DCM notes entries added yesterday where \"Category = Notes pertaining to DAR\". </b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Notes_WithLocation", null) + "&query.date~dateeq="+ formatted + "&query.category~eq=Notes Pertaining to DAR'>Click here to view them</a><br>\n\n");
            msg.append("</p><br><hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: No DCM notes added yesterday where \"Category = Notes pertaining to DAR\"!</b><br><hr>");
        }

        //Added by Kollil on 11/04/2020
        //New alert for Flags added the previous day.
        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_EQUAL);
        TableSelector ts2 = new TableSelector(getStudySchema(c, u).getTable("Flags_WithLocation"), filter2, null);
        long count2 = ts2.getRowCount();
        if (count2 > 0)
        {
            msg.append("<b>There are " + count2 + " flags added yesterday. </b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Flags_WithLocation", null) + "&query.date~dateeq="+ formatted + "'>Click here to view them</a><br>\n\n");
            msg.append("</p><hr>");
        }
        else
        {
            msg.append("<b>WARNING: There are no flags added yesterday!</b><br><hr>");
        }
    }

    /**
     * Kollil, 5/12/2017 : Send BSU Notes notification on the action date
     */
    protected void bsuNotesAlert(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("actiondate"), new Date(), CompareType.DATE_EQUAL);
        filter.addCondition(FieldKey.fromString("category"), "BSU Notes", CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("notes"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " BSU action items.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "notes", null) + "&query.actiondate~dateeq="+ getDateTimeFormat(c).format(new Date()) + "&query.category~eq=BSU Notes'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: There are no BSU action items!</b><br>\n");
        }
    }

    /* Created by Kollil on Nov 1st, 2021
    Create an alert to show the following fasts treatments prescribed on the current day between 16:00 - 7:30Am
    1. Complete NPO - 2440
    2. Overnight Fast - 1807
    3. AM Fast - 1804

    Changes made by Kolli on Mar 8th, 2022
    Carly requested the following changes
    1. I can remove the "Performed by" for all the alerts.
    2. Is there an option to show who requested it and their contact information? - Yes, I can add that
    3. Can we remove the column of charge unit in the alert as well? - Yes, I will remove the chargeunit field.
    4. Added First contact, Second contact, Third Contact and Created, Created By annd Lab Phone num from ehr.requests table
    */
    protected void processFastsTreatments(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "study") == null) {
            msg.append("<b>Warning: The study schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }
        //Fasts query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("TreatmentSchedulePostOpFasts", ContainerFilter.Type.AllFolders.create(c, u));
        //((ContainerFilterable) ti).setContainerFilter(ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, null);
        long count = ts.getRowCount();

        //Get num of rows
        if (count > 0) {
            msg.append("<b>" + count + " Fast treatment(s) scheduled for today:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "TreatmentSchedulePostOpFasts", null) + "&query.containerFilterName=AllFolders'>Click here to view the fast treatments in PRIME</a></p>\n");
            msg.append("<hr>");
        }
        else {
            msg.append("<b> There are no Fast treatments scheduled today! </b>");
            msg.append("<hr>");
        }

        //Display the daily report in the email
        if (count > 0)
        {
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("location"));
            columns.add(FieldKey.fromString("date"));
            columns.add(FieldKey.fromString("enddate"));
            columns.add(FieldKey.fromString("project"));
            columns.add(FieldKey.fromString("procedurename"));
            columns.add(FieldKey.fromString("instructions"));
            columns.add(FieldKey.fromString("remark"));
            columns.add(FieldKey.fromString("FirstContact"));
            columns.add(FieldKey.fromString("SecondContact"));
            columns.add(FieldKey.fromString("ThirdContact"));
            columns.add(FieldKey.fromString("createdby"));
            columns.add(FieldKey.fromString("created"));
            columns.add(FieldKey.fromString("LabPhoneNum"));
            columns.add(FieldKey.fromString("status"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, null);

            msg.append("<hr><b>Today's Fast Treatments:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#FFD700" + '"' + "style='font-weight: bold;'>");
            msg.append("<td>Id </td><td>Location </td><td>Start Date </td><td>End Date </td><td>Project </td><td>Procedure </td><td>Instructions </td><td>Remark </td><td>First Contact </td><td>Second Contact </td><td>Third Contact </td><td>Created By </td><td>Created </td><td>Lab Phone Num </td><td>Status </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));

                msg.append("<tr bgcolor = " + '"' + "#FFFACD" + '"' + ">");
                msg.append("<td><b> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a> </b></td>\n");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("location")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("date")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("enddate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("project")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("procedurename")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("instructions")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("remark")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("FirstContact")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("SecondContact")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("ThirdContact")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("createdby")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("created")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("LabPhoneNum")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("status")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table>");
        }

    }    //End of Fasts alert

    
    /**
     * Kollil, 10/24/2019 : PMIC scheduler alert notifications Daily & Weekly
     */
    protected void pmicSchedulerAlert(final Container c, User u, final StringBuilder msg)
    {
        //PMIC container: 783D2EA5-C6AC-1036-A33C-BD25D0574070
        if (QueryService.get().getUserSchema(u, c, "extscheduler") == null) {
            msg.append("<b>Warning: The extscheduler schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }
        //Daily events query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "extscheduler").getTable("PMIC_Scheduler_Daily", ContainerFilter.Type.AllFolders.create(c, u));
        //((ContainerFilterable) ti).setContainerFilter(ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, null);
        long count = ts.getRowCount();

        //Weekly events query
        TableInfo ti1 = QueryService.get().getUserSchema(u, c, "extscheduler").getTable("PMIC_Scheduler_Weekly", ContainerFilter.Type.AllFolders.create(c, u));
        //((ContainerFilterable) ti1).setContainerFilter(ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts1 = new TableSelector(ti1, null, null);
        long count1 = ts1.getRowCount();

        //Daily events count
        if (count > 0) {
            msg.append("<b>" + count + " PMIC event(s) scheduled for today:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "extscheduler", "PMIC_Scheduler_Daily", null) + "&query.containerFilterName=AllFolders'>Click here to view the events in PRIME</a></p>\n");
            msg.append("<hr>");
        }
        else {
            msg.append("<b> There are no PMIC events scheduled today! </b>");
            msg.append("<hr>");
        }

        //Weekly events count
        if (count1 > 0) {
            msg.append("<b>" + count1 + " PMIC event(s) scheduled this week:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "extscheduler", "PMIC_Scheduler_Weekly", null) + "&query.containerFilterName=AllFolders'>Click here to view the events in PRIME</a></p>\n");
            msg.append("<hr>");
        }
        else {
            msg.append("<b> There are no PMIC events scheduled this week! </b>");
            msg.append("<hr>");
        }

        //Display the daily report in the email
        if (count > 0)
        {
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("resourceid"));
            columns.add(FieldKey.fromString("startdate"));
            columns.add(FieldKey.fromString("enddate"));
            columns.add(FieldKey.fromString("name"));
            columns.add(FieldKey.fromString("alias"));
            columns.add(FieldKey.fromString("quantity"));
            columns.add(FieldKey.fromString("comments"));
            columns.add(FieldKey.fromString("color"));
            columns.add(FieldKey.fromString("room"));
            columns.add(FieldKey.fromString("bldg"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, null);

            msg.append("<hr><b>Today's PMIC events:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#FFD700" + '"' + "style='font-weight: bold;'>");
            msg.append("<td>Resource Id </td><td>Start Date </td><td>End Date </td><td>Name </td><td>Alias </td><td>Quantity </td><td>Comments </td><td>Color </td><td>Room </td><td>Bldg </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                msg.append("<tr bgcolor = " + '"' + "#FFFACD" + '"' + ">");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("resourceid")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("startdate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("enddate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("name")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("alias")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("quantity")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("comments")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("color")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("room")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("bldg")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table>");
        }

        //Display the weekly report in the email
        if (count1 > 0) {
            Set<FieldKey> columns1 = new HashSet<>();
            columns1.add(FieldKey.fromString("resourceid"));
            columns1.add(FieldKey.fromString("startdate"));
            columns1.add(FieldKey.fromString("enddate"));
            columns1.add(FieldKey.fromString("name"));
            columns1.add(FieldKey.fromString("alias"));
            columns1.add(FieldKey.fromString("quantity"));
            columns1.add(FieldKey.fromString("comments"));
            columns1.add(FieldKey.fromString("color"));
            columns1.add(FieldKey.fromString("room"));
            columns1.add(FieldKey.fromString("bldg"));

            final Map<FieldKey, ColumnInfo> colMap1 = QueryService.get().getColumns(ti1, columns1);
            TableSelector ts3 = new TableSelector(ti1, colMap1.values(), null, null);

            msg.append("<br><b>Weekly PMIC events:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#00FF7F" + '"' + "style='font-weight: bold;'>");
            msg.append("<td>Resource Id </td><td>Start Date </td><td>End Date </td><td>Name </td><td>Alias </td><td>Quantity </td><td>Comments </td><td>Color </td><td>Room </td><td>Bldg </td></tr>");

            ts3.forEach(object -> {
                Results rs1 = new ResultsImpl(object, colMap1);
                msg.append("<tr bgcolor = " + '"' + "#CEF6CE" + '"' + ">");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("resourceid")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("startdate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("enddate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("name")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("alias")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("quantity")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("comments")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("color")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("room")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs1.getString("bldg")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table>");
        }

    }
    //End of PMIC alert

    /**
     * Kollil, 03/24/2021 : PMIC services request alert
     */
    protected void pmicServicesRequestAlert(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("PMIC_ServicesRequestAlert"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>" + count + " PMIC procedures found.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "PMIC_ServicesRequestAlert", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("</p><br><hr>");
        }
        else
        {
            msg.append("<b>WARNING: There are no scheduled PMIC procedures!</b><br><hr>");
        }
    }
    //End of PMIC alert

    /**
     * Kollil, 12/22/2022 : Find the procedure entries where the PainCategory on the procedure is not defined (IS NULL).
     * This email notification is sent to Jeff every Thursday at 7:30am.
     */
    protected void proceduresWithoutUSDAPainLevels(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "onprc_ehr") == null) {
            msg.append("<b>Warning: The onprc_ehr schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }

        //procedures query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_ehr").getTable("Procedures_Missing_PainLevels", ContainerFilter.Type.AllFolders.create(c, u));
        //((ContainerFilterable) ti).setContainerFilter(ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, null);
        long count = ts.getRowCount();

        if (count > 0) {//procedures count
            msg.append("<br><b>Active procedures with missing USDA categories:</b><br><br>");
            msg.append("<b>" + count + " procedure(s) found:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "Procedures_Missing_PainLevels", null) + "'>Click here to view the procedures in PRIME</a></p>\n");
            msg.append("<hr>");
        }

        if (count == 0) {
            msg.append("<b>Currently, there are no active procedures with missing USDA categories!</b><hr>");
        }

        //Display the daily report in the email
        if (count > 0)
        {
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("project"));
            columns.add(FieldKey.fromString("date"));
            columns.add(FieldKey.fromString("name"));
            columns.add(FieldKey.fromString("PainCategories"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, null);

            // Table header
            msg.append("<br><br><table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#00FF7F" + '"' + "style='font-weight: bold;'>");
            msg.append("<td> Id </td><td> Center Project </td><td> Date </td><td> Procedure </td><td> USDA Categories </td></tr>");

            ts2.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, colMap);
                    String url = getParticipantURL(c, rs.getString("Id"));

                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Id")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("project")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("date")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("name")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("PainCategories")) + "</td>");
                    msg.append("</tr>");
                }
            });
            msg.append("</table>");
        }
    }
    //End of USDA Pain levels alert

    /**
     * Kollil, 03/18/2021 : Housing transfer notifications Daily
     */
    protected void housingTransferAlert(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "onprc_ehr") == null) {
            msg.append("<b>Warning: The onprc_ehr schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }

        //Daily transfers query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_ehr").getTable("housing_transfers", ContainerFilter.Type.AllFolders.create(c, u));
        //((ContainerFilterable) ti).setContainerFilter(ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, new Sort("building,area,room,cage")); //Added the sort parameters by Kollil, 4/16/2024
        long count = ts.getRowCount();

        if (count > 0) {//transfers count
            msg.append("<br><b>Housing Transfers:</b><br><br>");
            msg.append("<b>" + count + " animal transfers were found in last 24 hours:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "housing_transfers", null) + "'>Click here to view the transfers in PRIME</a></p>\n");
            msg.append("<hr>");
        }
        if (count == 0) {
            msg.append("<b>There are no animal transfers today!</b><hr>");
        }

        //Display the daily report in the email
        if (count > 0) {
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("Indate"));
            columns.add(FieldKey.fromString("Building"));
            columns.add(FieldKey.fromString("Area"));
            columns.add(FieldKey.fromString("Room"));
            columns.add(FieldKey.fromString("Cage"));
            columns.add(FieldKey.fromString("housingType"));
            columns.add(FieldKey.fromString("housingCondition"));
            columns.add(FieldKey.fromString("ReasonForMove"));
            columns.add(FieldKey.fromString("Remark"));
            columns.add(FieldKey.fromString("TotalAnimals"));
            columns.add(FieldKey.fromString("ActiveClinicalTreatment"));
            columns.add(FieldKey.fromString("ActiveDiets"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, new Sort("building,area,room,cage")); //Added the sort parameters by Kollil, 4/16/2024

            //Legend
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr>");
            msg.append("<td><b> LEGEND: </b></td></tr>");
            msg.append("<tr bgcolor = " + '"' + "#FFFF00" + '"' + ">");
            msg.append("<td><b> Yellow row indicates animal transferred into an empty room. </b></td></tr>");
            msg.append("<tr bgcolor = " + '"' + "#00FFFF" + '"' + ">");
            msg.append("<td><b> Blue cell indicates animal has active Clinical treatments with no Diets. </b></td></tr>");
            msg.append("<tr bgcolor = " + '"' + "#FFA500" + '"' + ">");
            msg.append("<td><b> Orange cell indicates animal has active Clinical treatments including Diets (or) just Diets. </b></td></tr>");
            msg.append("</table>");
            // Table header
            msg.append("<br><br><table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#00FF7F" + '"' + "style='font-weight: bold;'>");
            msg.append("<td> Id </td><td> In Date </td><td> Building </td><td> Area </td><td> Room </td><td> Cage </td><td> Housing Type </td><td> Housing Condition </td><td> Reason For Move </td><td> Remark </td><td> Num animals before the transfer </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));
                int animal_count = rs.getInt("TotalAnimals");

                if (animal_count == 0)
                { //high light the row in yellow if the room was empty before the move
                    msg.append("<tr bgcolor = " + '"' + "#FFFF00" + '"' + ">");
                    if (rs.getString("ActiveClinicalTreatment") != null && rs.getString("ActiveDiets") == null)
                    {  //High light with blue color if there are any active treatments
                        msg.append("<td style= " + '"' + "background-color:#00FFFF" + '"' + "> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                    }
                    else if (rs.getString("ActiveClinicalTreatment") != null && rs.getString("ActiveDiets") != null)
                    { //High light with orange color if there are any diets within treatments
                        msg.append("<td style= " + '"' + "background-color:#FFA500" + '"' + "> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                    }
                    else
                    {
                        msg.append("<td> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                    }
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("InDate")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Building")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Area")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Room")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Cage")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("housingType")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("housingCondition")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("ReasonForMove")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Remark")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getInt("TotalAnimals")) + "</td>");
                    msg.append("</tr>");
                }
                else
                { //animal moving into non-empty room
                    if (rs.getString("ActiveClinicalTreatment") != null && rs.getString("ActiveDiets") == null)
                    {  //High light with blue color if there are any active treatments
                        msg.append("<td style= " + '"' + "background-color:#00FFFF" + '"' + "> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                    }
                    else if (rs.getString("ActiveClinicalTreatment") != null && rs.getString("ActiveDiets") != null)
                    { //High light with orange color if there are any diets within treatments
                        msg.append("<td style= " + '"' + "background-color:#FFA500" + '"' + "> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                    }
                    else
                    {
                        msg.append("<td> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                    }
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("InDate")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Building")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Area")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Room")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Cage")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("housingType")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("housingCondition")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("ReasonForMove")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("Remark")) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getInt("TotalAnimals")) + "</td>");
                    msg.append("</tr>");
                }

            });
                msg.append("</table>");
        }
    }
    //End of housing transfer alert

    /**
     * Kollil, 06/27/2024 : Long-term clinical meds notifications Daily
     * Refer Tkt# 10897 for more details
     */
    protected void LongTermMedsAlert(final Container c, User u, final StringBuilder msg)
    {
        if (QueryService.get().getUserSchema(u, c, "onprc_ehr") == null) {
            msg.append("<b>Warning: The study schema has not been enabled in this folder, so the alert cannot run!<p><hr>");
            return;
        }

        //Daily meds query
        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_ehr").getTable("SoonExpiringLongTermMeds", ContainerFilter.Type.AllFolders.create(c, u));
        TableSelector ts = new TableSelector(ti, null, new Sort("AssignedVet, Room"));
        long count = ts.getRowCount();
        if (count == 0) {
            msg.append("<b>There are no long-term clinical meds expiring soon!</b><hr>");
        }
        else if (count > 0)
        {
            //Display the report link on the notification page
            msg.append("<br><b>Soon Expiring Long-Term Clinical Meds:</b><br><br>");
            msg.append("<b>" + count + " soon to be expiring long-term clinical meds were found:</b>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "SoonExpiringLongTermMeds", null) + "'>Click here to view the meds</a></p>\n");
            msg.append("<hr>");

            //Display the report in the email
            Set<FieldKey> columns = new HashSet<>();
            columns.add(FieldKey.fromString("Id"));
            columns.add(FieldKey.fromString("date"));
            columns.add(FieldKey.fromString("enddate"));
            columns.add(FieldKey.fromString("AssignedVet"));
            columns.add(FieldKey.fromString("Room"));
            columns.add(FieldKey.fromString("frequency"));
            columns.add(FieldKey.fromString("treatmentTimes"));
            columns.add(FieldKey.fromString("Treatment"));
            columns.add(FieldKey.fromString("volume"));
            columns.add(FieldKey.fromString("concentration"));
            columns.add(FieldKey.fromString("amount"));
            columns.add(FieldKey.fromString("route"));
            columns.add(FieldKey.fromString("remark"));

            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
            TableSelector ts2 = new TableSelector(ti, colMap.values(), null, new Sort("AssignedVet, Room"));

            // Table header
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr>");
            msg.append("<br><table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr bgcolor = " + '"' + "#00FF7F" + '"' + "style='font-weight: bold;'>");
            msg.append("<td> Id </td><td> Begin Date </td><td> End Date </td><td> Assigned Vet </td><td> Room </td><td> Frequency </td><td> Times </td><td> Treatment </td><td> Volume </td><td> Drug Conc </td><td> Amount </td><td> Route </td><td> Remark </td></tr>");

            ts2.forEach(object -> {
                Results rs = new ResultsImpl(object, colMap);
                String url = getParticipantURL(c, rs.getString("Id"));

                msg.append("<td> <a href='" + url + "'>" + PageFlowUtil.filter(rs.getString("Id")) + "</a></td>\n");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("date")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("enddate")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("AssignedVet")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Room")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("frequency")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("treatmentTimes")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("Treatment")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("volume")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("concentration")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("amount")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("route")) + "</td>");
                msg.append("<td>" + PageFlowUtil.filter(rs.getString("remark")) + "</td>");
                msg.append("</tr>");
            });
            msg.append("</table>");
        }
    }
    //End of Long term meds alert

    /**
     * we find protocols over the animal limit
     * Kollil, 2/12/2023: This warning is removed as per Tkt #9095 request
     */
    protected void protocolsOverLimit(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("totalRemaining"), 0, CompareType.LT);
        filter.addCondition(FieldKey.fromString("isActive"), true);
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("animalUsage"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " protocols that have exceeded the allowable animal limit, based on the data in the system.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "animalUsage", null) + "&query.totalRemaining~lt=0&query.isActive~eq=true'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find protocols nearing the animal limit, based on number and percent
     * Kollil, 2/12/2023: This warning is removed as per Tkt #9095 request
     */
    protected void assignmentsNotAllowed(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("project/protocol/enddateCoalesced"), new Date(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("date"), "-3y", CompareType.DATE_GTE);

        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("assignmentsNotAllowed"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " assignments to active IACUC Protocols within the past 3 years that do not match known allowable animal counts (for example, animals assigned prior to the start or end of the dates listed, or cynos assigned to a project only approved for rhesus).</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "assignmentsNotAllowed", null) + "&query.project/protocol/enddateCoalesced~dategte=-0d&query.date~dategte=-3y'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    //Added: 8-7-2018  R.Blasa
    //Modified: 2/4/2022 Kollil, Tkt #7928
    protected void ValidateBiirthHousingHistory(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("BirthInitialHousingMismatch"), null, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " Birth Id(s) found with mismatched initial locations.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "BirthInitialHousingMismatch", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
        // Changed: 2/4/2022, by Kolli. Tkt #7928. Commented out this part of the code so it doesn't send the alert if there are no discrepancies.
//        else
//        {
//            msg.append("<b>WARNING: There are no Birth Initial Housing mismtached locations to report.</b><br>\n");
//        }
    }


    protected void overlappingProtocolCounts(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getEHRSchema(c, u).getTable("protocolGroupsOverlapping"));
        Map<String, List<Aggregate.Result>> results = ts.getAggregates(Arrays.asList(new Aggregate(FieldKey.fromString("protocol"), Aggregate.BaseType.COUNT, null, true), new Aggregate(FieldKey.fromString("project"), Aggregate.BaseType.COUNT, null, true)));
        Long totalProtocol = (Long)(results.get("protocol").get(0).getValue());
        Long totalProject = (Long)(results.get("project").get(0).getValue());

        if (totalProject > 0 || totalProtocol > 0)
        {
            msg.append("<b>WARNING: There are " + Math.max(totalProject, totalProtocol) + " IACUC Protocols or Center Projects that list allowable animal groups that overlap or conflict.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr", "protocolGroupsOverlapping", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void getGeographicOriginConflicts(final Container c, User u, final StringBuilder msg)
    {
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("geographicOriginConflicts"));
        long count = ts.getRowCount();

        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals where the demographics table value for geographic origin conflicts with genetic ancestry.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "geographicOriginConflicts", null) + "'>Click here to view them</a><br>\n\n");
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
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("gender/meaning"), PageFlowUtil.set("", "Unknown"), CompareType.IN);
        filter.addCondition(FieldKey.fromString("calculated_status"), "Alive", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/age/ageInDays"), 30, CompareType.GTE);

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Demographics"), filter, new Sort(getStudy(c).getSubjectColumnName()));
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: The following animals are listed as Alive and are over 30 days old, but do not have a known gender:</b><br>\n");
            ts.forEach(rs -> {
                msg.append(rs.getString(getStudy(c).getSubjectColumnName()));
                if (rs.getDate("birth") == null)
                    msg.append(" (" + getDateFormat(c).format(rs.getDate("birth")) + ")");

                msg.append("<br>\n");
            });
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", null) + "&query.gender/meaning~in=;Unknown&query.calculated_status~eq=Alive&query.Id/age/ageInDays~gte=30'>Click here to view these animals</a></p>\n");
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
            ts.forEach(rs -> msg.append(rs.getString(getStudy(c).getSubjectColumnName()) + " (" + getDateFormat(c).format(rs.getDate("date"))+ ")" + "<br>\n"));

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

        UserSchema us = getStudySchema(c, u);
        QueryDefinition qd = us.getQueryDefForTable("HousingCheck");
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);
        if (null == ti)
            return;

        SQLFragment sql = ti.getFromSQL("hc");
        Map<String, Object> params = new HashMap<>();
        params.put("MINDATE", cal.getTime());
        sql = new SQLFragment("SELECT * FROM ").append(sql);
        QueryService.get().bindNamedParameters(sql, params);

        SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
        long total = ss.getRowCount();

        if (total > 0)
        {
            msg.append("<b>WARNING: There are ").append(total).append(" housing records since ").append(getDateFormat(c).format(cal.getTime())).append(" that do not have a contiguous previous or next record.</b><br>\n");
            msg.append("<p><a href='").append(getExecuteQueryUrl(c, "study", "HousingCheck", null)).append("&query.param.MINDATE=").append(getDateFormat(c).format(cal.getTime())).append("'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    /**
     * we find open-ended problems where the animal is not alive
     */
    protected void deadAnimalsWithActiveProblems(final Container c, User u, final StringBuilder msg)
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
    protected void deadAnimalsWithActiveTreatments(final Container c, User u, final StringBuilder msg)
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

    protected void cageReviewErrors(final Container c, User u, final StringBuilder msg, boolean notifyOnNone, String requirementSet)
    {
        cageReview(c, u, msg, notifyOnNone, "ERROR", "WARNING: The following cages are too small for the animals currently in them (using " + requirementSet + "), except for animals with height/weight exemption flags:", requirementSet);
    }

    protected void cageReviewWarnings(final Container c, User u, final StringBuilder msg, boolean notifyOnNone, String requirementSet)
    {
        cageReview(c, u, msg, notifyOnNone, "WARN", "WARNING: The following cages have 5 month olds that will cause the cage to become too small when they turn 6 months:", requirementSet);
    }

    /**
     * then we find all animals with cage size problems
     * @param msg
     */
    private void cageReview(final Container c, User u, final StringBuilder msg, boolean notifyOnNone, String filterTerm, String message, String requirementSet)
    {
        UserSchema us = getEHRLookupsSchema(c, u);
        QueryDefinition qd = us.getQueryDefForTable("cageReview");
        List<QueryException> errors = new ArrayList<>();
        TableInfo ti = qd.getTable(us, errors, true);
        if (null == ti)
            return;

        SQLFragment sql = ti.getFromSQL("t");
        Map<String, Object> params = new HashMap<>();
        params.put("RequirementSet", requirementSet);
        QueryService.get().bindNamedParameters(sql, params);

        sql = new SQLFragment("SELECT * FROM ").append(sql).append(" WHERE t.status = ? ORDER BY room, cage").add(filterTerm);
        SqlSelector ss = new SqlSelector(ti.getSchema(), sql);
        Map<String, Object>[] rows = ss.getMapArray();

        if (rows.length > 0)
        {
            msg.append("<b>").append(message).append("</b><br>");
            for (Map<String, Object> row : rows)
            {
                String room = (String)row.get("room");
                String cage = (String)row.get("cage");
                String sqFtStatus = (String)row.get("sqFtStatus");
                String heightStatus = (String)row.get("heightStatus");

                if (sqFtStatus != null && !sqFtStatus.startsWith("NOTE: "))
                {
                    sqFtStatus = sqFtStatus.replaceAll("\n", ", ");
                    if (room != null)
                        msg.append("Room: ").append(room);

                    if (cage != null)
                        msg.append(" ").append(cage);

                    msg.append(": ").append(sqFtStatus);
                    msg.append("<br>");
                }

                if (heightStatus != null && !heightStatus.startsWith("NOTE: "))
                {
                    heightStatus = heightStatus.replaceAll("\n", ", ");
                    if (room != null)
                        msg.append("Room: ").append(room);

                    if (cage != null)
                        msg.append(" ").append(cage);

                    msg.append(": ").append(heightStatus);

                    msg.append("<br>");
                }
            }

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "ehr_lookups", "cageReview", "Problem Cages") + "&query.param.RequirementSet=" + requirementSet + "'>Click here to view these cages</a></p>\n");
            msg.append("<hr>\n");
        }
        else if (notifyOnNone)
        {
            msg.append("<b>Cage Size Review:</b><br><br>All cages are within size limits<br><hr>");
        }
    }

    protected void housedInUnavailableCages(final Container c, User u, final StringBuilder msg)
    {
        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        TableInfo ti = us.getTable("housedInUnavailableCages");
        TableSelector ts = new TableSelector(ti, null, new Sort("room,cage"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals housed in cages that should not be available, based on the cage/divider configuration.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "housedInUnavailableCages", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<br>");

            final Set<String> locations = new TreeSet<>();
            ts.forEach(object -> {
                String url = AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath() + "/cageDetails.view?room=" + object.getString("room");
                locations.add("<a href='" + url + "'>" + object.getString("room") + " / " + object.getString("cage") + (object.getString("expectedCage") == null ? ".  No record of this cage" : ".  Expected cage: " + object.getString("expectedCage")) + "</a>");
            });

            msg.append(StringUtils.join(locations, "<br>"));
            msg.append("<br><hr>\n\n");
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
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("animal_group_members"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals assigned to groups, where the animal is not currently housed at the center.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "animal_group_members", null) + "&query.isActive~eq=true&query.Id/Dataset/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void surgeryCasesRecentlyClosed(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -2);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddate"), cal.getTime(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("category"), "Surgery");
        filter.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive");

        Sort sort = new Sort("Id/curLocation/room");
        sort.appendSortColumn(FieldKey.fromString("Id/curLocation/cage"), Sort.SortDirection.ASC, false);

        Set<FieldKey> fks = new HashSet<>();
        fks.add(FieldKey.fromString("Id"));
        fks.add(FieldKey.fromString("Id/curLocation/room"));
        fks.add(FieldKey.fromString("Id/curLocation/cage"));
        fks.add(FieldKey.fromString("cagematesAtOpen/roomAtOpen"));
        fks.add(FieldKey.fromString("cagematesAtOpen/cageAtOpen"));
        fks.add(FieldKey.fromString("cagematesAtOpen/cagematesAtOpen"));
        fks.add(FieldKey.fromString("cagematesAtOpen/cagemateCurrentLocations"));
        fks.add(FieldKey.fromString("Id/activeAnimalGroups/groups"));

        TableInfo ti = getStudySchema(c, u).getTable("cases");
        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, fks);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, sort);
        if (ts.exists())
        {
            msg.append("The following surgery cases were closed in the past 48H:<br>");
            msg.append("<table border=1 style='border-collapse: collapse;'><tr><td>Id</td><td>Current Location</td><td>Location At Case Open</td><td>Cagemates At Open</td><td>Cagemate Current Location(s)</td><td>Active Groups</td></tr>");
            ts.forEach(object -> {
                Results rs = new ResultsImpl(object, columns);

                String currentLocation = rs.getString(FieldKey.fromString("Id/curLocation/room"));
                if (rs.getString(FieldKey.fromString("Id/curLocation/cage")) != null)
                {
                    currentLocation += " " + rs.getString(FieldKey.fromString("Id/curLocation/cage"));
                }

                String previousLocation = rs.getString(FieldKey.fromString("cagematesAtOpen/roomAtOpen"));
                if (rs.getString(FieldKey.fromString("cagematesAtOpen/cageAtOpen")) != null)
                {
                    previousLocation += " " + rs.getString(FieldKey.fromString("cagematesAtOpen/cageAtOpen"));
                }

                msg.append("<tr><td>").append(rs.getString(FieldKey.fromString("Id"))).append("</td>");
                msg.append("<td>").append(prepareStringForCell(currentLocation)).append("</td>");
                msg.append("<td>").append(prepareStringForCell(previousLocation)).append("</td>");

                msg.append("<td>").append(prepareStringForCell(rs.getString(FieldKey.fromString("cagematesAtOpen/cagematesAtOpen")))).append("</td>");
                msg.append("<td>").append(prepareStringForCell(rs.getString(FieldKey.fromString("cagematesAtOpen/cagemateCurrentLocations")))).append("</td>");
                msg.append("<td>").append(prepareStringForCell(rs.getString(FieldKey.fromString("Id/activeAnimalGroups/groups")))).append("</td>");
                msg.append("</tr>");
            });

            msg.append("</table><br>");
        }
    }

    private String prepareStringForCell(String input)
    {
        if (StringUtils.trimToNull(input) == null)
        {
            return "";
        }

        input = input.replaceAll("\n", "<br>");

        return input;
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

            String formatted = getDateFormat(c).format(cal.getTime());
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
    protected void bloodDrawsOverLimit(final Container c, User u, final StringBuilder msg, int daysInPast)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, (-1 * daysInPast));

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), EHRService.QCSTATES.RequestDenied.getLabel(), CompareType.NEQ_OR_NULL);

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
        final Set<String> lines = new HashSet<>();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " blood draws within the past " + daysInPast + " day(s) exceeding the allowable volume.  Note: this warning may include draws scheduled in the future, but have not actually been performed.  Click the IDs below to see more information:</b><br><br>");
            ts.forEach(object -> {
                Results rs = new ResultsImpl(object, columns);

                StringBuilder text = new StringBuilder();
                text.append(rs.getString(getStudy(c).getSubjectColumnName()));
                Double amount = -1.0 * rs.getDouble(FieldKey.fromString("BloodRemaining/availableBlood"));
                text.append(": ").append(DecimalFormat.getNumberInstance().format(amount)).append(" mL overdrawn on ").append(getDateFormat(c).format(rs.getDate(FieldKey.fromString("date"))));

                //String url = getParticipantURL(c, rs.getString(getStudy(c).getSubjectColumnName()));
                String url = getExecuteQueryUrl(c, "study", "Blood Draws", "With Blood Volume") + "&query.Id~eq=" + rs.getString(getStudy(c).getSubjectColumnName());
                lines.add("<a href='" + url + "'>" + text.toString() + "</a><br>\n");
            });

            //simple way to enforce uniqueness
            for (String line : lines)
            {
                msg.append(line);
            }

            msg.append("<hr>\n");
        }
    }

    /**
     * we find any requests where the animal is not assigned to that project
     */
    protected void requestsNotAssignedToProject(Container c, User u, String queryName, String label, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), EHRService.QCSTATES.RequestDenied.getLabel(), CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("requestid"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromString("isAssignedToProtocolAtTime"), "Y", CompareType.NEQ_OR_NULL);

        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        TableInfo ti = us.getTable(queryName);
        TableSelector ts = new TableSelector(ti, filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " " + label + " requests scheduled today or in the future where the animal is not assigned to the project.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", queryName, "Requests", filter) + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * find any blood draws not yet approved
     */
    protected void findNonApprovedRequests(Container c, User u, String queryName, String label, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("qcstate/label"), EHRService.QCSTATES.RequestPending.getLabel());
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable(queryName), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("WARNING: The following " + count + " " + label + " requests that have not been approved or denied yet:<br><br>");
            final Map<String, Integer> counts = new TreeMap<>();
            ts.forEach(rs -> {
                String chargeType = rs.getString("chargeType") == null ? "Not Assigned" : rs.getString("chargeType");
                Integer count1 = counts.get(chargeType);
                if (count1 == null)
                    count1 = 0;

                count1++;
                counts.put(chargeType, count1);
            });

            for (String chargeType : counts.keySet())
            {
                String otherFilter = "&query.chargetype~" + (chargeType == "Not Assigned" ? "isblank" : "eq=" + chargeType);
                msg.append(chargeType + ": ").append("<a href='" + getExecuteQueryUrl(c, "study", queryName, "Requests", filter) + otherFilter + "'>" + counts.get(chargeType) + " </a><br>\n");
            }

            msg.append("<hr>\n");
        }
    }

    /*
     * we find any incomplete requests scheduled today
     */
    protected void incompleteRequests(Container c, User u, String queryName, String label, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_EQUAL);
        filter.addCondition(FieldKey.fromString("requestid"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromString("qcstate/label"), EHRService.QCSTATES.RequestDenied.getLabel(), CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("qcstate/label"), EHRService.QCSTATES.Completed.getLabel(), CompareType.NEQ_OR_NULL);

        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        TableInfo ti = us.getTable(queryName);
        Set<FieldKey> fks = PageFlowUtil.set(FieldKey.fromString("chargetype"), FieldKey.fromString("qcstate"), FieldKey.fromString("qcstate/Label"));
        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, fks);
        TableSelector ts = new TableSelector(ti, cols.values(), filter, null);

        long count = ts.getRowCount();
        if (count == 0)
        {
            msg.append("There are no " + label + " requests scheduled for " + getDateFormat(c).format(new Date()) + " that have not already been performed.\n");
        }
        else
        {
            final String NOT_ASSIGNED = "Not Assigned";
            final Map<String, Integer> summary = new HashMap<>();
            ts.forEach(object -> {
                Results rs = new ResultsImpl(object, cols);
                String chargeType = rs.getString("chargetype") == null ? NOT_ASSIGNED : rs.getString("chargetype");
                Integer count1 = summary.get(chargeType);
                if (count1 == null)
                    count1 = 0;

                count1++;

                summary.put(chargeType, count1);
            });

            msg.append("The following " + label + " requests are scheduled for " + getDateFormat(c).format(new Date()) + ", but have not been marked complete:<p>\n");
            for (String chargeType : summary.keySet())
            {
                msg.append(chargeType + ": ");
                msg.append("<a href='" + getExecuteQueryUrl(c, "study", queryName, "Requests", filter) + (NOT_ASSIGNED.equals(chargeType) ? "&query.chargetype~isblank" : "&query.chargetype~eq=" + chargeType) + "'>" + summary.get(chargeType) + "</a><br>\n");
            }
        }

        msg.append("<hr>\n");
    }

    /**
     * we find any current or future blood draws where the animal is not alive
     */
    protected void bloodDrawsOnDeadAnimals(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("qcstate/label"), EHRService.QCSTATES.RequestDenied.getLabel(), CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("taskid"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("blood"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " current or scheduled blood draws for animals not currently at the center.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "blood", null) + "&query.date~dategte=" + getDateFormat(c).format(new Date()) + "&query.Id/DataSet/Demographics/calculated_status~neqornull=Alive'>Click here to view them</a><br>\n");
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
            msg.append("<b>WARNING: There are " + count + " animal groups with members located in more than 1 room, excluding hospital rooms.  This is not always an error, but may indicate that group designations need to be updated for some of the animals.</b><br>");
            final String url = getExecuteQueryUrl(c, "study", "animalGroupLocationSummary", null) + "&query.totalRooms~gt=1";
            msg.append("<p><a href='" + url + "'>Click here to view them</a><br><br>\n");

            msg.append("<table border=1 style='border-collapse: collapse;'>\n");
            ts.forEach(object -> {
                ResultsImpl rs = new ResultsImpl(object, columns);
                String summary = rs.getString(FieldKey.fromString("roomSummary"));
                if (summary != null)
                {
                    summary = summary.replaceAll("\\)\n", ")<br>");
                    summary = summary.replaceAll("\n", " / ");
                }

                DetailsURL groupUrl = DetailsURL.fromString("/ehr-animalGroupDetails.view", c);
                String groupUrlString = AppProps.getInstance().getBaseServerUrl() + "/onprc_ehr/onprc" + groupUrl;
                groupUrlString += "groupId=" + rs.getInt("groupId");

                String group = rs.getString(FieldKey.fromString("groupId/name"));
                String url2 = url + "&query.groupId/name~eq=" + group;
                msg.append("<tr><td style='vertical-align:top;'><a href='" + groupUrlString + "'>" + group + ":</a></td><td><a href='" + url2 + "'>" + summary + "</a></td></tr>\n");
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
     *  Created by Kollil, 9/6/23
     *  Get the new animals found with the flag, "NHPR NOTE: BCG Vaccinated".
     */
    protected void BCGVaccineFlags(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getStudySchema(c, u).getTable("BCGVaccinatedFlags");
        TableSelector ts = new TableSelector(ti);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>ALERT: " + count + " new animal(s) found with the flag, \"NHPR NOTE: BCG Vaccinated\" added yesterday.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "BCGVaccinatedFlags", null) + "'>Click here to view them</a><br>\n");
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
        String U42 = ONPRC_EHRManager.U42_PROJECT;
        TableInfo ti = getStudySchema(c, u).getTable("demographics");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/activeAssignments/projects"), U42, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room/housingType/value"), "Cage Location", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/area"), "Hospital", CompareType.NEQ_OR_NULL);

        TableSelector ts = new TableSelector(ti, Collections.singleton("Id"), filter, null);
        long count = ts.getRowCount();

        if (count == 0)
        {
            msg.append("<b>WARNING: this alert did not find any animals assigned to U42 (" + U42 + ") in caged locations.</b>  This probably indicates a problem with the alert, or perhaps the U42 project # has changed.<p><hr>");
            return;
        }

        String level = null;
        if (count > 75)
        {
            level = "ALERT";
        }
        else if (count > 65)
        {
            level = "WARNING";
        }

        if (level != null)
        {
            msg.append("<b>" + level + ": There are " + count + " animals single-assigned to U42 (" + U42 + ") that are housed in cage locations, excluding the hospital area.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.Id/curLocation/room/housingType/value~eq=Cage Location&query.Id/curLocation/area~neqornull=Hospital&query.Id/activeAssignments/projects~eq=" + U42 + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    /**
     * Displays any infants not housed with the dam
     */
    protected void infantsNotWithMother(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/age/ageInDays"), 180, CompareType.LTE);
        //Added by Kollil, 6/11. Excluding the Guinea pigs & Rabbits and showing only primates
        //filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG;RABBIT", CompareType.CONTAINS_NONE_OF);
        filter.addCondition(FieldKey.fromString("Id/demographics/species/common"), "GUINEA PIG", CompareType.NEQ);
        filter.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive", CompareType.EQUAL);
        // Changed by Kolli on 3/6/2020
        /*Rm 191 used to be a nursery, but below are the current rooms where infants are likely to be housed without dams. Can you exclude these rooms, rather than ASB RM 191?
        ASB RM 213
        ASB RM 236
        ASB RM 240
        ASB RM 185
        COL RM 4
        */
        //Added ASB 239 to this list on 5/14/2020 by kollil
        //Added ASB 234 to this list on 4/19/2023 by kollil, EHR tkt #9378
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "ASB RM 234", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "ASB RM 213", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "ASB RM 236", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "ASB RM 240", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "ASB RM 185", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "ASB RM 239", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room"), "COL RM 4", CompareType.NEQ_OR_NULL);
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
            msg.append("<b>NOTE: There are " + count + " animals under 180 days old not housed with their dam or foster dam, excluding animals in locations ASB RM 185, ASB RM 213, ASB RM 234, ASB RM 236, ASB RM 239, ASB RM 240 & COL RM 4</b><br><br>");
            ts.forEach(object -> {
                ResultsImpl rs = new ResultsImpl(object, cols);
                String subjectId = rs.getString(getStudy(c).getSubjectColumnName());
                String location = rs.getString(FieldKey.fromString("Id/curLocation/room"));
                String cage = rs.getString(FieldKey.fromString("Id/curLocation/cage"));
                if (cage != null)
                    location += " " + cage;

                String url = getParticipantURL(c, subjectId);
                msg.append("<a href='" + url + "'>" + subjectId + " (" + location + ")</a><br>\n");
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

        int minValue = 2;
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
            msg.append("<b>WARNING: There are " + count + " drug entries since " + getDateFormat(c).format(cal.getTime()) + " for ketamine or telazol using mgs listing an amount less than " + minValue +"</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Drug Administration", null) + "&query.created~dategte=" + getDateFormat(c).format(cal.getTime()) + "&query.code/meaning~containsoneof=ketamine;telazol&query.amount_units~contains=mg&query.qcstate/PublicData~eq=true&query.amount~lt=" + minValue + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }


        int maxValue = 300;
        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("created"), cal.getTime(), CompareType.DATE_GTE);
        filter2.addCondition(FieldKey.fromString("qcstate/PublicData"), true);
        filter2.addCondition(FieldKey.fromString("code/meaning"), "ketamine;telazol", CompareType.CONTAINS_ONE_OF);
        filter2.addCondition(FieldKey.fromString("amount"), maxValue, CompareType.GT);
        filter2.addCondition(FieldKey.fromString("amount_units"), "mg", CompareType.CONTAINS);

        TableSelector ts2 = new TableSelector(ti, PageFlowUtil.set(ti.getColumn("Id"), ti.getColumn("date"), ti.getColumn("amount"), ti.getColumn("amount_units")), filter2, null);
        long count2 = ts2.getRowCount();
        if (count2 > 0)
        {
            msg.append("<b>WARNING: There are " + count2 + " drug entries since " + getDateFormat(c).format(cal.getTime()) + " for ketamine or telazol using mgs listing an amount greater than " + maxValue + "</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Drug Administration", null) + "&query.created~dategte=" + getDateFormat(c).format(cal.getTime()) + "&query.code/meaning~containsoneof=ketamine;telazol&query.amount_units~contains=mg&query.qcstate/PublicData~eq=true&query.amount~gt=" + maxValue + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }

    protected String getParticipantURL(Container c, String id)
    {
        return AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath() + "/participantView.view?participantId=" + id;
    }

    protected void offspringWithMother(final Container c, User u, final StringBuilder msg, int limit)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("ageInDays"), limit, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("room/housingType/value"), "Cage Location", CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("offspringWithMother"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " offspring over " + limit + " days old that are still in cage with their mother</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "offspringWithMother", null) + "&query.room/housingType/value~eq=Cage Location&query.ageInDays~gte=" + limit + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void assignmentsWithoutReleaseCondition(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -60);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddate"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromString("enddate"), cal.getTime(), CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("releaseCondition"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("assignment"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " assignment records ended since " + getDateFormat(c).format(cal.getTime()) + " that lack a release condition.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "assignment", null, filter) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void demographicsDeathMismatch(final Container c, User u, final StringBuilder msg)
    {
        String demographicsTable = getStudy(c).getDatasetByLabel("demographics").getDomain().getStorageTableName();
        String deathTable = getStudy(c).getDatasetByLabel("deaths").getDomain().getStorageTableName();

        SQLFragment sql = new SQLFragment("SELECT d1.participantid FROM studyDataset." + demographicsTable + " d1\n" +
                "JOIN studyDataset." + deathTable + " d2 ON (d1.participantid = d2.participantid)\n" +
                "where d1.death is null OR CAST(d1.death AS DATE) != CAST(d2.date AS DATE)"
        );

        SqlSelector ss = new SqlSelector(DbScope.getLabKeyScope(), sql);
        List<String> ids = ss.getArrayList(String.class);
        if (!ids.isEmpty())
        {
            msg.append("<b>WARNING: There are " + ids.size() + " demographics records where the death date does not match the death table.</b><br>\n");
            msg.append(StringUtils.join(ids, "<br>"));
            msg.append("<hr>\n\n");
        }
    }

    protected void demographicsBirthMismatch(final Container c, User u, final StringBuilder msg)
    {
        String demographicsTable = getStudy(c).getDatasetByLabel("demographics").getDomain().getStorageTableName();
        String deathTable = getStudy(c).getDatasetByLabel("birth").getDomain().getStorageTableName();

        SQLFragment sql = new SQLFragment("SELECT d1.participantid FROM studyDataset." + demographicsTable + " d1\n" +
                "JOIN studyDataset." + deathTable + " d2 ON (d1.participantid = d2.participantid)\n" +
                "where d1.birth is null OR CAST(d1.birth AS DATE) != CAST(d2.date AS DATE)"
        );

        SqlSelector ss = new SqlSelector(DbScope.getLabKeyScope(), sql);
        List<String> ids = ss.getArrayList(String.class);
        if (!ids.isEmpty())
        {
            msg.append("<b>WARNING: There are " + ids.size() + " demographics records where the birth date does not match the birth table.</b><br>\n");
            msg.append(StringUtils.join(ids, "<br>"));
            msg.append("<hr>\n\n");
        }
    }

    protected void demographicsBirthDetailsMismatch(final Container c, User u, final StringBuilder msg)
    {
        String demographicsTable = getStudy(c).getDatasetByLabel("demographics").getDomain().getStorageTableName();
        String birthTable = getStudy(c).getDatasetByLabel("birth").getDomain().getStorageTableName();

        SQLFragment sql = new SQLFragment("SELECT d1.participantid FROM studyDataset." + demographicsTable + " d1\n" +
                "JOIN studyDataset." + birthTable + " d2 ON (d1.participantid = d2.participantid)\n" +
                "where " +
                    "(COALESCE(d1.species, '') != COALESCE(d2.species, '')) OR " +
                    "(COALESCE(d1.gender, '') != COALESCE(d2.gender, '')) OR" +
                    "(COALESCE(d1.geographic_origin, '') != COALESCE(d2.geographic_origin, ''))"
        );

        SqlSelector ss = new SqlSelector(DbScope.getLabKeyScope(), sql);
        List<String> ids = ss.getArrayList(String.class);
        if (!ids.isEmpty())
        {
            msg.append("<b>WARNING: There are " + ids.size() + " demographics records where the species, gender or geographic origin listed in the birth table does not match the value listed in the birth table.  This is a relatively minor issue not visible to any users, but should be investigated.</b><br>\n");
            msg.append(StringUtils.join(ids, "<br>"));
            msg.append("<hr>\n\n");
        }
    }

    protected void notesEndingToday(final Container c, User u, final StringBuilder msg, @Nullable List<String> includedCategories, @Nullable List<String> excludedCategories)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("enddate"), new Date(), CompareType.DATE_EQUAL);
        if (includedCategories != null)
        {
            filter.addCondition(FieldKey.fromString("category"), includedCategories, CompareType.IN);
        }

        if (excludedCategories != null)
        {
            filter.addCondition(FieldKey.fromString("category"), excludedCategories, CompareType.NOT_IN);
        }

        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("notes"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>There are " + count + " notes ending today.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "notes", null, filter) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }

        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("actiondate"), new Date(), CompareType.DATE_EQUAL);
        if (includedCategories != null)
        {
            filter2.addCondition(FieldKey.fromString("category"), includedCategories, CompareType.IN);
        }

        if (excludedCategories != null)
        {
            filter2.addCondition(FieldKey.fromString("category"), excludedCategories, CompareType.NOT_IN);
        }

        TableSelector ts2 = new TableSelector(getStudySchema(c, u).getTable("notes"), filter2, null);
        long count2 = ts2.getRowCount();
        if (count2 > 0)
        {
            msg.append("<b>There are " + count2 + " notes with an action date of today.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "notes", null, filter2) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void hospitalAnimalsWithoutCase(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/curLocation/area"), "Hospital", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/curLocation/room/housingType/value"), "Cage Location", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/activeCases/categories"), "Clinical", CompareType.DOES_NOT_CONTAIN);

        TableInfo ti = getStudySchema(c, u).getTable("demographics");

        TableSelector ts = new TableSelector(ti, Collections.singleton(ti.getColumn("Id")), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " animals in a room marked as hospital that do not have an open clinical case</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "demographics", "By Location", filter) + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
    }
}
