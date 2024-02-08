package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by Lakshmi Kolli
 */
public class PregnantNHPsGestationAlert extends ColonyAlertsNotification
{
    public PregnantNHPsGestationAlert(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Pregnant NHPs Gestation Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Pregnant Animal Alerts: " + getDateTimeFormat(c).format(new Date());
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
        return "The report is designed to provide a daily summary of pregnant NHPs past 30 days of gestation for the colony!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        checkPregnantGestation(c, u, msg);

        return msg.toString();
    }
}




