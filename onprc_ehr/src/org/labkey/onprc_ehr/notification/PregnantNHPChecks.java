/*
 * Copyright (c) 2023-2026 LabKey Corporation
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
 * Created by kollil,
 * March, 2023
 */
public class PregnantNHPChecks extends ColonyAlertsNotification
{
    public PregnantNHPChecks(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Pregnant checks and gestation alerts";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Monkeys needing pregnancy checks: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 30 5 ? * THU";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every Thursday at 5:30Am";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a list of monkeys needing pregnancy checks once a week!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        pregnancyChecks(c, u, msg);

        checkPregnantGestation(c, u, msg);

        return msg.toString();
    }
}
