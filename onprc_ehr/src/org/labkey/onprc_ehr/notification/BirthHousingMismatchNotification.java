package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

// Created: 8-7-2018   R.Blasa
public class BirthHousingMismatchNotification extends ColonyAlertsNotification
{
    public  BirthHousingMismatchNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Birth Initial Housing Locations Discrepancies Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Discrepancies between Birth and Initial Housing Locations Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 6 * * ?";
    }


    @Override
    public String getScheduleDescription()
    {
        return "every day at 6:00AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a daily summary of discrepancies between Birth and Initial Housing Locations.";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        ValidateBiirthHousingHistory(c, u, msg);

        return msg.toString();
    }
}




