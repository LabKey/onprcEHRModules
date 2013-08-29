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
package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class LabworkFormType extends TaskForm
{
    public static final String NAME = "Labwork";

    public LabworkFormType(Module owner)
    {
        super(owner, NAME, "Lab Results", "Clinpath", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new ClinpathRunsFormSection(),
                new AnimalDetailsFormSection(),
                new LabworkFormSection("study", "Chemistry Results", "Biochemistry"),
                new LabworkFormSection("study", "Hematology Results", "Hematology"),
                new LabworkFormSection("study", "Microbiology Results", "Microbiology"),
                new LabworkFormSection("study", "Antibiotic Sensitivity", "Antibiotic Sensitivity"),
                new LabworkFormSection("study", "Parasitology Results", "Parasitology"),
                new LabworkFormSection("study", "Serology Results", "Serology/Virology"),
                new LabworkFormSection("study", "Urinalysis Results", "Urinalysis"),
                new LabworkFormSection("study", "Misc Tests", "Misc Tests")
        ));
    }
}
