package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.security.User;
import org.labkey.onprc_ehr.etl.ETLRunnable;

import java.io.IOException;
import java.util.Date;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 3/26/13
 * Time: 7:36 AM
 */
public class ETLNotification extends AbstractEHRNotification
{
    @Override
    public String getName()
    {
        return "ETL Validation Notification";
    }

    @Override
    public String getEmailSubject()
    {
        return "ETL Validation: " + _dateTimeFormat.format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 4 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 4:00AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a nightly validation of the ETL sync.  It will provide a list of any records missing from PRIMe or that need to be deleted";
    }

    public String getMessage(Container c, User u)
    {
        StringBuilder sb = new StringBuilder();
        try
        {
            ETLRunnable runnable = new ETLRunnable();
            String msg = runnable.validateEtlSync(false);
            if (msg != null)
                sb.append(msg);
        }
        catch (Exception e)
        {
            sb.append(e.getMessage());
        }
        return sb.toString();
    }
}
