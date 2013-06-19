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

import org.labkey.api.action.NullSafeBindException;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QuerySettings;
import org.labkey.api.query.QueryView;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.ResultSetUtil;
import org.springframework.beans.MutablePropertyValues;
import org.springframework.validation.BindException;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * User: bbimber
 * Date: 8/4/12
 * Time: 4:30 PM
 */
public class BloodAdminAlertsNotification extends ColonyAlertsNotification
{
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
        drawsNotAssigned(c, u, msg);
        incompleteDraws(c, u, msg);

        //drawsWithServicesAndNoRequest(msg);

        return msg.toString();
    }
}
