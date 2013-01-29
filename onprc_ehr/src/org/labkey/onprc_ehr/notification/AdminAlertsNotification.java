/*
 * Copyright (c) 2012 LabKey Corporation
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
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QuerySettings;
import org.labkey.api.query.QueryView;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.util.ResultSetUtil;
import org.springframework.beans.MutablePropertyValues;
import org.springframework.validation.BindException;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Map;
import java.util.Set;

/**
 * Created by IntelliJ IDEA.
 * User: bbimber
 * Date: 8/4/12
 * Time: 4:02 PM
 */
public class AdminAlertsNotification extends AbstractEHRNotification
{
    public String getName()
    {
        return "Admin Alerts";
    }

    public String getDescription()
    {
        return "This runs every day at 10AM and sends an email summarizing various events about the site, including usage";
    }

    public String getEmailSubject()
    {
        return "Daily Admin Alerts: " + AbstractEHRNotification._dateTimeFormat.format(new Date());
    }

    public Set<String> getNotificationTypes()
    {
        return Collections.singleton(getName());
    }

    @Override
    public String getCronString()
    {
        return "0 0 10 * * ?";
    }

    public String getScheduleDescription()
    {
        return "daily at 10AM";
    }

    public String getMessage(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();
        msg.append("This email contains a series of alerts designed for site admins.  It was run on: " + AbstractEHRNotification._dateTimeFormat.format(new Date()) + ".<p>");

        siteUsage(c, u, msg);

        //TODO
//        dataEntryStatus(msg);

        //TODO: possibly log changes?  maybe other timestamps?

        return msg.toString();
    }

    /**
     * summarize site usage in the past 7 days
     */
    private void siteUsage(Container c, User u, final StringBuilder msg)
    {
        UserSchema us = QueryService.get().getUserSchema(u, c, "core");
        TableInfo ti = us.getTable("SiteUsageByDay");

        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -7);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), cal.getTime(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(ti, filter, null);
        ts.setForDisplay(true);
        Map<String, Object>[] rows = ts.getArray(Map.class);
        if (rows.length > 0)
        {
            msg.append("Site Logins In The Past 7 Days:<br>\n");
            msg.append("<table border=1><tr><td>Day of Week</td><td>Date</td><td>Logins</td></tr>");
            for (Map<String, Object> row : rows)
            {
                String date = row.get("date") == null ? "" : (String)row.get("date");
                msg.append("<tr><td>" + row.get("dayOfWeek") + "</td><td>" + date + "</td><td>" + row.get("Logins") + "</td></tr>");
            }

            msg.append("</table><p>\n");
        }
    }

    /**
     * we print some stats on data entry
     */
    private void dataEntryStatus(Container c, User u, final StringBuilder msg)
    {
        msg.append("<b>Data Entry Stats:</b><p>");

        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date());
        cal.add(Calendar.DATE, -1);
        SQLFragment sql = new SQLFragment("SELECT t.formtype, count(*) as total FROM ehr.tasks t WHERE cast(t.created as date) = '" + AbstractEHRNotification._dateFormat.format(cal.getTime()) + "' GROUP BY t.formtype ORDER BY t.formtype");

        UserSchema us = QueryService.get().getUserSchema(u, c, "core");
        SqlSelector ss = new SqlSelector(us.getDbSchema(), sql);

        msg.append("Number of Forms Created Yesterday: <br>\n");

        ss.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                msg.append(rs.getString("formtype") + ": " + rs.getInt("total") + "<br>\n");
            }
        });

        msg.append("<p>\n");
    }
}