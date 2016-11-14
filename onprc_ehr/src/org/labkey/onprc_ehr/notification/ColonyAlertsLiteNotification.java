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
public class ColonyAlertsLiteNotification extends ColonyAlertsNotification
{
    public ColonyAlertsLiteNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Colony Alerts Lite";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Colony Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 5 0/1 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every 60 minutes, 5 min past the hour";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to identify potential problems with the colony, primarily related to weights, housing and assignments.  It runs a subset of the alerts from Colony Alerts and will send an email only if problems are found.";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        final StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();

        multipleHousingRecords(c, u, msg);
        deadAnimalsWithActiveHousing(c, u, msg);
        livingAnimalsWithoutHousing(c, u, msg);
        cageReviewErrors(c, u, msg, false, "The Guide");
        cageReviewErrors(c, u, msg, false, "USDA");
        deadAnimalsWithActiveAssignments(c, u, msg);
        deadAnimalsWithActiveCases(c, u, msg);
        deadAnimalsWithActiveFlags(c, u, msg);
        deadAnimalsWithActiveNotes(c, u, msg);

        deadAnimalsWithActiveTreatments(c, u, msg);
        deadAnimalsWithActiveProblems(c, u, msg);

        assignmentsWithoutValidProtocol(c, u, msg);
        duplicateAssignments(c, u, msg);

        nonContiguousHousing(c, u, msg);
        housedInUnavailableCages(c, u, msg);
        roomsReportingNegativeCagesAvailable(c, u, msg);

        //since we dont want to trigger an email if there's no alerts, conditionally append the title
        //if msg.legnth == 0, notification service wont send the message
        if (msg.length() > 0)
        {
            msg.insert(0, "This email contains a series of automatic alerts about the colony.  It was run on: " + getDateFormat(c).format(now) + " at " + AbstractEHRNotification._timeFormat.format(now) + ".<p>");
        }

        return msg.toString();
    }
}
