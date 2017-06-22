/*
 * Copyright (c) 2017 LabKey Corporation
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
import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
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
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.apache.commons.lang3.StringUtils;


import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//Created: 3-8-2017  R.Blasa
public class ObeseFlagNotification extends AbstractEHRNotification
{
    public ObeseFlagNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Expiring Obese Flag Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Expiring Obese Flag Alerts: " + DateUtil.formatDateTime(c, new Date());
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
        return "The report is designed to warn users of expiring Obese Flag settings";
    }

    @Nullable
    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        Map<String, String> saved = getSavedValues(c);
        Map<String, String> toSave = new HashMap<String, String>();

        StringBuilder msg = new StringBuilder();

        ObeseFlagprocess(c, u, msg);

        return msg.toString();
    }

    private void ObeseFlagprocess(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id/Dataset/Demographics/calculated_status"), "Alive", CompareType.EQUAL);

        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("qcstate/label"), "Completed");
        filter.addCondition(FieldKey.fromString("flag/category"), "Caging Note");
        filter.addCondition(FieldKey.fromString("flag/value"), "Obese, or Pregnant");


        Calendar date = Calendar.getInstance();
        date.setTime(new Date());
        date.add(Calendar.DATE, 7);
        filter.addCondition(FieldKey.fromString("enddate"), date.getTime(),  CompareType.DATE_EQUAL);


        Sort sort = new Sort("Id");

         TableInfo ti = getStudySchema(c, u).getTable("Flags");
        List<FieldKey> colKeys = new ArrayList<>();
        colKeys.add(FieldKey.fromString(getStudy(c).getSubjectColumnName()));
        colKeys.add(FieldKey.fromString("Id"));
        colKeys.add(FieldKey.fromString("date"));
        colKeys.add(FieldKey.fromString("enddate"));
        colKeys.add(FieldKey.fromString("flag/category"));
        colKeys.add(FieldKey.fromString("flag/value"));
        final Map<FieldKey, ColumnInfo> columns = QueryService.get().getColumns(ti, colKeys);

        TableSelector ts = new TableSelector(ti, columns.values(), filter, sort);
        long total = ts.getRowCount();
        if (total == 0)
        {
            msg.append("There are no Expiring Obese Flag for today.\n");
        }
        else
        {
            //Create header information on this report
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'><td>Monkey ID</td><td>Start Date</td><td>Removal Date</td><td>Category</td><td>Meaning</td></tr>\n");


            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Results results = new ResultsImpl(rs, columns);
                    String Ids = results.getString(FieldKey.fromString("Id"));
                    Date enddates = results.getDate(FieldKey.fromString("enddate"));
                    Date datess = results.getDate(FieldKey.fromString("date"));
                    String categorys = results.getString(FieldKey.fromString("flag/category"));
                    String valuess = results.getString(FieldKey.fromString("flag/value"));
                    msg.append("<tr><td>" + Ids  + "</td><td>" + DateUtil.formatDateTime(c, datess) + "</td><td>" + DateUtil.formatDateTime(c, enddates) + "</td><td>" + categorys  + "</td><td>" + valuess  + "</td></tr>\n");

                }
            });

            msg.append("</table>\n");

        }
    }
}
