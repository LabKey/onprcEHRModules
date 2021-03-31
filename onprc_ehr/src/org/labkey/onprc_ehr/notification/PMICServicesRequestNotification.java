package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.ehr.notification.AbstractEHRNotification;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by Kollil on 03/18/2021
 */

public class PMICServicesRequestNotification extends ColonyAlertsNotification
{
    public PMICServicesRequestNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "PMIC Services Request Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "PMIC Services Request Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 15 7 ? * THU";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every Thursday at 7:15Am";
    }

    @Override
    public String getDescription()
    {
        return "This runs every Thursday and sends alerts related to PMIC service requests!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();
        //msg.append("This email is designed to summarize pending or scheduled requests. It was run on: " + getDateFormat(c).format(now) + " at " + AbstractEHRNotification._timeFormat.format(now) + ".<p>");

        pmicServicesRequestAlert(c, u, msg);

        return msg.toString();
    }
}