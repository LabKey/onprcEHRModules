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

import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * User: bimber
 * Date: 4/26/13
 * Time: 9:09 AM
 */
public class TMBNotification extends ColonyAlertsNotification
{
    public TMBNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "TMB Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "TMB Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 15 5 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 5:15AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a daily summary of TMB and Reproductive Management alerts";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        matings30DaysAgo(c, u, msg);
        offspringWithMother(c, u, msg, 250);
        pregnantAnimals(c, u, msg);
        incompleteBirthRecords(c, u, msg);

        return msg.toString();
    }

    protected void matings30DaysAgo(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysElapsed"), 30, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("daysElapsed"), 36, CompareType.LTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Matings"), filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " matings that occurred 30-36 days ago</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "Matings", "30-36 Days Ago") + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void pregnantAnimals(final Container c, User u, final StringBuilder msg)
    {
        //SimpleFilter filter = new SimpleFilter(FieldKey.fromString("estDeliveryDays"), 30, CompareType.LTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("pregnantAnimals"));
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>Alert: There are " + count + " animals known to be pregnant, based on pregnancy confirmations (ultrasound/hormone tests) only.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "pregnantAnimals", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }
}
