/*
 * Copyright (c) 2012-2015 LabKey Corporation
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

import com.sun.javafx.collections.MappingChange;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
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
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.files.FileContentService;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.pipeline.PipelineStatusUrls;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.resource.FileResource;
import org.labkey.api.security.AdminConsoleAction;
import org.labkey.api.security.CSRF;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.RequiresSiteAdmin;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.services.ServiceRegistry;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.Path;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HtmlView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.UnauthorizedException;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLRunnable;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.lang.reflect.Method;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
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

    @RequiresPermission(AdminPermission.class)
    @CSRF
    public class GetEtlDetailsAction extends ApiAction<Object>
    {
        public ApiResponse execute(Object form, BindException errors)
        {
            Map<String, Object> resultProperties = new HashMap<>();
            resultProperties.put("enabled", ETL.isEnabled());
            resultProperties.put("active", ETL.isRunning());
            resultProperties.put("scheduled", ETL.isScheduled());
            resultProperties.put("nextSync", ETL.nextSync());
            resultProperties.put("cannotTruncate", ETLRunnable.CANNOT_TRUNCATE);

            String[] etlConfigKeys = {"labkeyUser", "labkeyContainer", "jdbcUrl", "jdbcDriver", "runIntervalInMinutes"};

            resultProperties.put("configKeys", etlConfigKeys);
            resultProperties.put("config", PropertyManager.getProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN));
            resultProperties.put("rowversions", PropertyManager.getProperties(ETLRunnable.ROWVERSION_PROPERTY_DOMAIN));
            Map<String, String> map = PropertyManager.getProperties(ETLRunnable.TIMESTAMP_PROPERTY_DOMAIN);
            Map<String, Date> timestamps = new TreeMap<>();
            for (String key : map.keySet())
            {
                timestamps.put(key, new Date(Long.parseLong(map.get(key))));
            }
            resultProperties.put("timestamps", timestamps);

            return new ApiSimpleResponse(resultProperties);
        }
    }

    @RequiresPermission(ReadPermission.class)
    @CSRF
    public class GetNavItemsAction extends ApiAction<Object>
    {
        public ApiResponse execute(Object form, BindException errors)
        {
            Map<String, Object> resultProperties = new HashMap<>();

            resultProperties.put("labs", getSection("/ONPRC/Labs"));
            resultProperties.put("admin", getSection("/ONPRC/Admin"));
            resultProperties.put("cores", getSection("/ONPRC/Core Facilities"));
            resultProperties.put("dcm", getSection("/ONPRC/DCM"));

            //Created: 12-7-2016 -- Update by jones ga to change target
            resultProperties.put("scheduler", getSection("/ONPRC/ResourceScheduler"));

            //Added 6-5-2016 Blasa
            resultProperties.put("sla", getSection("/ONPRC/SLA"));


            //for now, EHR is hard coded
            List<JSONObject> ehr = new ArrayList<>();
            Container ehrContainer = ContainerManager.getForPath("/ONPRC/EHR");
            if (ehrContainer != null)
            {
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
                json.put("name", "ONPRC Animal Search");
                json.put("path", ehrContainer.getPath());
                json.put("url", new ActionURL("ehr", "animalSearch", ehrContainer).toString());
                json.put("canRead", ehrContainer.hasPermission(getUser(), ReadPermission.class));
                ehr.add(json);

            }

            resultProperties.put("ehr", ehr);
            resultProperties.put("success", true);

            return new ApiSimpleResponse(resultProperties);
        }

        private List<JSONObject> getSection(String path)
        {
            List<JSONObject> ret = new ArrayList<>();
            Container mainContainer = ContainerManager.getForPath(path);
            if (mainContainer != null)
            {
                for (Container c : mainContainer.getChildren())
                {
                    JSONObject json = new JSONObject();
                    json.put("name", c.getName());
                    json.put("title", c.getTitle());
                    json.put("path", c.getPath());
                    json.put("url", c.getStartURL(getUser()));
                    json.put("canRead", c.hasPermission(getUser(), ReadPermission.class));
                    ret.add(json);

                    Container publicContainer = ContainerManager.getForPath(c.getPath() + "/Public");
                    if (publicContainer != null)
                    {
                        JSONObject childJson = new JSONObject();
                        childJson.put("name", publicContainer.getName());
                        childJson.put("title", publicContainer.getTitle());
                        childJson.put("path", publicContainer.getPath());
                        childJson.put("url", publicContainer.getStartURL(getUser()));
                        childJson.put("canRead", publicContainer.hasPermission(getUser(), ReadPermission.class));

                        json.put("publicContainer", childJson);
                    }
                }
            }

            return ret;
        }
    }

    @RequiresPermission(AdminPermission.class)
    @CSRF
    public class SetEtlDetailsAction extends ApiAction<EtlAdminForm>
    {
        public ApiResponse execute(EtlAdminForm form, BindException errors)
        {
            Map<String, Object> resultProperties = new HashMap<>();

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

            configMap.save();

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
                            TableSelector ts = new TableSelector(ti, new SimpleFilter(FieldKey.fromString("rowid"), value), null);
                            Map<String, Object>[] rows = ts.getMapArray();
                            if (rows.length != 1)
                                continue;

                            rowVersionMap.put(key, (String)rows[0].get("rowversion"));
                            Long date = ((Date)rows[0].get("date")).getTime();
                            timestampMap.put(key, date.toString());
                        }
                    }
                }
                rowVersionMap.save();
                timestampMap.save();
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

            resultProperties.put("success", true);

            return new ApiSimpleResponse(resultProperties);
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
    public class ShowEtlLogAction extends ExportAction
    {
        public void export(Object o, HttpServletResponse response, BindException errors) throws Exception
        {
            PageFlowUtil.streamLogFile(response, 0, getLogFile("ehr-etl.log"));
        }
    }

    private File getLogFile(String name)
    {
        File tomcatHome = new File(System.getProperty("catalina.home"));
        return new File(tomcatHome, "logs/" + name);
    }

    @RequiresPermission(AdminPermission.class)
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

    @RequiresPermission(AdminPermission.class)
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
            return DetailsURL.fromString("/onprc_ehr/etlAdmin.view", getContainer()).getActionURL();
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class ValidateEtlAction extends ConfirmAction<ValidateEtlSyncForm>
    {
        public boolean handlePost(ValidateEtlSyncForm form, BindException errors) throws Exception
        {
            if (!getUser().isSiteAdmin())
            {
                throw new UnauthorizedException("Only site admins can view this page");
            }

            ETLRunnable runnable = new ETLRunnable();
            runnable.validateEtlSync(form.isAttemptRepair());
            return true;
        }

        public ModelAndView getConfirmView(ValidateEtlSyncForm form, BindException errors) throws Exception
        {
            if (!getUser().isSiteAdmin())
            {
                throw new UnauthorizedException("Only site admins can view this page");
            }

            StringBuilder sb = new StringBuilder();
            sb.append("The following text describes the results of comparing the EHR study with the MSSQL records from the production instance on the same server as this DB instance.  Clicking OK will cause the system to attempt to repair any differences.  Please do this very carefully.<br>");
            sb.append("<br><br>");

            ETLRunnable runnable = new ETLRunnable();
            String msg = runnable.validateEtlSync(false);
            if (msg != null)
                sb.append(msg);
            else
                sb.append("There are no discrepancies<br>");

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

    @RequiresSiteAdmin
    public class FixWorkbookPathsAction extends ConfirmAction<Object>
    {
        public boolean handlePost(Object form, BindException errors) throws Exception
        {
            inspectWorkbooks(true);

            return true;
        }

        public ModelAndView getConfirmView(Object form, BindException errors) throws Exception
        {
            List<String> msgs = inspectWorkbooks(false);

            return new HtmlView(StringUtils.join(msgs, "<br><br>"));
        }

        public void validateCommand(Object form, Errors errors)
        {

        }

        public ActionURL getSuccessURL(Object form)
        {
            return getContainer().getStartURL(getUser());
        }

        private int getChildFileCount(File f)
        {
            int count = 0;
            if (f.isDirectory())
            {
                for (File child : f.listFiles())
                {
                    count += getChildFileCount(child);
                }
            }
            else
            {
                count++;
            }

            return count;
        }

        private List<String> inspectWorkbooks(final boolean makeChanges)
        {
            final List<String> msgs = new ArrayList<>();
            TableInfo containers = DbSchema.get("core").getTable("containers");
            TableSelector ts = new TableSelector(containers, new SimpleFilter(FieldKey.fromString("type"), "workbook"), null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    try
                    {
                        Container workbook = ContainerManager.getForId(rs.getString("entityid"));
                        FileContentService svc = ServiceRegistry.get().getService(FileContentService.class);
                        File parentRoot = svc.getFileRoot(workbook.getParent());
                        if (parentRoot != null)
                        {
                            File oldDirectory = new File(parentRoot, "workbook-" + workbook.getRowId());
                            if (oldDirectory.exists())
                            {
                                File target = new File(parentRoot, workbook.getName());
                                if (target.exists())
                                {
                                    int count = getChildFileCount(target);
                                    if (count == 0)
                                    {
                                        msgs.add("no files in target, deleting: " + target.getPath() + ", and moving from: " + oldDirectory.getPath());
                                        if (makeChanges)
                                        {
                                            FileUtils.deleteDirectory(target);
                                            FileUtils.moveDirectory(oldDirectory, target);
                                            svc.fireFileMoveEvent(oldDirectory, target, getUser(), workbook);
                                        }
                                    }
                                    else
                                    {
                                        msgs.add("has files, copy/merge from: " + oldDirectory.getPath() + ", to: " + target.getPath());
                                        if (makeChanges)
                                        {
                                            FileUtils.copyDirectory(oldDirectory, target);
                                            FileUtils.deleteDirectory(oldDirectory);
                                            svc.fireFileMoveEvent(oldDirectory, target, getUser(), workbook);
                                        }
                                    }
                                }
                                else
                                {
                                    msgs.add("no existing folder, moving from: " + oldDirectory.getPath() + ", to: " + target.getPath());
                                    if (makeChanges)
                                    {
                                        FileUtils.moveDirectory(oldDirectory, target);
                                        svc.fireFileMoveEvent(oldDirectory, target, getUser(), workbook);
                                    }
                                }
                            }
                            else
                            {
                                msgs.add("old directory does not exist: " + oldDirectory.getPath());
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        throw new RuntimeException(e);
                    }
                }
            });

            return msgs;
        }
    }

    @RequiresPermission(ReadPermission.class)
    @CSRF
    public class GetAnimalLockAction extends ApiAction<Object>
    {
        public ApiResponse execute(Object form, BindException errors)
        {
            return new ApiSimpleResponse(ONPRC_EHRManager.get().getAnimalLockProperties(getContainer()));
        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    @CSRF
    public class SetAnimalLockAction extends ApiAction<LockAnimalForm>
    {
        public ApiResponse execute(LockAnimalForm form, BindException errors)
        {
            ///Added by Lakshmi on 02/26/2015: This is server side validation code to check if the Birth/Arrival screens are locked or not.
            //If already locked: show the lock results
            //If not locked: Check if its locked and display the lock results instead of locking the screen again.
            Map<String, Object> props = ONPRC_EHRManager.get().getAnimalLockProperties(getContainer());
            if (!Boolean.TRUE.equals(props.get("locked") ) || (!form.isLock()) )
            {
                ONPRC_EHRManager.get().lockAnimalCreation(getContainer(), getUser(), form.isLock(), form.getStartingId(), form.getIdCount());
            }

            return new ApiSimpleResponse(ONPRC_EHRManager.get().getAnimalLockProperties(getContainer()));
        }
    }

    public static class LockAnimalForm
    {
        private boolean _lock;
        private Integer _startingId;
        private Integer _idCount;

        public boolean isLock()
        {
            return _lock;
        }

        public void setLock(boolean lock)
        {
            _lock = lock;
        }

        public Integer getIdCount()
        {
            return _idCount;
        }

        public void setIdCount(Integer idCount)
        {
            _idCount = idCount;
        }

        public Integer getStartingId()
        {
            return _startingId;
        }

        public void setStartingId(Integer startingId)
        {
            _startingId = startingId;
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class ValidateDatasetColsAction extends ConfirmAction<Object>
    {
        public void validateCommand(Object form, Errors errors)
        {

        }

        public URLHelper getSuccessURL(Object form)
        {
            return PageFlowUtil.urlProvider(PipelineStatusUrls.class).urlBegin(getContainer());
        }

        public ModelAndView getConfirmView(Object form, BindException errors) throws Exception
        {
            //NOTE: consider allowing moduleName as a URL param?
            Module module = ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class);
            FileResource resource = (FileResource)module.getModuleResolver().lookup(Path.parse("referenceStudy/datasets/datasets_metadata.xml"));
            File xml = resource.getFile();

            List<String> msgs = ONPRC_EHRManager.get().validateDatasetCols(getContainer(), getUser(), xml);

            return new HtmlView("This action will compare the columns in the study datasets against those expected in the reference XML file.  " + (msgs.isEmpty() ? "No problems were found." : "The following discrepancies were found:<br><br> " + StringUtils.join(msgs, "<br>")));
        }

        public boolean handlePost(Object form, BindException errors) throws Exception
        {
            //TODO: consider automatically fixing?

            return true;
        }
    }
}
