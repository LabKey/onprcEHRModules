/*
 * Copyright (c) 2013 LabKey Corporation
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
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 4/5/13
 * Time: 2:25 PM
 */
public class BehaviorNotification extends ColonyAlertsNotification
{
    @Override
    public String getName()
    {
        return "Behavior Notification";
    }

    @Override
    public String getEmailSubject()
    {
        return "Behavior Alerts: " + _dateTimeFormat.format(new Date());
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
        return "The report is designed to provide a daily summary of issues related to behavior management, such as housing, pairing, and behavior cases";
    }

    @Override
    public String getMessage(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        doHousingChecks(c, u, msg);



        return msg.toString();
    }
}
