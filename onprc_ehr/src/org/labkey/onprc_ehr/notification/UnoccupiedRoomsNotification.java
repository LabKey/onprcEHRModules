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

        unoccupiedSLARooms(c, u, msg);

        return msg.toString();
    }


    private void unoccupiedNHPRooms(Container c, User u, final StringBuilder msg)
    {
        TableInfo ti = getEHRLookupsSchema(c, u).getTable("rooms", null , true, true);
        assert ti instanceof AbstractTableInfo;

        LDKService.get().applyNaturalSort((AbstractTableInfo) ti, "room");

        //NHP Locations
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("utilization/TotalAnimals"), 0);

        //NHP Location filters
        filter.addCondition(FieldKey.fromString("housingType/value"), "Rodent Location", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("housingType/value"), "Off Campus", CompareType.NEQ_OR_NULL);
        filter.addCondition(FieldKey.fromString("datedisabled"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("building"), null, CompareType.NONBLANK);
        Sort sort = new Sort("building,room");

        //NHP unoccupied locations
        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("room", "building", "room_sortValue"), filter, sort);
        if (ts.getRowCount() == 0)
        {
            msg.append("There are no empty NHP rooms");
        }
        else
        {
            msg.append("<b>Unoccupied NHP Locations:</b><br>\n");
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

    private void unoccupiedSLARooms(Container c, User u, final StringBuilder msg)
    {
         /*****************************
         //SLA Unoccupied Locations//
         ******************************/
        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("SLAOccupiedLocations");

        //SLA Locations
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Cage_Count"),null, CompareType.ISBLANK);

        //SLA Location filters
        filter.addCondition(FieldKey.fromString("building"), null, CompareType.NONBLANK);

        //SLA unoccupied locations
        Set<FieldKey> columns = new HashSet<>();
        columns.add(FieldKey.fromString("room"));
        columns.add(FieldKey.fromString("building"));
        columns.add(FieldKey.fromString("Date"));
        columns.add(FieldKey.fromString("Animal_Count"));
        columns.add(FieldKey.fromString("Cage_Count"));

        final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, columns);
        TableSelector ts = new TableSelector(ti, colMap.values(), filter, new Sort("building,room"));

        String url = getExecuteQueryUrl(c, "sla", "SLAOccupiedLocations", null) ;
        long total = ts.getRowCount();

        if (total == 0)
        {
            msg.append("There are no empty SLA rooms");
        }
        else
        {
            msg.append("<br><br><br><b>Unoccupied SLA Locations:</b><br><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'>");
            msg.append("<tr style='font-weight: bold;'><td>Building</td><td>Room</td></tr>");

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, colMap);
                    msg.append("<tr>");
                    msg.append("<td>" + (rs.getString("building") == null ? PageFlowUtil.filter("") : PageFlowUtil.filter(rs.getString("building"))) + "</td>");
                    msg.append("<td>" + PageFlowUtil.filter(rs.getString("room")) + "</td>");
                    msg.append("</tr>");
                }
            });

            msg.append("</table>");


        }
    }
}
