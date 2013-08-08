/*
 * Copyright (c) 2013 LabKey Corporation
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

import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.Module;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.study.DataSetTable;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 7/10/13
 * Time: 8:37 PM
 */
public class ManageCasesButton extends SimpleButtonConfigFactory
{
    public ManageCasesButton(Module owner)
    {
        super(owner, "Manage Cases", "ONPRC_EHR.Buttons.showManageCases(dataRegionName);");
        setClientDependencies(ClientDependency.fromFilePath("ehr/panel/ManageCasesPanel.js"), ClientDependency.fromFilePath("ehr/window/ManageCasesWindow.js"), ClientDependency.fromFilePath("onprc_ehr/buttons.js"));
    }

    public boolean isAvailable(TableInfo ti)
    {
        if (!super.isAvailable(ti) || !(ti instanceof DataSetTable))
            return false;

        if (ti.getUserSchema().getName().equalsIgnoreCase("study") && ti.getPublicName().equalsIgnoreCase("cases"))
            return EHRService.get().hasDataEntryPermission(ti);

        return EHRService.get().hasDataEntryPermission("study", "cases", ti.getUserSchema().getContainer(), ti.getUserSchema().getUser());
    }
}
