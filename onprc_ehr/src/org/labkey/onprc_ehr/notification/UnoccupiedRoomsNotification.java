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

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

/**
 * User: bimber
 * Date: 4/5/13
 * Time: 2:25 PM
 */
public class UnoccupiedRoomsNotification extends ColonyAlertsNotification
{
    public UnoccupiedRoomsNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Unoccupied Rooms Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Unoccupied Rooms: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 16 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 4:00PM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a daily list of any rooms without animals";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        unoccupiedNHPRooms(c, u, msg);



        return msg.toString();
    }

    private void unoccupiedNHPRooms(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getEHRLookupsSchema(c, u).getTable("rooms");
        assert ti instanceof AbstractTableInfo;

        LDKService.get().applyNaturalSort((AbstractTableInfo)ti, "room");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("utilization/TotalAnimals"), 0);
        filter.addCondition(FieldKey.fromString("housingType/value"), "Rodent Location", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("housingType/value"), "Off Campus", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("datedisabled"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("building"), null, CompareType.NONBLANK);
        Sort sort = new Sort("building,room");

        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("room", "building", "room_sortValue"), filter, sort);
        if (ts.getRowCount() == 0)
        {
            msg.append("There are no empty rooms");
        }
        else
        {
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'><td>Building</td><td>Room</td></tr>");

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    msg.append("<tr><td>" + (rs.getString("building") == null ? "" : rs.getString("building")) + "</td><td>" + rs.getString("room") + "</td></tr>");
                }
            });

            msg.append("</table>");
        }
    }
}
