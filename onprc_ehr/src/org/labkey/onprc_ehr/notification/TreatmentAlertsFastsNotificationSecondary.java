package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by kollil on 11/1/2021
 */

public class TreatmentAlertsFastsNotificationSecondary extends ColonyAlertsNotification
{
    public TreatmentAlertsFastsNotificationSecondary(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Fasts Treatment Alert Secondary";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Fasts treatment Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 7 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 7Am";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to send Fast treatments alerts daily!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        //Find today's date
        //Date now = new Date();
        //msg.append("This email contains any fast treatments not marked as completed.  It was run on: " + getDateFormat(c).format(now) + " at " + _timeFormat.format(now) + ".<p>");

        processFastsTreatments(c, u, msg);

        return msg.toString();
    }


}