/*
 * Copyright (c) 2012 LabKey Corporation
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
package org.labkey.onprc_ehr.etl;

import org.apache.log4j.Logger;
import org.labkey.api.data.PropertyManager;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

import java.io.IOException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Created by IntelliJ IDEA.
 * User: newton
 * Date: Oct 26, 2010
 * Time: 10:07:34 AM
 */
public class ETL
{
    private final static Logger log = Logger.getLogger(ONPRC_EHRModule.class);
    private static ScheduledExecutorService executor;
    private static ETLRunnable runnable;
    private static boolean isRunning = false;
    public static final String ENABLED_PROP_NAME = "etlStatus";

    static public synchronized void init(int delay)
    {
        if (isEnabled())
            start(delay);
    }

    static public synchronized void start(int delay)
    {
        if (!isRunning)
        {
            executor = Executors.newSingleThreadScheduledExecutor();

            try
            {
                runnable = new ETLRunnable();
                int interval = runnable.getRunIntervalInMinutes();
                if (interval != 0)
                {
                    log.info("Scheduling db sync at " + interval + " minute interval.");
                    executor.scheduleWithFixedDelay(runnable, delay, interval, TimeUnit.MINUTES);
                    setEnabled(true);
                    isRunning = true;
                }
            }
            catch (Exception e)
            {
                log.error("Could not start incremental db sync", e);
            }
        }
        else
        {
            log.info("ETL is already running");
        }
    }

    static public synchronized void stop()
    {
        if (isRunning)
        {
            log.info("Stopping ETL");
            executor.shutdownNow();
            runnable.shutdown();
            setEnabled(false);
            isRunning = false;
        }
    }

    /**
     * This allows an admin to manually kick off one ETL sync.  It is primarily used for development
     * and not recommended on production servers
     */
    static public void run()
    {
        if (isEnabled())
        {
            if (runnable == null)
            {
                try
                {
                   runnable = new ETLRunnable();
                }
                catch (IOException e)
                {
                    log.error("Error running ETL: " + e.getMessage());
                }
            }

            if (runnable != null)
                runnable.run();

        }
        else
            log.error("ETL is either disabled to inactive.  Will not start");
    }

    public static boolean isEnabled()
    {
        String prop = PropertyManager.getProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN).get(ENABLED_PROP_NAME);
        if (prop == null)
            return false;

        Boolean value = Boolean.parseBoolean(prop);
        if (value == null)
        {
            return false;
        }

        return value;
    }

    public static boolean isRunning()
    {
        if (runnable == null)
            return false;

        return runnable.isRunning();
    }

    private static void setEnabled(Boolean enabled)
    {
        PropertyManager.PropertyMap pm = PropertyManager.getWritableProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN, true);
        pm.put(ENABLED_PROP_NAME, enabled.toString());
        PropertyManager.saveProperties(pm);
    }
}
