/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
 * Time: 4:30 PM
 */
public class BloodAdminAlertsNotification extends ColonyAlertsNotification
{
    public BloodAdminAlertsNotification(Module owner)
    {
        super(owner);
    }

    public static enum TimeOfDay {
        AM(9),
        Noon(12),
        PM(15);

        private TimeOfDay(int hour)
        {
            this.hour = hour;
        }

        private int hour;
    }

    public String getName()
    {
        return "Blood Admin Alerts";
    }

    public String getDescription()
    {
        return "This runs periodically during the day and sends alerts for incomplete blood draws and other potential problems in the blood draw schedule.";
    }

    public String getEmailSubject()
    {
        return "Blood Admin Alerts: " + AbstractEHRNotification._dateTimeFormat.format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 10,13 * * ?";
    }

    public String getScheduleDescription()
    {
        return "daily at 10AM and 1PM";
    }

    public String getMessage(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();
        msg.append("This email contains any scheduled blood draws not marked as completed, along with other potential problems in the blood schedule.  It was run on: " + AbstractEHRNotification._dateFormat.format(now) + " at " + AbstractEHRNotification._timeFormat.format(now) + ".<p>");

        bloodDrawsOnDeadAnimals(c, u, msg);
        bloodDrawsOverLimit(c, u, msg);
        bloodDrawsNotAssignedToProject(c, u, msg);
        findNonApprovedDraws(c, u, msg);
        incompleteDraws(c, u, msg);

        //drawsWithServicesAndNoRequest(msg);

        return msg.toString();
    }
}
