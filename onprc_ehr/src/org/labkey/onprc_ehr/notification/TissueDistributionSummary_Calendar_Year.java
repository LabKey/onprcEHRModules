/*
 * Copyright (c) 2017-2018 LabKey Corporation
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

import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.notification.AbstractEHRNotification;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//Created: 10-13-2026 R.Blasa
public class TissueDistributionSummary_Calendar_Year extends AbstractEHRNotification
{
    public TissueDistributionSummary_Calendar_Year(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Tissue Distribution By Summary Year";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Tissue Distribution by Summary Year: " + DateUtil.formatDateTime(c, new Date());
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
        return "The report is designed to generate Tissue Distribution by Calendar year";
    }

    @Nullable
    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        Map<String, String> saved = getSavedValues(c);
        Map<String, String> toSave = new HashMap<>();

        StringBuilder msg = new StringBuilder();

        Tissuedistributionprocess(c, u, msg);

        return msg.toString();
    }

    private void Tissuedistributionprocess(Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("thirty_days_pastGestation_date"), new Date(), CompareType.DATE_LTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("TissueDistributionSummaryCalendarYr_Notification"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>Tissue Distribution Summary by Year:</b><br>\n");
            msg.append("There are " + count + " this many Tissue Distribution groups by year.<br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "TissueDistributionSummaryCalendarYr_Notification", null) + "&query.thirty_days_pastGestation_date~datelte=" + getDateTimeFormat(c).format(new Date()) + "'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
        else
        {
            msg.append("<b>WARNING: There are no Tissue Distribution Summary at this time.</b><br>\n");
        }
    }
}
