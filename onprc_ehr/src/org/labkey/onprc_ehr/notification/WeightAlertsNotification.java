/*
 * Copyright (c) 2012-2016 LabKey Corporation
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
import org.labkey.api.settings.AppProps;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * User: bbimber
 * Date: 7/23/12
 * Time: 7:41 PM
 */
public class WeightAlertsNotification extends AbstractEHRNotification
{
    public WeightAlertsNotification(Module owner)
    {
        super(owner);
    }

    public String getName()
    {
        return "Weight Drop Alerts";
    }

    public String getDescription()
    {
        return "This will send an email to alert of any animals with significant weight changes";
    }

    public String getEmailSubject(Container c)
    {
        return "Weight Drop Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 15 9 ? * MON";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every Monday, at 9:15 AM";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();
        msg.append("This email contains alerts of significant weight changes.  It was run on: " + getDateFormat(c).format(now) + " at " + _timeFormat.format(now) + ".<p>");

        getLivingWithoutWeight(c, u, msg);

        generateCombinedWeightTable(c, u, msg);

        return msg.toString();
    }

    private void generateCombinedWeightTable(final Container c, User u, final StringBuilder msg)
    {
        StringBuilder sb = new StringBuilder();

        //first weight drops
        Set<String> dropDistinctIds = new HashSet<String>();
        processWeights(c, u, sb, 0, 30, CompareType.LTE, -10, dropDistinctIds);
        consecutiveWeightDrops(c, u, sb, dropDistinctIds);

        if (dropDistinctIds.size() > 0)
        {
            String url = getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.calculated_status~eq=Alive&query.Id~in=" + (StringUtils.join(new ArrayList(dropDistinctIds), ";"));
            sb.insert(0, "<b>WARNING: There are " + dropDistinctIds.size() + " animals that experienced either a large weight loss, or 3 consecutive weight drops.</b>  <a href='" + url + "'>Click here to view this list</a>, or view the data below.<p><hr>");
        }

        //also weight gains
        Set<String> gainDistinctIds = new HashSet<String>();
        processWeights(c, u, sb, 0, 30, CompareType.GTE, 10, gainDistinctIds);

        if (gainDistinctIds.size() > 0)
        {
            String url = getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.calculated_status~eq=Alive&query.Id~in=" + (StringUtils.join(new ArrayList(gainDistinctIds), ";"));
            sb.insert(0, "<b>WARNING: There are " + gainDistinctIds.size() + " animals that experienced large weight gain (>10%).</b>  <a href='" + url + "'>Click here to view this list</a>, or view the data below.<p><hr>");
        }

        msg.append(sb);
    }

    private void getLivingWithoutWeight(final Container c, User u, final StringBuilder msg)
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
        if (ts.exists())
        {
            msg.append("<b>WARNING: The animals listed below do not have a weight.</b>\n");
            msg.append("  <a href='" + getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.calculated_status~eq=Alive&query.Id/MostRecentWeight/MostRecentWeightDate~isblank'>Click here to view these animals</a></p>\n");

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

            msg.append("<hr>\n");
        }
    }

