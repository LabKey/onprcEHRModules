/*
 * Copyright (c) 2012-2017 LabKey Corporation
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

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.ConfirmAction;
import org.labkey.api.action.ExportAction;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.CoreSchema;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.files.FileContentService;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.AdminConsoleAction;
import org.labkey.api.security.CSRF;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.RequiresSiteAdmin;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.services.ServiceRegistry;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HtmlView;
import org.labkey.api.view.NavTree;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
            TableInfo containers = CoreSchema.getInstance().getTableInfoContainers();
            TableSelector ts = new TableSelector(containers, new SimpleFilter(FieldKey.fromString("type"), "workbook"), null);
            ts.forEach(rs ->
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
}
