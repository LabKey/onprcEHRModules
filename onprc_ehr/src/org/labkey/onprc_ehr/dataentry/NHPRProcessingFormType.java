/*
 * Copyright (c) 2014 LabKey Corporation
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

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.dataentry.UnsaveableTask;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

//Created: 4-5-2017  R.Blasa
public class NHPRProcessingFormType extends UnsaveableTask
{
    public static final String NAME = "NHPRProcess";

    public NHPRProcessingFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "NHPR Processing", "Colony Management", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new AssignmentFormSection(),
                new SimpleGridPanel("study", "notes", "DCM Notes"),
                new SimpleGridPanel("study", "flags", "Flags")
        ));

        //Added 2-23-2016 R.Blasa
        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ProjectAnimalConditions");
        }


        //Added 5-26-2016 R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("/onprc_ehr/model/sources/ProjectAnimalConditions.js"));

    }
}
