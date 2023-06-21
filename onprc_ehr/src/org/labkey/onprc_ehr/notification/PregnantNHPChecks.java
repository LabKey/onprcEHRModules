package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created by kollil,
 * March, 2023
 */
public class PregnantNHPChecks extends ColonyAlertsNotification
{
    public PregnantNHPChecks(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Pregnant checks and gestation alerts";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Monkeys needing pregnancy checks: " + getDateTimeFormat(c).format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 30 5 ? * THU";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every Thursday at 5:30Am";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a list of monkeys needing pregnancy checks once a week!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        pregnancyChecks(c, u, msg);

        checkPregnantGestation(c, u, msg);

        return msg.toString();
    }
}
