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
public class DataValidationNotification extends ColonyAlertsNotification
{
    public DataValidationNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "EHR Data Validation Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "EHR Data Validation Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 50 6,15 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 6:50AM and 3:50PM";
    }

    @Override
    public String getDescription()
    {
        return "The report identifies potential problems with the EHR data. Although similar to Colony Alerts, it is limited to problems in the data itself.";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        final StringBuilder msg = new StringBuilder();

        //Find today's date
        Date now = new Date();

        //assignments
        deadAnimalsWithActiveAssignments(c, u, msg);
        assignmentsWithoutValidProtocol(c, u, msg);
        assignmentsWithEndedProject(c, u, msg);
        projectsWithExpiredProtocol(c, u, msg);
        duplicateAssignments(c, u, msg);
        protocolsWithFutureApproveDates(c, u, msg);
        doDuplicateResourceCheck(c, u, msg);

        //housing
        livingAnimalsWithoutHousing(c, u, msg);
        livingAnimalsBornDead(c, u, msg);
        nonContiguousHousing(c, u, msg);
        roomsWithoutInfo(c, u, msg);
        multipleHousingRecords(c, u, msg);
        deadAnimalsWithActiveHousing(c, u, msg);

        //clinical
        deadAnimalsWithActiveCases(c, u, msg);
        deadAnimalsWithActiveFlags(c, u, msg);
        deadAnimalsWithActiveNotes(c, u, msg);
        deadAnimalsWithActiveGroups(c, u, msg);
        deadAnimalsWithActiveTreatments(c, u, msg);
        deadAnimalsWithActiveProblems(c, u, msg);

        //blood draws
        bloodDrawsOnDeadAnimals(c, u, msg);

        //misc
        demographicsWithoutGender(c, u, msg);
        incompleteBirthRecords(c, u, msg);
        birthRecordsWithoutDemographics(c, u, msg);
        deathRecordsWithoutDemographics(c, u, msg);
        demographicsDeathMismatch(c, u, msg);
        demographicsBirthMismatch(c, u, msg);
        demographicsBirthDetailsMismatch(c, u, msg);
        infantsNotAssignedToDamGroup(c, u, msg);
        infantsNotAssignedToDamSPF(c, u, msg);
        birthRecordsNotMatchingHousing(c, u, msg);
        duplicateGroupMembership(c, u, msg);
        duplicateFlags(c, u, msg);
        //Added by Kolli, Oct 2025
        //Tasks list alert for the new animal births, Refer to # 13504
        newBirthTasks(c, u, msg);

        //only send if there are alerts
        if (!msg.isEmpty())
        {
            msg.insert(0, "This email contains a series of automatic alerts identifying problems in the EHR data.  It was run on: " + getDateFormat(c).format(now) + " at " + _timeFormat.format(now) + ".<p>");
        }

        return msg.toString();
    }
}
