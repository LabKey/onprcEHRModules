/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;
import org.labkey.onprc_ehr.etl.ETLRunnable;

import java.util.Date;

/**
 * User: bimber
 * Date: 3/26/13
 * Time: 7:36 AM
 */
public class ETLNotification extends AbstractEHRNotification
{
    public ETLNotification(Module owner)
    {
        super(owner);
    }

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

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder sb = new StringBuilder();
        try
        {
            ETLRunnable runnable = new ETLRunnable();
            Container etlContainer = runnable.getContainer();
            if (!c.equals(etlContainer))
            {
                sb.append("This alert can only be run from the same container as the ETL: " + etlContainer.getPath());
            }

            String msg = runnable.validateEtlSync(false);
            if (msg != null)
                sb.append(msg);
            else
                sb.append("No ETL problems found");
        }
        catch (ETLRunnable.BadConfigException e)
        {
            sb.append(e.getMessage());
        }
        catch (Exception e)
        {
            sb.append(e.getMessage());
        }
        return sb.toString();
    }
}
