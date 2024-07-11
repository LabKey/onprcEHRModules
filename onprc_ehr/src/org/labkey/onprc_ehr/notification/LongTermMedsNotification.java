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

import org.apache.commons.lang3.StringUtils;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Date;
import java.util.Map;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

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