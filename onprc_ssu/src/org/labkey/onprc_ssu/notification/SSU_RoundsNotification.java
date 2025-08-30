package org.labkey.onprc_ssu.notification;

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
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ldk.notification.AbstractNotification;
import org.labkey.api.module.Module;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ssu.ONPRC_SSUSchema;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by: Kollil
 * Date: 8/23/24
 */
public class SSU_RoundsNotification extends AbstractNotification
{
    public SSU_RoundsNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Surgery Rounds Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Surgery Rounds Notification: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 13 * * ?";
    }

    @Override
    public String getCategory()
    {
        return "SSU";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 1pm";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a summary of surgeries performed today and alert for any surgeries missing the post-op meds.";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();
        //Find today's date
        Date now = new Date();

        msg.append("This email contains any surgery rounds not marked as completed.  It was run on: " + getDateFormat(c).format(now) + " at " + _timeFormat.format(now) + "<br><br>");

        Container ehrContainer = EHRService.get().getEHRStudyContainer(c);
        if (ehrContainer != null && ehrContainer.hasPermission(u, ReadPermission.class))
        {
            animalsWithoutRoundsToday(ehrContainer, u, msg);
        }
        return msg.toString();
    }

    private String safeAppend(Results rs, String fieldKey, String emptyText) throws SQLException
    {
        String ret = rs.getString(FieldKey.fromString(fieldKey));
        return ret == null ? emptyText : ret;
    }

    protected String getParticipantURL(Container c, String id)
    {
        return AppProps.getInstance().getBaseServerUrl() + AppProps.getInstance().getContextPath() + "/ehr" + c.getPath() + "/participantView.view?participantId=" + id;
    }

    protected void animalsWithoutRoundsToday(final Container ehrContainer, User u, final StringBuilder msg)
    {
        //Get observed count
        SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("daysSinceLastRounds"), 0, CompareType.EQUAL);
        filter2.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter2.addCondition(FieldKey.fromString("category"), "Surgery", CompareType.EQUAL);
        filter2.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive", CompareType.EQUAL);

        TableInfo ti2 = QueryService.get().getUserSchema(u, ehrContainer, "study").getTable("cases");
        Set<FieldKey> keys2 = new HashSet<>();
        keys2.add(FieldKey.fromString("Id"));
        keys2.add(FieldKey.fromString("Id/curLocation/room"));
        keys2.add(FieldKey.fromString("Id/curLocation/cage"));
        keys2.add(FieldKey.fromString("daysSinceLastRounds"));
        keys2.add(FieldKey.fromString("date"));
        keys2.add(FieldKey.fromString("remark"));

        final Map<FieldKey, ColumnInfo> cols2 = QueryService.get().getColumns(ti2, keys2);

        TableSelector ts2 = new TableSelector(ti2, cols2.values(), filter2, new Sort("Id/curLocation/room_sortValue,Id/curLocation/cage_sortValue"));
        long observed_count = ts2.getRowCount();

        //Get total count
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysSinceLastRounds"), 0, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("category"), "Surgery", CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id/demographics/calculated_status"), "Alive", CompareType.EQUAL);

        TableInfo ti = QueryService.get().getUserSchema(u, ehrContainer, "study").getTable("cases");
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("Id/curLocation/room"));
        keys.add(FieldKey.fromString("Id/curLocation/cage"));
        keys.add(FieldKey.fromString("daysSinceLastRounds"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("remark"));

        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, keys);

        TableSelector ts = new TableSelector(ti, cols.values(), filter, new Sort("Id/curLocation/room_sortValue,Id/curLocation/cage_sortValue"));
        long total_count = ts.getRowCount();

        if (observed_count <= total_count)
        {
            msg.append("<b>Rounds: " + observed_count + " of " + total_count + " active surgical cases that have obs entered today.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(ehrContainer, "study", "cases", "Surgeries", filter) + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }
        if (total_count == 0)
        {
            msg.append("<b>Rounds: " + observed_count + " of " + observed_count + " active surgical cases that have obs entered today.</b><br>");
            msg.append("<p><a href='" + getExecuteQueryUrl(ehrContainer, "study", "cases", "Surgeries", filter) + "'>Click here to view them</a><br>\n");
            msg.append("<hr>\n");
        }

        msg.append("<table border=1 style='border-collapse: collapse;'>");
        msg.append("<tr style='font-weight: bold;'><td>Id</td><td>Room</td><td>Cage</td><td>Date Opened</td><td>Description</td><td>Days Since Last Rounds</td></tr>");
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            public void exec(ResultSet object) throws SQLException
            {
                Results rs = new ResultsImpl(object, cols);
                String url = getParticipantURL(ehrContainer, rs.getString("Id"));
                //Get the status
                int status = rs.getInt("daysSinceLastRounds");
                //If not "completed", highlight the record with yellow color
                if (status > 0) {
                    msg.append("<tr bgcolor = " + '"' + "#FFFF00" + '"' + ">");
                }
                msg.append("<td> <a href='" + url + "'>" + rs.getString(FieldKey.fromString("Id")) + "</td>");
                msg.append("<td>" + safeAppend(rs, "Id/curLocation/room", "None") + "</td>");
                msg.append("<td>" + safeAppend(rs, "Id/curLocation/cage", "") + "</td>");
                msg.append("<td>" + safeAppend(rs, "date", "") + "</td>");
                msg.append("<td>" + safeAppend(rs, "remark", "") + "</td>");
                msg.append("<td>" + safeAppend(rs, "daysSinceLastRounds", "") + "</td>");
                msg.append("</tr>");
            }
        });
        msg.append("</table>");
        msg.append("<hr>\n");
    }
}