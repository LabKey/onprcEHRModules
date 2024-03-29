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
package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

//Created: 5-13-2022  R.Blasa

public class EpocFormType extends TaskForm
{
    public static final String NAME = "Epoc";

    public EpocFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Epoc Results", "Lab Results", Arrays.asList(
                new TaskFormSection(),
                new EpocPanelForm(),
                new LabworkFormSection("study", "Epoc", "EPOC", true)
        ));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("Epoca");
        }

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/Epoc.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/EpocImportWindow.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/CopyFromRunsTemplateWindow.js"));
    }
}
