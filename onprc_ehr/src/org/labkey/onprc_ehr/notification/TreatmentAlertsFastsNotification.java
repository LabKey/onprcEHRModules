package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by kollil on 11/1/2021
 */

public class TreatmentAlertsFastsNotification extends ColonyAlertsNotification
{
    public TreatmentAlertsFastsNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Fasts Treatment Alert";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Fasts treatment Alerts: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 30 16 ? * * *";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 4:30pm";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to send Fast treatments alerts daily at 4:30pm.";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        processFastsTreatments(c, u, msg);

        return msg.toString();
    }


}