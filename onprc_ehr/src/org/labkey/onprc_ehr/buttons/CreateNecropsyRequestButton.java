/*
 * Copyright (c) 2019-2026 LabKey Corporation
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

import org.labkey.api.ehr.buttons.CreateTaskFromRecordsButton;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.dataentry.PathologyTissuesFormType;

public class CreateNecropsyRequestButton extends CreateTaskFromRecordsButton
{
    public CreateNecropsyRequestButton(Module owner)
    {
        super(owner, "Create Pathology TASK From Selected", "ONPRC_EHR.window.CreateNecropsyRequestWindow.createTaskFromRecordHandler(dataRegionName, '" + PathologyTissuesFormType.NAME + "')");
        setClientDependencies(ClientDependency.supplierFromPath("onprc_ehr/window/CreateNecropsyRequestWindow.js"));
    }
}
