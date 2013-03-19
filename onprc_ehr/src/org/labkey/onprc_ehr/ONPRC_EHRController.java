/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
import org.labkey.api.action.ConfirmAction;
import org.labkey.api.action.ExportAction;
import org.labkey.api.action.RedirectAction;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ldk.NavItem;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.AdminConsoleAction;
import org.labkey.api.security.RequiresPermissionClass;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HtmlView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.UnauthorizedException;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLRunnable;
import org.labkey.onprc_ehr.legacydata.LegacyDataManager;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

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
            resp.getProperties().put("scheduled", ETL.isScheduled());
            resp.getProperties().put("nextSync", ETL.nextSync());

            String[] etlConfigKeys = {"labkeyUser", "labkeyContainer", "jdbcUrl", "jdbcDriver", "runIntervalInMinutes"};

            resp.getProperties().put("configKeys", etlConfigKeys);
            resp.getProperties().put("config", PropertyManager.getProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN));
            resp.getProperties().put("rowversions", PropertyManager.getProperties(ETLRunnable.ROWVERSION_PROPERTY_DOMAIN));
            Map<String, String> map = PropertyManager.getProperties(ETLRunnable.TIMESTAMP_PROPERTY_DOMAIN);
            Map<String, Date> timestamps = new TreeMap<String, Date>();
            for (String key : map.keySet())
            {
                timestamps.put(key, new Date(Long.parseLong(map.get(key))));
            }
            resp.getProperties().put("timestamps", timestamps);

            return resp;
        }
    }

    @RequiresPermissionClass(ReadPermission.class)
    public class GetNavItemsAction extends ApiAction<Object>
    {
        public ApiResponse execute(Object form, BindException errors)
        {
            ApiResponse resp = new ApiSimpleResponse();

            //first add labs
            List<JSONObject> labs = new ArrayList<JSONObject>();
            Container labContainer = ContainerManager.getForPath("/ONPRC/Labs");
            if (labContainer != null)
            {
                for (Container c : labContainer.getChildren())
                {
                    JSONObject json = new JSONObject();
                    json.put("name", c.getName());
                    json.put("path", c.getPath());
                    json.put("url", c.getStartURL(getUser()));
                    json.put("canRead", c.hasPermission(getUser(), ReadPermission.class));
                    labs.add(json);
                }
            }
            resp.getProperties().put("labs", labs);

            //then admin
            List<JSONObject> admin = new ArrayList<JSONObject>();
            Container adminContainer = ContainerManager.getForPath("/ONPRC/Admin");
            if (adminContainer != null)
            {
                for (Container c : adminContainer.getChildren())
                {
                    JSONObject json = new JSONObject();
                    json.put("name", c.getName());
                    json.put("path", c.getPath());
                    json.put("url", c.getStartURL(getUser()));
                    json.put("canRead", c.hasPermission(getUser(), ReadPermission.class));
                    admin.add(json);
                }
            }
            resp.getProperties().put("admin", admin);

            //then cores
            List<JSONObject> cores = new ArrayList<JSONObject>();
            Container coresContainer = ContainerManager.getForPath("/ONPRC/Core Facilities");
            if (coresContainer != null)
            {
                for (Container c : coresContainer.getChildren())
                {
                    JSONObject json = new JSONObject();
                    json.put("name", c.getName());
                    json.put("path", c.getPath());
                    json.put("url", c.getStartURL(getUser()));
                    json.put("canRead", c.hasPermission(getUser(), ReadPermission.class));
                    cores.add(json);
                }
            }
            resp.getProperties().put("cores", cores);

            //for now, EHR is hard coded
            List<JSONObject> ehr = new ArrayList<JSONObject>();
            Container ehrContainer = ContainerManager.getForPath("/ONPRC/EHR");

            JSONObject json = new JSONObject();
            json.put("name", "Main Page");
            json.put("path", ehrContainer.getPath());
            json.put("url", ehrContainer.getStartURL(getUser()).toString());
            json.put("canRead", ehrContainer.hasPermission(getUser(), ReadPermission.class));
            ehr.add(json);

            json = new JSONObject();
            json.put("name", "Animal History");
            json.put("path", ehrContainer.getPath());
            json.put("url", new ActionURL("ehr", "animalHistory", ehrContainer).toString());
            json.put("canRead", ehrContainer.hasPermission(getUser(), ReadPermission.class));
            ehr.add(json);

            json = new JSONObject();
            json.put("name", "Animal Search");
            json.put("path", ehrContainer.getPath());
            json.put("url", new ActionURL("ehr", "animalSearch", ehrContainer).toString());
            json.put("canRead", ehrContainer.hasPermission(getUser(), ReadPermission.class));
            ehr.add(json);

            resp.getProperties().put("ehr", ehr);

            resp.getProperties().put("success", true);

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

            boolean shouldReschedule = false;
            if (form.getLabkeyUser() != null)
                configMap.put("labkeyUser", form.getLabkeyUser());

            if (form.getLabkeyContainer() != null)
                configMap.put("labkeyContainer", form.getLabkeyContainer());

            if (form.getJdbcUrl() != null)
                configMap.put("jdbcUrl", form.getJdbcUrl());

            if (form.getJdbcDriver() != null)
                configMap.put("jdbcDriver", form.getJdbcDriver());

            if (form.getRunIntervalInMinutes() != null)
            {
                String oldValue = configMap.get("runIntervalInMinutes");
                if (!form.getRunIntervalInMinutes().equals(oldValue))
                    shouldReschedule = true;

                configMap.put("runIntervalInMinutes", form.getRunIntervalInMinutes());
            }

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

            //if config was changed and the ETL is current scheduled to run, we need to restart it
            if (form.getEtlStatus() && shouldReschedule)
            {
                ETL.stop();
                ETL.start(0);
            }
            else
            {
                if (form.getEtlStatus())
                    ETL.start(0);
                else
                    ETL.stop();
            }

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
        private String runIntervalInMinutes;

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

        public String getRunIntervalInMinutes()
        {
            return runIntervalInMinutes;
        }

        public void setRunIntervalInMinutes(String runIntervalInMinutes)
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
    public class RunEHRTestsAction extends SimpleViewAction<RunEHRTestsForm>
    {
        public void validateCommand(RunEHRTestsForm form, Errors errors)
        {

        }

        public URLHelper getSuccessURL(RunEHRTestsForm form)
        {
            return getContainer().getStartURL(getUser());
        }

        public ModelAndView getView(RunEHRTestsForm form, BindException errors) throws Exception
        {
            StringBuilder msg = new StringBuilder();

            ONPRC_EHRTestHelper helper = new ONPRC_EHRTestHelper();
            Method method = helper.getClass().getMethod("testBloodCalculation", Container.class, User.class);
            method.invoke(helper, getContainer(), getUser());



//            List<String> messages = EHRManager.get().verifyDatasetResources(getContainer(),  getUser());
//            for (String message : messages)
//            {
//                msg.append("\t").append(message).append("<br>");
//            }
//
//            if (messages.size() == 0)
//                msg.append("There are no missing files");

            return new HtmlView(msg.toString());
        }

        public NavTree appendNavTrail(NavTree tree)
        {
            return tree.addChild("ONPRC EHR Tests");

        }
    }

    public static class RunEHRTestsForm
    {
        String[] _tests;

        public String[] getTests()
        {
            return _tests;
        }

        public void setTests(String[] tests)
        {
            _tests = tests;
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

    @RequiresPermissionClass(AdminPermission.class)
    public class ValidateEtlAction extends ConfirmAction<ValidateEtlSyncForm>
    {
        public boolean handlePost(ValidateEtlSyncForm form, BindException errors) throws Exception
        {
            if (!getUser().isAdministrator())
            {
                throw new UnauthorizedException("Only site admins can view this page");
            }

            ETLRunnable runnable = new ETLRunnable();
            runnable.validateEtlSync(form.isAttemptRepair());
            return true;
        }

        public ModelAndView getConfirmView(ValidateEtlSyncForm form, BindException errors) throws Exception
        {
            if (!getUser().isAdministrator())
            {
                throw new UnauthorizedException("Only site admins can view this page");
            }

            StringBuilder sb = new StringBuilder();
            sb.append("The following text describes the results of comparing the EHR study with the MSSQL records from the production instance on the same server as this DB instance.  Clicking OK will cause the system to attempt to repair any differences.  Please do this very carefully<br>");
            sb.append("<br><br>");

            ETLRunnable runnable = new ETLRunnable();
            String msg = runnable.validateEtlSync(false);
            sb.append(msg);

            return new HtmlView(sb.toString());
        }

        public void validateCommand(ValidateEtlSyncForm form, Errors errors)
        {

        }

        public ActionURL getSuccessURL(ValidateEtlSyncForm form)
        {
            return getContainer().getStartURL(getUser());
        }
    }

    public static class ValidateEtlSyncForm
    {
        private boolean _attemptRepair = false;

        public boolean isAttemptRepair()
        {
            return _attemptRepair;
        }

        public void setAttemptRepair(boolean attemptRepair)
        {
            _attemptRepair = attemptRepair;
        }
    }

    @RequiresPermissionClass(AdminPermission.class)
    public class LegacyDataImportAction extends ConfirmAction<LegacyDataImportForm>
    {
        public void validateCommand(LegacyDataImportForm form, Errors errors)
        {

        }

        @Override
        public ModelAndView getConfirmView(LegacyDataImportForm form, BindException errors) throws Exception
        {
            StringBuilder sb = new StringBuilder();
            if (form.getTypes() == null || form.getTypes().length == 0)
            {
                errors.reject(ERROR_MSG, "No import types provided");
                return new HtmlView("No import types provided");
            }

            List<String> types = new ArrayList<String>();
            types.addAll(Arrays.asList(form.getTypes()));

            sb.append("This action is highly experimental and should be used at your own risk.  It is designed to bulk upload existing folders into workbooks. <br><br>");

            if (types.contains("expt"))
                sb.append(LegacyDataManager.getInstance().importSachaExperiments(getUser(), getContainer(), true)).append("<hr>");

            if (types.contains("peptides"))
                sb.append(LegacyDataManager.getInstance().importSachaPeptides(getUser(), getContainer(), true)).append("<hr>");

            if (types.contains("elispot"))
                sb.append(LegacyDataManager.getInstance().importElispotResults(getViewContext(), true)).append("<hr>");

            sb.append("<br>Do you want to continue?");

            return new HtmlView(sb.toString());
        }

        public boolean handlePost(LegacyDataImportForm form, BindException errors) throws Exception
        {
            if (form.getTypes() == null || form.getTypes().length == 0)
            {
                errors.reject(ERROR_MSG, "No import types provided");
                return false;
            }

            List<String> types = new ArrayList<String>();
            types.addAll(Arrays.asList(form.getTypes()));

            if (types.contains("expt"))
                LegacyDataManager.getInstance().importSachaExperiments(getUser(), getContainer(), false);

            if (types.contains("peptides"))
                LegacyDataManager.getInstance().importSachaPeptides(getUser(), getContainer(), false);

            if (types.contains("elispot"))
                LegacyDataManager.getInstance().importElispotResults(getViewContext(), false);

            return true;
        }

        public URLHelper getSuccessURL(LegacyDataImportForm form)
        {
            return getContainer().getStartURL(getUser());
        }
    }

    public static class LegacyDataImportForm
    {
        private String[] _types;

        public String[] getTypes()
        {
            return _types;
        }

        public void setTypes(String[] types)
        {
            _types = types;
        }
    }
}