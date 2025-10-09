package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;

import java.util.Calendar;
import java.util.Date;


public class AvailableBloodVolumeNotification extends ColonyAlertsNotification
{
    public AvailableBloodVolumeNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Available Blood Volume Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Available Blood Volume Alert: " + getDateTimeFormat(c).format(new Date());
    }

    /* Mathematica push:
     * Server mkt7: Runs at :55 from 4:55am to 7:55pm
     * Server mkt8: Runs at :25 from 4:25am to 7:25pm
     *
     * ABV ETL:
     * :01 and :31 after the hour for hours between 05:00 and 20:00
     * 0 1,31 5-20 ? * * *
     */
    @Override
    public String getCronString()
    {
        return "0 15 6-19 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "15 min past every hour from 06:15 to 19:15.";
    }

    @Override
    public String getDescription()
    {
        return "Sends status of available blood volume data from Mathematica.";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();
        availableBloodCheck(c, u, msg);
        return msg.toString();
    }

    protected void availableBloodCheck(final Container c, User u, final StringBuilder msg)
    {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.HOUR, -1);
        Date staleTime = cal.getTime();

        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_ehr").getTable("AvailableBloodVolume", ContainerFilter.Type.AllFolders.create(c, u));

        if (ti == null)
        {
            msg.append("<b>ERROR: Unable to access onprc_ehr.AvailableBloodVolume table.</b><br>\n");
            return;
        }

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("datecreated"), staleTime, CompareType.LTE);
        TableSelector ts = new TableSelector(ti, filter, null);
        long count = ts.getRowCount();

        if (count > 0)
        {
            msg.append("<b>WARNING: The available blood volume data from Mathematica is stale (last updated more than 1 hour ago).</b><br>\n");
            msg.append("<p>View <a href='").append(getExecuteQueryUrl(c, "onprc_ehr", "AvailableBloodVolume", null)).append("'>onprc_ehr.AvailableBloodVolume</a>.</p>\n");
            msg.append("<br>");
        }
        else
        {
            msg.append("<b>OK:</b> The available blood volume data from Mathematica is current (updated within the last hour).<br>\n");
            msg.append("<p>View <a href='").append(getExecuteQueryUrl(c, "onprc_ehr", "AvailableBloodVolume", null)).append("'>onprc_ehr.AvailableBloodVolume</a>.</p>\n");
            msg.append("<br>");
        }
    }
}