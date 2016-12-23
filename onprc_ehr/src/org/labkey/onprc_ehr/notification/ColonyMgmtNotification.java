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

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * User: bbimber
 * Date: 8/4/12
 * Time: 8:28 PM
 */
public class ColonyMgmtNotification extends ColonyAlertsNotification
{
    public ColonyMgmtNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Colony Management Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Colony Management Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 15 6 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 6:15AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to identify potential problems with the colony, focused on housing.";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        final StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();

        doHousingChecks(c, u, msg);
        transfersYesterday(c, u, msg);
        roomsWithMixedViralStatus(c, u, msg);
        livingAnimalsWithoutWeight(c, u, msg);
        hospitalAnimalsWithoutCase(c, u, msg);

        offspringWithMother(c, u, msg, 150);
        offspringWithMother(c, u, msg, 180);
        offspringWithMother(c, u, msg, 250);
        offspringWithMother(c, u, msg, 365);
        incompleteBirthRecords(c, u, msg);

        //only send if there are alerts
        if (msg.length() > 0)
        {
            msg.insert(0, "This email contains a series of automatic alerts for colony management and husbandry.  It was run on: " + getDateFormat(c).format(now) + " at " + _timeFormat.format(now) + ".<p>");
        }

        return msg.toString();
    }
}
