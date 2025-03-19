/*
 * Copyright (c) 2012-2018 LabKey Corporation
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
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.ReadOnlyApiAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.view.ActionURL;
import org.springframework.validation.BindException;

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
    public static class GetNavItemsAction extends ReadOnlyApiAction<Object>
    {
        @Override
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

            //Added by kollil 5/7/2019
            resultProperties.put("reservation", getSection("/ONPRC/Room Reservations"));

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

    /**
     * Used to get the HTTP Session ID for SSRS integration. See ONPRC.Utils.getSsrsParams().
     * This allows the cookie to be marked as HTTP-only
     */
    @RequiresPermission(ReadPermission.class)
    public static class GetSessionIdAction extends MutatingApiAction<Object>
    {
        @Override
        public Object execute(Object o, BindException errors)
        {
            return Map.of("SessionId", getViewContext().getRequest().getSession(true).getId());
        }
    }

    @RequiresPermission(ReadPermission.class)
    public static class GetAnimalLockAction extends ReadOnlyApiAction<Object>
    {
        @Override
        public ApiResponse execute(Object form, BindException errors)
        {
            return new ApiSimpleResponse(ONPRC_EHRManager.get().getAnimalLockProperties(getContainer()));
        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public static class SetAnimalLockAction extends MutatingApiAction<LockAnimalForm>
    {
        @Override
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
