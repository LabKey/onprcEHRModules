/*
 * Copyright (c) 2012-2014 LabKey Corporation
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

import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.Results;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.ldk.notification.Notification;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyService;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

/**
 * User: bimber
 * Date: 12/19/12
 * Time: 7:32 PM
 */
abstract public class AbstractEHRNotification implements Notification
{
    protected final static Logger log = Logger.getLogger(AbstractEHRNotification.class);
    protected final static SimpleDateFormat _dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd kk:mm");
    protected final static SimpleDateFormat _dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    protected final static SimpleDateFormat _timeFormat = new SimpleDateFormat("kk:mm");
    protected static final String lastSave = "lastSave";

    protected NotificationService _ns = NotificationService.get();

    public boolean isAvailable(Container c)
    {
        if (!c.getActiveModules().contains(ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class)))
            return false;

        if (StudyService.get().getStudy(c) == null)
            return false;

        return true;
    }

    protected UserSchema getStudySchema(Container c, User u)
    {
        return QueryService.get().getUserSchema(u, c, "study");
    }

    protected UserSchema getEHRSchema(Container c, User u)
    {
        return QueryService.get().getUserSchema(u, c, "ehr");
    }

    protected UserSchema getEHRLookupsSchema(Container c, User u)
    {
        return QueryService.get().getUserSchema(u, c, "ehr_lookups");
    }

    protected Study getStudy(Container c)
    {
        return StudyService.get().getStudy(c);
    }

    public String getCategory()
    {
        return "EHR";
    }

    protected String appendField(String name, Results rs) throws SQLException
    {
        return rs.getString(FieldKey.fromString(name)) == null ? "" : rs.getString(FieldKey.fromString(name));
    }

    public String getCronString()
    {
        return null;//"0 0/5 * * * ?";
    }

    protected String getExecuteQueryUrl(Container c, String schemaName, String queryName, @Nullable String viewName)
    {
        return getExecuteQueryUrl(c, schemaName, queryName, viewName, null);
    }

    /**
     * This should really be using URLHelpers better, but there is a lot of legacy URL strings
     * migrated into java and its not worth changing all of it at this point
     */
    protected String getExecuteQueryUrl(Container c, String schemaName, String queryName, @Nullable String viewName, @Nullable SimpleFilter filter)
    {
        DetailsURL url = DetailsURL.fromString("/query/executeQuery.view", c);
        String ret = AppProps.getInstance().getBaseServerUrl() + url.getActionURL().toString();
        ret += "schemaName=" + schemaName + "&query.queryName=" + queryName;
        if (viewName != null)
            ret += "&query.viewName=" + viewName;

        if (filter != null)
            ret += "&" + filter.toQueryString("query");

        return ret;
    }

    protected Map<String, String> getSavedValues(Container c)
    {
        return PropertyManager.getProperties(c, getClass().getName());
    }

    protected void saveValues(Container c, Map<String, String> newValues)
    {
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(c, getClass().getName(), true);

        Long lastSaveMills = map.containsKey(lastSave) ? Long.parseLong(map.get(lastSave)) : null;

        //if values have already been cached for this alert on this day, dont re-cache them.
        if (lastSaveMills != null)
        {
            if (DateUtils.isSameDay(new Date(), new Date(lastSaveMills)))
            {
                return;
            }
        }

        newValues.put(lastSave, String.valueOf(new Date().getTime()));
        map.putAll(newValues);

        PropertyManager.saveProperties(map);
    }

    protected String getParameterUrlString(Map<String, Object> params)
    {
        StringBuilder sb = new StringBuilder();
        for (String key : params.keySet())
        {
            sb.append("&query.param.").append(key).append("=");
            if (params.get(key) instanceof Date)
            {
                sb.append(_dateFormat.format(params.get(key)));
            }
            else
            {
                sb.append(params.get(key));
            }
        }


        return sb.toString();
    }
}
