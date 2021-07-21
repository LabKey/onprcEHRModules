package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by Kollil on 03/18/2021
 */

public class HousingTransferNotification extends ColonyAlertsNotification
{
    public HousingTransferNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Housing Transfers Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Housing Transfer Alerts: " + getDateTimeFormat(c).format(new Date());
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
        return "The report is designed to send housing transfer alerts daily!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        housingTransferAlert(c, u, msg);

        return msg.toString();
    }
}