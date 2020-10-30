package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by kollil on 5/12/2017.
 */

public class BSUNotesNotification extends ColonyAlertsNotification
{
    public BSUNotesNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "BSU Notes Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "BSU Notes Alerts: " + getDateTimeFormat(c).format(new Date());
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
        return "The report is designed to send BSU Notes alerts on the day indicated by the action date!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        bsuNotesAlert(c, u, msg);

        return msg.toString();
    }
}