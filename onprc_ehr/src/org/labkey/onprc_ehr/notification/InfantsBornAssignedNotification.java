/*
 * Copyright (c) 2013-2014 LabKey Corporation
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

import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.notification.AbstractEHRNotification;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;


import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//Created: 3-8-2017  R.Blasa
public class InfantsBornAssignedNotification extends AbstractEHRNotification
{
    public InfantsBornAssignedNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Infants Born to Assigned Animals Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Infants Born To Assigned Animals Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 7 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 7:00AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to warn users of infants that are born to Assigned Animals";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        Map<String, String> saved = getSavedValues(c);
        Map<String, String> toSave = new HashMap<String, String>();

        StringBuilder msg = new StringBuilder();

        AssignedInfantprocess(c, u, msg);

        return msg.toString();
    }

    private void AssignedInfantprocess(Container c, User u, final StringBuilder msg)
    {

        Calendar date = Calendar.getInstance();
        date.setTime(new Date());
        date.add(Calendar.DATE, -45);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), date.getTime(),  CompareType.DATE_GTE);  //birth date


        Sort sort = new Sort("-date");

        TableInfo ti = getStudySchema(c, u).getTable("InfantsBorntoAssigned");
        List<FieldKey> colKeys = new ArrayList<>();
        colKeys.add(FieldKey.fromString(getStudy(c).getSubjectColumnName()));
        colKeys.add(FieldKey.fromString("Id"));
        colKeys.add(FieldKey.fromString("date"));
        colKeys.add(FieldKey.fromString("dam"));
        colKeys.add(FieldKey.fromString("ProjectName"));

        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, sort);
        long total = ts.getRowCount();
        if (total == 0)
        {
            msg.append("There are no records of infants that were born to Assigned Animals.\n");
        }
        else
        {
            //Create header information on this report
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'><td>Monkey ID</td><td>Date</td><td>Project Name</td><td>Dam</tr>\n");


            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Results results = new ResultsImpl(rs, columns);
                    String Ids = results.getString(FieldKey.fromString("Id"));
                    Date datess = results.getDate(FieldKey.fromString("date"));
                    String dams = results.getString(FieldKey.fromString("dam"));
                    String projectname = results.getString(FieldKey.fromString("ProjectName"));

                    msg.append("<tr><td>" + PageFlowUtil.filter(Ids)  + "</td><td>" + PageFlowUtil.filter(getDateTimeFormat(c).format(datess)) + "</td><td>"  + PageFlowUtil.filter(projectname) + "</td><td>" + PageFlowUtil.filter(dams) + "</td></tr>\n");

                }
            });

            msg.append("</table>\n");

        }
    }







}
