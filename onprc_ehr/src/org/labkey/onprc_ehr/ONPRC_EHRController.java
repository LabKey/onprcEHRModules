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

import org.apache.commons.codec.binary.Base64;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLRunnable;
import org.labkey.api.action.FormViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.security.RequiresPermissionClass;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.text.DateFormat;
import java.util.Date;
import java.util.Map;

import static java.text.DateFormat.*;

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
    public class EtlAdminAction extends FormViewAction<Object>
    {

        String[] configKeys = {"labkeyUser", "labkeyContainer", "jdbcUrl", "jdbcDriver", "runIntervalInMinutes"};


        @Override
        public void validateCommand(Object o, Errors errors)
        {
            //To change body of implemented methods use File | Settings | File Templates.
        }

        @Override
        public ModelAndView getView(Object o, boolean reshow, BindException errors) throws Exception
        {
            EtlAdminBean bean = new EtlAdminBean();
            bean.setConfig(PropertyManager.getProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN));
            bean.setRowversions(PropertyManager.getProperties(ETLRunnable.ROWVERSION_PROPERTY_DOMAIN));
            bean.setTimestamps(PropertyManager.getProperties(ETLRunnable.TIMESTAMP_PROPERTY_DOMAIN));
            bean.setConfigKeys(configKeys);

            return new JspView<EtlAdminBean>("/org/labkey/onprc_ehr/view/EtlAdmin.jsp", bean, errors);
        }

        @Override
        public boolean handlePost(Object o, BindException errors) throws Exception
        {
            HttpServletRequest request = getViewContext().getRequest();
            PropertyManager.PropertyMap configMap = PropertyManager.getWritableProperties(ETLRunnable.CONFIG_PROPERTY_DOMAIN, true);

            for (String key : configKeys)
            {
                if (request.getParameter(key) != null)
                {
                    configMap.put(key, request.getParameter(key));
                }
            }

            String shouldAnalyze = request.getParameter("shouldAnalyze");
            configMap.put("shouldAnalyze", shouldAnalyze != null && shouldAnalyze.equals("on") ? "true" : "false");

            PropertyManager.saveProperties(configMap);

            PropertyManager.PropertyMap rowVersionMap = PropertyManager.getWritableProperties(ETLRunnable.ROWVERSION_PROPERTY_DOMAIN, true);

            for (String key : PropertyManager.getProperties(ETLRunnable.ROWVERSION_PROPERTY_DOMAIN).keySet())
            {
                if (request.getParameter(key) != null)
                {
                    byte[] bytes = Base64.decodeBase64(request.getParameter(key));
                    String encoded = new String(bytes, "US-ASCII");
                    rowVersionMap.put(key, encoded);
                }
            }
            PropertyManager.saveProperties(rowVersionMap);



            String status = request.getParameter("etlStatus");
            if (status.equals("true"))
                ETL.start(0);
            else if (status.equals("false"))
                ETL.stop();

            return true;
        }

        @Override
        public URLHelper getSuccessURL(Object o)
        {
            return null;  //To change body of implemented methods use File | Settings | File Templates.
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("ETL Admin");
        }
    }

    public class EtlAdminBean
    {
        String[] configKeys;
        Map<String, String> config;
        Map<String, String> rowversions;
        Map<String, String> timestamps;

        public Map<String, String> getConfig()
        {
            return config;
        }

        public void setConfig(Map<String, String> config)
        {
            this.config = config;
        }

        public Map<String, String> getTimestamps()
        {
            return timestamps;
        }

        public void setTimestamps(Map<String, String> timestamps)
        {
            this.timestamps = timestamps;
        }

        public Map<String, String> getRowversions()
        {
            return rowversions;
        }

        public void setRowversions(Map<String, String> rowversions)
        {
            this.rowversions = rowversions;
        }

        public String[] getConfigKeys()
        {
            return configKeys;
        }

        public void setConfigKeys(String[] configKeys)
        {
            this.configKeys = configKeys;
        }

        public boolean shouldAnalyze()
        {
            String shouldAnalyze = config.get("shouldAnalyze");
            return shouldAnalyze != null && shouldAnalyze.equals("true") ? true : false;
        }

    }
}
