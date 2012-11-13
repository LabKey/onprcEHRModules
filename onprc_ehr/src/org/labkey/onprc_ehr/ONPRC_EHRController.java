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
package org.labkey.onprc_ehr;

import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.ExportAction;
import org.labkey.api.action.RedirectAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.AdminConsoleAction;
import org.labkey.api.security.RequiresPermissionClass;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.ActionURL;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLRunnable;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:56 PM
 */
public class ONPRC_EHRController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(ONPRC_EHRController.class);

    public ONPRC_EHRController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermissionClass(AdminPermission.class)
    public class GetEtlDetailsAction extends ApiAction<Object>
    {
        public ApiResponse execute(Object form, BindException errors)
        {
            ApiResponse resp = new ApiSimpleResponse();
            resp.getProperties().put("enabled", ETL.isEnabled());
            resp.getProperties().put("active", ETL.isRunning());

            //"etlStatus",
            String[] etlConfigKeys = {"labkeyUser", "labkeyContainer", "jdbcUrl", "jdbcDriver", "runIntervalInMinutes"};

            resp.getProperties().put("configKeys", etlConfigKeys);
            resp.getProperties().put("config", PropertyManager.getProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN));
            resp.getProperties().put("rowversions", PropertyManager.getProperties(ETLRunnable.ROWVERSION_PROPERTY_DOMAIN));
            Map<String, String> map = PropertyManager.getProperties(ETLRunnable.TIMESTAMP_PROPERTY_DOMAIN);
            Map<String, Date> timestamps = new HashMap<String, Date>();
            for (String key : map.keySet())
            {
                timestamps.put(key, new Date(Long.parseLong(map.get(key))));
            }
            resp.getProperties().put("timestamps", timestamps);

            return resp;
        }
    }

    @RequiresPermissionClass(AdminPermission.class)
    public class SetEtlDetailsAction extends ApiAction<EtlAdminForm>
    {
        public ApiResponse execute(EtlAdminForm form, BindException errors)
        {
            ApiResponse resp = new ApiSimpleResponse();

            PropertyManager.PropertyMap configMap = PropertyManager.getWritableProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN, true);

            if (form.getLabkeyUser() != null)
                configMap.put("labkeyUser", form.getLabkeyUser());

            if (form.getLabkeyContainer() != null)
                configMap.put("labkeyContainer", form.getLabkeyContainer());

            if (form.getJdbcUrl() != null)
                configMap.put("jdbcUrl", form.getJdbcUrl());

            if (form.getJdbcDriver() != null)
                configMap.put("jdbcDriver", form.getJdbcDriver());

            if (form.getRunIntervalInMinutes() != null)
                configMap.put("runIntervalInMinutes", form.getRunIntervalInMinutes().toString());

            if (form.getEtlStatus() != null)
                configMap.put("etlStatus", form.getEtlStatus().toString());

            PropertyManager.saveProperties(configMap);

            PropertyManager.PropertyMap rowVersionMap = PropertyManager.getWritableProperties(ETLRunnable.ROWVERSION_PROPERTY_DOMAIN, true);
            PropertyManager.PropertyMap timestampMap = PropertyManager.getWritableProperties(ETLRunnable.TIMESTAMP_PROPERTY_DOMAIN, true);

            if (form.getTimestamps() != null)
            {
                JSONObject json = new JSONObject(form.getTimestamps());
                for (String key : rowVersionMap.keySet())
                {
                    if (json.get(key) != null)
                    {
                        //this key corresponds to the rowId of the row in the etl_runs table
                        Integer value = json.getInt(key);
                        if (value == -1)
                        {
                            rowVersionMap.put(key, null);
                            timestampMap.put(key, null);
                        }
                        else
                        {
                            TableInfo ti = ONPRC_EHRSchema.getInstance().getSchema().getTable(ONPRC_EHRSchema.TABLE_ETL_RUNS);
                            TableSelector ts = new TableSelector(ti, Table.ALL_COLUMNS, new SimpleFilter(FieldKey.fromString("rowid"), value), null);
                            Map<String, Object>[] rows = ts.getArray(Map.class);
                            if (rows.length != 1)
                                continue;

                            rowVersionMap.put(key, (String)rows[0].get("rowversion"));
                            Long date = ((Date)rows[0].get("date")).getTime();
                            timestampMap.put(key, date.toString());
                        }
                    }
                }
                PropertyManager.saveProperties(rowVersionMap);
                PropertyManager.saveProperties(timestampMap);
            }

            if (form.getEtlStatus() && !ETL.isEnabled())
            {
                ETL.start(100);
            }
            else if (!form.getEtlStatus() && ETL.isEnabled())
                ETL.stop();

            resp.getProperties().put("success", true);

            return resp;
        }
    }

    public static class EtlAdminForm
    {
        private Boolean etlStatus;
        private String config;
        private String timestamps;
        private String labkeyUser;
        private String labkeyContainer;
        private String jdbcUrl;
        private String jdbcDriver;
        private Integer runIntervalInMinutes;

        public Boolean getEtlStatus()
        {
            return etlStatus;
        }

        public void setEtlStatus(Boolean etlStatus)
        {
            this.etlStatus = etlStatus;
        }

        public String getConfig()
        {
            return config;
        }

        public void setConfig(String config)
        {
            this.config = config;
        }

        public String getTimestamps()
        {
            return timestamps;
        }

        public void setTimestamps(String timestamps)
        {
            this.timestamps = timestamps;
        }

        public String getLabkeyUser()
        {
            return labkeyUser;
        }

        public void setLabkeyUser(String labkeyUser)
        {
            this.labkeyUser = labkeyUser;
        }

        public String getLabkeyContainer()
        {
            return labkeyContainer;
        }

        public void setLabkeyContainer(String labkeyContainer)
        {
            this.labkeyContainer = labkeyContainer;
        }

        public String getJdbcUrl()
        {
            return jdbcUrl;
        }

        public void setJdbcUrl(String jdbcUrl)
        {
            this.jdbcUrl = jdbcUrl;
        }

        public String getJdbcDriver()
        {
            return jdbcDriver;
        }

        public void setJdbcDriver(String jdbcDriver)
        {
            this.jdbcDriver = jdbcDriver;
        }

        public Integer getRunIntervalInMinutes()
        {
            return runIntervalInMinutes;
        }

        public void setRunIntervalInMinutes(int runIntervalInMinutes)
        {
            this.runIntervalInMinutes = runIntervalInMinutes;
        }
    }

    @AdminConsoleAction
    public class ShowEtlErrorsAction extends ExportAction
    {
        public void export(Object o, HttpServletResponse response, BindException errors) throws Exception
        {
            showLogFile(response, 0, getLogFile("ehr-etl-errors.log"));
        }
    }

    @AdminConsoleAction
    public class ShowEtlLogAction extends ExportAction
    {
        public void export(Object o, HttpServletResponse response, BindException errors) throws Exception
        {
            showLogFile(response, 0, getLogFile("ehr-etl.log"));
        }
    }

    private File getLogFile(String name)
    {
        File tomcatHome = new File(System.getProperty("catalina.home"));
        return new File(tomcatHome, "logs/" + name);
    }

    public void showLogFile(HttpServletResponse response, long startingOffset, File logFile) throws Exception
    {
        if (logFile.exists())
        {
            FileInputStream fIn = null;
            try
            {
                fIn = new FileInputStream(logFile);
                //noinspection ResultOfMethodCallIgnored
                fIn.skip(startingOffset);
                OutputStream out = response.getOutputStream();
                response.setContentType("text/plain");
                byte[] b = new byte[4096];
                int i;
                while ((i = fIn.read(b)) != -1)
                {
                    out.write(b, 0, i);
                }
            }
            finally
            {
                if (fIn != null)
                {
                    fIn.close();
                }
            }
        }
    }

    @RequiresPermissionClass(AdminPermission.class)
    public class RunEtlAction extends RedirectAction<Object>
    {
        public boolean doAction(Object form, BindException errors) throws Exception
        {
            ETL.run();
            return true;
        }

        public void validateCommand(Object form, Errors errors)
        {

        }

        public ActionURL getSuccessURL(Object form)
        {
            return DetailsURL.fromString(getContainer(), "/onprc_ehr/etlAdmin.view").getActionURL();
        }
    }
}
