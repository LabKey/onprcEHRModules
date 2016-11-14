/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

//Added 6-23-2015 Blasa
public class TreatmentAlertsPostOpsNotification extends AbstractEHRNotification
{
    public TreatmentAlertsPostOpsNotification(Module owner)
    {
        super(owner);
    }

    public String getName()
    {
        return "Treatment PostOpsMed Alerts";
    }

    public String getDescription()
    {
        return "This runs every day at 9AM, 1PM, 5PM  if there are treatments scheduled that have not yet been marked complete";
    }

    public String getEmailSubject(Container c)
    {
        return "Daily Treatment PostOpsMed Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString() {return "0 0 9,13,17 * * ?";}

    public String getScheduleDescription()
    {
        return "daily at 9AM,1PM, 5PM";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();
        msg.append("This email contains any treatments not marked as completed.  It was run on: " + getDateFormat(c).format(now) + " at " + _timeFormat.format(now) + ".<p>");


        processPostOpsTreatments(c, u, msg, new Date());

        return msg.toString();
    }



      // Added 6-23-2015  Blasa  Address Notifications for only Post Ops Meds
    private void processPostOpsTreatments(Container c, User u, final StringBuilder msg, final Date maxDate)
    {
        Date curDate = new Date();
        Date roundedMax = new Date();
        roundedMax.setTime(maxDate.getTime());
        roundedMax = DateUtils.truncate(roundedMax, Calendar.DATE);

        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("treatmentSchedulePostOps");

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), roundedMax, CompareType.DATE_EQUAL);
        filter.addCondition(FieldKey.fromString("date"), maxDate, CompareType.LTE);
        filter.addCondition(FieldKey.fromString("Id/DataSet/Demographics/calculated_status"), "Alive");


        Set<FieldKey> columns = new HashSet<>();
        columns.add(FieldKey.fromString("Id"));
        columns.add(FieldKey.fromString("Id/curLocation/area"));
        columns.add(FieldKey.fromString("Id/curLocation/room"));
        columns.add(FieldKey.fromString("Id/curLoation/cage"));
        columns.add(FieldKey.fromString("projectStatus"));
        columns.add(FieldKey.fromString("treatmentStatus"));
        columns.add(FieldKey.fromString("treatmentStatus/Label"));
        columns.add(FieldKey.fromString("code"));
        columns.add(FieldKey.fromString("code/meaning"));

        Map<String, Object> params = new HashMap<>();
        params.put("StartDate", roundedMax);
        params.put("NumDays", 1);

        final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
        TableSelector ts = new TableSelector(ti, colMap.values(), filter, new Sort("Id/curLocation/area,Id/curLocation/room"));
        ts.setNamedParameters(params);

        String url = getExecuteQueryUrl(c, "study", "treatmentSchedulePostOps", null) + "&" + filter.toQueryString("query") + getParameterUrlString(c, params);
        long total = ts.getRowCount();
        if (total == 0)
        {
            msg.append("There are no treatments scheduled on " + getDateFormat(c).format(maxDate) + " on or before " + _timeFormat.format(maxDate) + ". Treatments could be added after this email was sent, so please <a href='" + url + "'>click here to check online</a> closer to the time.<hr>\n");
        }
        else
        {
            final String completed = "completed";
            final String incomplete = "incomplete";
            final Map<String, Integer> totals = new HashMap<>();
            totals.put(completed, 0);
            totals.put(incomplete, 0);

            final Map<String, Integer> totalByArea = new TreeMap<>();

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, colMap);
                    //Modified 7-2-2015 Blasa Comparing QC state to column values
                    if ("Completed".equals(rs.getString(FieldKey.fromString("treatmentStatus"))))
                    {
                        totals.put(completed, totals.get(completed) + 1);
                    }
                    else
                    {
                        totals.put(incomplete, totals.get(incomplete) + 1);

                        String area = rs.getString(FieldKey.fromString("Id/curLocation/area"));
                        if (area == null)
                        {
                            area = "<Unknown Area>";
                        }
                        Integer areaVal = totalByArea.containsKey(area) ? totalByArea.get(area) : 0;
                        areaVal++;

                        totalByArea.put(area, areaVal);
                    }
                }
            });

            msg.append("<b>Treatments:</b><p>");
            msg.append("There are " + (totals.get(completed) + totals.get(incomplete)) + " scheduled treatments on or before " + _timeFormat.format(maxDate) + ".  <a href='" + url + "'>Click here to view them</a>.  Of these, " + totals.get(completed) + " have been marked completed.</p>\n");

            if (totals.get(incomplete) == 0)
            {
                msg.append("All treatments scheduled prior to " + _timeFormat.format(maxDate) + " have been marked complete as of " + getDateTimeFormat(c).format(curDate) + ".<p>\n");
            }
            else
            {
                msg.append("There are " + totals.get(incomplete) + " treatments that have not been marked complete:<p>\n");
                msg.append("<table border=1 style='border-collapse: collapse;'>");

                for (String area : totalByArea.keySet())
                {
                    msg.append("<tr><td><b>" + PageFlowUtil.filter(area) + ":</b></td><td><a href='" + url + "&query.Id/curLocation/area~eq=" + PageFlowUtil.filter(area) + "'>" + totalByArea.get(area) + "</a></td></tr>\n");
                }

                msg.append("</table><p>\n");
            }
            msg.append("<hr>\n");
        }
    }
}