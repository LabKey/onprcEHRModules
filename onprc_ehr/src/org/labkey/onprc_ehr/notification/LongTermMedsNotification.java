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

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * User: bimber
 * Date: 4/5/13
 * Time: 2:25 PM
 */
public class LongTermMedsNotification extends ColonyAlertsNotification
{
    public LongTermMedsNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Long-Term Clinical Meds Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Long-Term Clinical Meds: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 40 5 ? * MON";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every Monday at 5:40AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a list of long-term clinical meds that are soon to be expiring";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        LongTermMedsAlert(c, u, msg);

        return msg.toString();
    }
}