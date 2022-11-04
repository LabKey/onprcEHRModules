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


public class BioFireFormType extends TaskForm
{
    public static final String NAME = "iStat";

    public BioFireFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Bio Fire Results", "Lab Results", Arrays.asList(
                new TaskFormSection(),
                new BioFirePanelForm(),
                new LabworkFormSection("study", "miscTests", "Misc Test", true)
        ));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("Labwork");
            s.addConfigSource("iStat");
        }

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/iStat.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/BioFireImportWindow.js"));
    }
}