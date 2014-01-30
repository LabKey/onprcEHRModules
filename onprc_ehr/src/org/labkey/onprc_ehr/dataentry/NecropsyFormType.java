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
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class NecropsyFormType extends EncounterForm
{
    public static final String NAME = "Necropsies";
    public static final String LABEL = "Necropsy";

    public NecropsyFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Pathology", Arrays.<FormSection>asList(
                new NonStoreFormSection("Instructions", "Instructions", "ehr-necropsyinstructionspanel", Arrays.asList(ClientDependency.fromFilePath("ehr/panel/NecropsyInstructionsPanel.js"))),
                new TaskFormSection(),
                new ClinicalEncountersFormPanelSection("Necropsy"),
                new AnimalDetailsFormSection(),
                new GrossFindingsFormPanelSection(),
                new PathologyFormSection("ehr", "encounter_participants", "Staff"),
                new PathologyMedicationsFormSection("study", "Drug Administration", "Medications/Treatments"),
                new PathologyFormSection("study", "tissue_samples", "Tissues/Weights"),
                new PathologyFormSection("study", "tissueDistributions", "Tissue Distributions"),
                new PathologyFormSection("study", "measurements", "Measurements"),
                new PathologyDiagnosesFormSection("study", "histology", "Histologic Findings"),
                new PathologyDiagnosesFormSection("study", "pathologyDiagnoses", "Diagnoses")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("Pathology");
            s.addConfigSource("Necropsy");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Pathology.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Necropsy.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/PathologyCaseNoField.js"));
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/pathologyButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromCaseWindow.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.add("COPYFROMCASE");
        ret.add("ENTERDEATH");

        return ret;
    }
}
