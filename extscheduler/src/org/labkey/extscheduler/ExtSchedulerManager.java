/*
 * Copyright (c) 2016-2026 LabKey Corporation
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
package org.labkey.extscheduler;

import org.labkey.api.data.Container;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.module.ModuleProperty;
import org.labkey.api.security.User;

import java.util.Date;
import java.util.Map;

public class ExtSchedulerManager
{
    private static final ExtSchedulerManager _instance = new ExtSchedulerManager();

    private ExtSchedulerManager()
    {
    }

    public static ExtSchedulerManager getInstance()
    {
        return _instance;
    }

    public boolean isEventOwner(User user, Map<String, Object> row)
    {
        Integer rowUserId = row.get("UserId") != null ? Integer.parseInt(row.get("UserId").toString()) : null;
        return rowUserId != null && user.getUserId() == rowUserId.intValue();
    }

    public boolean isEventCreator(User user, Map<String, Object> row)
    {
        Integer rowCreatedBy = row.get("CreatedBy") != null ? Integer.parseInt(row.get("CreatedBy").toString()) : null;
        return rowCreatedBy != null && user.getUserId() == rowCreatedBy.intValue();
    }

    public boolean isEventInPast(Map<String, Object> row)
    {
        Date rowStartDate = (Date) row.get("StartDate");
        Date now = new Date();
        return rowStartDate.getTime() < now.getTime();
    }

    private ModuleProperty getModuleProperty(String propName)
    {
        Module slaModule = ModuleLoader.getInstance().getModule(ExtSchedulerModule.class);
        return slaModule.getModuleProperties().get(propName);
    }

    public String getExtSchedulerUserGroupName(Container c)
    {
        ModuleProperty groupName = getModuleProperty("ExtSchedulerUserGroupName");
        if (groupName != null)
            return groupName.getEffectiveValue(c);

        return null;
    }
}
