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
public class ComplianceNotification extends ColonyAlertsNotification
{
    public ComplianceNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Compliance Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Compliance Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 5 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 5:00AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a daily summary of potential compliance or QC issues for the colony";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        doAssignmentChecks(c, u, msg);
        assignmentsNotAllowed(c, u, msg);
        overlappingProtocolCounts(c, u, msg);

        bloodDrawsOverLimit(c, u, msg, 21);

        return msg.toString();
    }
}
