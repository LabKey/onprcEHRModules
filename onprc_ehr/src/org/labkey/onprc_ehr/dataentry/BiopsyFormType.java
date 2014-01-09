/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.EncounterForm;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
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
public class BiopsyFormType extends EncounterForm
{
    public static final String NAME = "Biopsy";

    public BiopsyFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Pathology", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleFormPanelSection("study", "encounters", "Biopsy"),
                new AnimalDetailsFormSection(),
                new PathologyFormSection("ehr", "encounter_participants", "Staff"),
                new PathologyFormSection("study", "Drug Administration", "Medications/Treatments"),
                new PathologyFormSection("study", "tissue_samples", "Tissues/Weights"),
                new PathologyFormSection("study", "tissueDistributions", "Tissue Distributions"),
                new PathologyFormSection("study", "measurements", "Measurements"),
                new PathologyDiagnosesFormSection("study", "grossFindings", "Gross Findings"),
                new PathologyDiagnosesFormSection("study", "histology", "Histologic Findings"),
                new PathologyDiagnosesFormSection("study", "pathologyDiagnoses", "Diagnoses")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("Pathology");
            s.addConfigSource("Biopsy");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Pathology.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Biopsy.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/PathologyCaseNoField.js"));
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/pathologyButtons.js"));
    }
}
