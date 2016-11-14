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
 * Time: 4:30 PM
 */
public class RequestAdminNotification extends ColonyAlertsNotification
{
    public RequestAdminNotification(Module owner)
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
        return "Service Request Alerts";
    }

    public String getDescription()
    {
        return "This runs periodically during the day and sends alerts related to service requests.";
    }

    public String getEmailSubject(Container c)
    {
        return "DCM Service Request Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 7,15 * * ?";
    }

    public String getScheduleDescription()
    {
        return "daily at 7AM and 3PM";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();
        msg.append("This email is designed to summarize pending or scheduled requests, including potential problems with these requests like animals lacking assignment or blood draws that would place the animal above the allowable amount.  It was run on: " + getDateFormat(c).format(now) + " at " + AbstractEHRNotification._timeFormat.format(now) + ".<p>");

        bloodDrawsOnDeadAnimals(c, u, msg);
        bloodDrawsOverLimit(c, u, msg, 1);
        incompleteRequests(c, u, "blood", "Blood Draw", msg);
        incompleteRequests(c, u, "drug", "Injection", msg);
        requestsNotAssignedToProject(c, u, "blood", "Blood Draw", msg);
        requestsNotAssignedToProject(c, u, "drug", "Injection", msg);
        findNonApprovedRequests(c, u, "blood", "Blood Draw", msg);
        findNonApprovedRequests(c, u, "drug", "Injection", msg);

        return msg.toString();
    }
}
