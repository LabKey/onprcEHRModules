package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by kollil on 10/24/2019.
 */

public class PMICSchedulerNotification extends ColonyAlertsNotification
{
    public PMICSchedulerNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "PMIC Scheduler Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "PMIC Scheduler Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 5 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 5:00AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to send PMIC scheduler alerts daily!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        pmicSchedulerAlert(c, u, msg);

        return msg.toString();
    }
}