    private void processWeights(Container c, User u, final StringBuilder msg, int min, int max, CompareType ct, double pct, @Nullable Set<String> distinctIds)
    {
        TableInfo ti = getStudySchema(c, u).getTable("weightRelChange");
        assert ti != null;

        final FieldKey areaKey = FieldKey.fromString("Id/curLocation/Area");
        final FieldKey roomKey = FieldKey.fromString("Id/curLocation/Room");
        final FieldKey cageKey = FieldKey.fromString("Id/curLocation/Cage");
        final FieldKey ageKey = FieldKey.fromString("Id/age/AgeFriendly");
        final FieldKey problemKey = FieldKey.fromString("Id/openProblems/problems");
        final FieldKey investKey = FieldKey.fromString("Id/activeAssignments/investigators");
        final FieldKey vetsKey = FieldKey.fromString("Id/activeAssignments/vets");
        final FieldKey peKey = FieldKey.fromString("Id/physicalExamHistory/daysSinceExam");

        List<FieldKey> colKeys = new ArrayList<>();
        colKeys.add(areaKey);
        colKeys.add(roomKey);
        colKeys.add(cageKey);
        colKeys.add(ageKey);
        colKeys.add(problemKey);
        colKeys.add(investKey);
        colKeys.add(vetsKey);
        colKeys.add(peKey);
        colKeys.add(FieldKey.fromString("Id"));

        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);
        for (ColumnInfo col : ti.getColumns())
        {
            columns.put(col.getFieldKey(), col);
        }

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("PctChange"), pct, ct);
        filter.addCondition(FieldKey.fromString("IntervalInDays"), min, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("IntervalInDays"), max, CompareType.LTE);

        Calendar date = Calendar.getInstance();
        date.add(Calendar.DATE, -30);
        filter.addCondition(FieldKey.fromString("LatestWeightDate"), getDateFormat(c).format(date.getTime()), CompareType.DATE_GTE);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, null);

        msg.append("<b>Weights since " + getDateFormat(c).format(date.getTime()) + " representing changes of " + (pct > 0 ? "+" : "") + pct + "% in the past " + max + " days:</b><p>");
        final Set<String> distinctAnimals = new HashSet<String>();

        final Map<String, Map<String, List<Map<String, Object>>>> summary = new TreeMap<>();
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                Results rs = new ResultsImpl(object, columns);
                String area = rs.getString(areaKey) == null ? "" : rs.getString(areaKey);
                Map<String, List<Map<String, Object>>> areaMap = summary.get(area);
                if (areaMap == null)
                {
                    areaMap = new TreeMap<>();
                    summary.put(area, areaMap);
                }

                String room = rs.getString(roomKey) == null ? "" : rs.getString(roomKey);
                List<Map<String, Object>> roomList = areaMap.get(room);
                if (roomList == null)
                {
                    roomList = new ArrayList<>();
                    summary.get(area).put(room, roomList);
                }

                Map<String, Object> rowMap = new HashMap<>();
                rowMap.put("area", rs.getString(areaKey));
                rowMap.put("room", rs.getString(roomKey));
                rowMap.put("cage", rs.getString(cageKey));
                rowMap.put("age", rs.getString(ageKey));
                rowMap.put("weight", rs.getDouble("weight"));
                rowMap.put("LatestWeight", rs.getDouble("LatestWeight"));
                rowMap.put("LatestWeightDate", rs.getDate("LatestWeightDate"));
                rowMap.put("date", rs.getDate("date"));
                rowMap.put("IntervalInDays", rs.getInt("IntervalInDays"));
                rowMap.put("PctChange", rs.getDouble("PctChange"));
                rowMap.put("OpenProblems", rs.getString(problemKey));
                rowMap.put("Id", rs.getString("Id"));
                rowMap.put("vets", rs.getString(vetsKey));
                rowMap.put("investigators", rs.getString(investKey));
                rowMap.put("peDate", rs.getString(peKey));

                roomList.add(rowMap);

                distinctAnimals.add(rs.getString("Id"));
            }
        });

        if (summary.size() > 0)
        {
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.calculated_status~eq=Alive&query.Id~in=" + (StringUtils.join(new ArrayList(distinctAnimals), ";"))+ "'>Click here to view these " + distinctAnimals.size() + " animals</a></p>\n");

            msg.append("<table border=1><tr><td>Area</td><td>Room</td><td>Cage</td><td>Id</td><td>Investigators</td><td>Responsible Vet</td><td>Open Problems</td><td>Days Since Last PE</td><td>Weight Dates</td><td>Days Between</td><td>Weight (kg)</td><td>Percent Change</td></tr>");
            for (String area : summary.keySet())
            {
                Map<String, List<Map<String, Object>>> areaValue = summary.get(area);
                for (String room : areaValue.keySet())
                {
                    List<Map<String, Object>> roomValue = areaValue.get(room);
                    for (Map<String, Object> map : roomValue)
                    {
                        msg.append("<tr>");
                        msg.append("<td>").append(area).append("</td>");
                        msg.append("<td>").append(room).append("</td>");
                        msg.append("<td>").append(map.get("cage") == null ? "" : map.get("cage")).append("</td>");

                        msg.append("<td><a href='" + AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath());
                        msg.append("/animalHistory.view?#inputType:singleSubject&showReport:1&subjects:");
                        msg.append(map.get("Id")).append("'>").append(map.get("Id"));
                        msg.append("</a></td>");

                        msg.append("<td>").append(map.get("investigators") == null ? "" : map.get("investigators")).append("</td>");
                        msg.append("<td>").append(map.get("vets") == null ? "" : map.get("vets")).append("</td>");

                        msg.append("<td>").append(map.get("OpenProblems") == null ? "" : map.get("OpenProblems")).append("</td>");
                        msg.append("<td>").append(map.get("peDate") == null ? "" : map.get("peDate")).append("</td>");

                        msg.append("<td>").append(getDateTimeFormat(c).format(map.get("LatestWeightDate"))).append("<br>");
                        msg.append(getDateTimeFormat(c).format(map.get("date"))).append("</td>");

                        msg.append("<td>").append(map.get("IntervalInDays")).append("</td>");

                        msg.append("<td>").append(map.get("LatestWeight")).append("<br>");
                        msg.append(map.get("weight")).append("</td>");

                        msg.append("<td>").append(map.get("PctChange")).append("</td>");
                        msg.append("</tr>");
                    }
                }
            }
            msg.append("</table><p>\n");
            msg.append("<hr>");
        }
        else
        {
            msg.append("There are no changes during this period.<hr>");
        }

        if (distinctIds != null && distinctAnimals.size() > 0)
            distinctIds.addAll(distinctAnimals);
    }

    protected void consecutiveWeightDrops(final Container c, User u, final StringBuilder msg, @Nullable Set<String> distinctIds)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/dataset/demographics/calculated_status"), "Alive");
        Calendar date = Calendar.getInstance();
        date.add(Calendar.DATE, -10);

        filter.addCondition(FieldKey.fromString("date"), date.getTime(), CompareType.DATE_GTE);
        Sort sort = new Sort();
        sort.appendSortColumn(new Sort.SortField(FieldKey.fromString("Id/curLocation/area"), Sort.SortDirection.ASC));
        sort.appendSortColumn(new Sort.SortField(FieldKey.fromString("Id/curLocation/room"), Sort.SortDirection.ASC));
        sort.appendSortColumn(new Sort.SortField(FieldKey.fromString("Id/curLocation/cage"), Sort.SortDirection.ASC));

        TableInfo ti = getStudySchema(c, u).getTable("weightConsecutiveDrops");
        assert ti != null;

        List<FieldKey> colKeys = new ArrayList<>();
        colKeys.add(FieldKey.fromString("Id/curLocation/area"));
        colKeys.add(FieldKey.fromString("Id/curLocation/room"));
        colKeys.add(FieldKey.fromString("Id/curLocation/cage"));
        colKeys.add(FieldKey.fromString("Id/activeAssignments/investigators"));
        colKeys.add(FieldKey.fromString("Id/activeAssignments/vets"));
        colKeys.add(FieldKey.fromString("Id/physicalExamHistory/daysSinceExam"));
        colKeys.add(FieldKey.fromString("Id/openProblems/problems"));

        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);
        for (ColumnInfo col : ti.getColumns())
        {
            columns.put(col.getFieldKey(), col);
        }

        TableSelector ts = new TableSelector(ti, columns.values(), filter, sort);
        if (ts.exists())
        {
            final Set<String> animalIds = new HashSet<>();

            msg.append("<b>WARNING: The following animals have a weight entered since " + getDateFormat(c).format(date.getTime()) + " representing 3 consecutive weight drops with a total drop of more than 3%:</b><br><br>\n");

            final StringBuilder tableMsg = new StringBuilder();
            tableMsg.append("<table border=1><tr><td>Room</td><td>Cage</td><td>Id</td><td>Investigator(s)</td><td>Responsible Vet</td><td>Open Problems</td><td>Days Since Last PE</td><td>Weight Date</td><td>Interval (days)</td><td>Weight (kg)</td><td>% Change</td></tr>");
            ts.forEach(new TableSelector.ForEachBlock<ResultSet>(){
                public void exec(ResultSet rs) throws SQLException
                {
                    Results results = new ResultsImpl(rs, columns);

                    tableMsg.append("<tr>");
                    tableMsg.append("<td>").append(getValue(results, "Id/curLocation/room")).append("</td>");
                    tableMsg.append("<td>").append(getValue(results, "Id/curLocation/cage")).append("</td>");
                    String subj = getValue(results, getStudy(c).getSubjectColumnName());
                    tableMsg.append("<td><a href='" + AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath());
                    tableMsg.append("/animalHistory.view?#inputType:singleSubject&showReport:1&subjects:" + subj + "'>");
                    tableMsg.append(subj).append("</a></td>");

                    tableMsg.append("<td>").append(getValue(results, "Id/activeAssignments/investigators")).append("</td>");
                    tableMsg.append("<td>").append(getValue(results, "Id/activeAssignments/vets")).append("</td>");
                    tableMsg.append("<td>").append(getValue(results, "Id/openProblems/problems")).append("</td>");
                    tableMsg.append("<td>").append(getValue(results, "Id/physicalExamHistory/daysSinceExam")).append("</td>");

                    tableMsg.append("<td>").append(getDateValue(c, results, "date")).append("<br>");
                    tableMsg.append(getDateValue(c, results, "prevDate1")).append("<br>");
                    tableMsg.append(getDateValue(c, results, "prevDate2"));
                    tableMsg.append("</td>");

                    tableMsg.append("<td>");
                    tableMsg.append(getNumericValue(results, "interval1")).append("<br>");
                    tableMsg.append(getNumericValue(results, "interval2")).append("<br>");
                    tableMsg.append("<br>");
                    tableMsg.append("</td>");

                    tableMsg.append("<td>").append(getValue(results, "curWeight")).append("<br>");
                    tableMsg.append(getValue(results, "prevWeight1")).append("<br>");
                    tableMsg.append(getValue(results, "prevWeight2"));
                    tableMsg.append("</td>");

                    tableMsg.append("<td>").append(getNumericValue(results, "pctChange1")).append("<br>");
                    tableMsg.append(getNumericValue(results, "pctChange2")).append("<br>");
                    tableMsg.append("<br>");
                    tableMsg.append("</td>");

                    tableMsg.append("</tr>");

                    String id = getValue(results, getStudy(c).getSubjectColumnName());
                    if (id != null)
                        animalIds.add(id);
                }
            });

            tableMsg.append("</table>\n");

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Demographics", "By Location") + "&query.calculated_status~eq=Alive&query.Id~in=" + (StringUtils.join(new ArrayList(animalIds), ";"))+ "'>Click here to view these " + animalIds.size() + " animals</a></p>\n");
            msg.append(tableMsg);
            msg.append("<hr>\n");

            if (distinctIds != null && animalIds.size() > 0)
                distinctIds.addAll(animalIds);
        }
    }

    private String getValue(Results rs, String prop) throws SQLException
    {
        String val = rs.getString(FieldKey.fromString(prop));
        return val == null ? "" : val;
    }

    private String getNumericValue(Results rs, String prop) throws SQLException
    {
        String val = rs.getString(FieldKey.fromString(prop));
        return val == null ? "" : val;
    }

    private String getDateValue(Container c, Results rs, String dateProp) throws SQLException
    {
        Date dateVal = rs.getDate(FieldKey.fromString(dateProp));
        return dateVal == null ? "" : getDateFormat(c).format(dateVal);
    }
}
