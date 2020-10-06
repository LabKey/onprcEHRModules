/*
 * Copyright (c) 2013-2016 LabKey Corporation
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
package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.security.EHRScheduledInsertPermission;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.Module;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.study.DatasetTable;
import org.labkey.api.view.template.ClientDependency;

import java.util.Set;

//Createdd: 1-18-2019   R.Blasa

public class CreateTaskFromRecordButtons extends SimpleButtonConfigFactory
{
    public CreateTaskFromRecordButtons(Module owner, String btnLabel, String taskLabel, String formType)
    {
        super(owner, btnLabel, "ONPRC_EHR.window.CreateTaskFromRecordsWindow.createTaskFromRecordHandler(dataRegionName, '" + formType + "', '" + taskLabel + "')");
        setClientDependencies(ClientDependency.fromPath("onprc_ehr/window/CreateTaskFromRecordsWindow.js"));    //Modified: 1-19-2019 R.Blasa

    }

    public boolean isAvailable(TableInfo ti)
    {
        if (!super.isAvailable(ti))
            return false;

        if (ti instanceof DatasetTable)
        {
            Set<Class<? extends Permission>> perms = ((DatasetTable) ti).getDataset().getPermissions(ti.getUserSchema().getUser());
            return perms.contains(EHRScheduledInsertPermission.class);
        }

        return ti.hasPermission(ti.getUserSchema().getUser(), EHRScheduledInsertPermission.class);
    }
}

