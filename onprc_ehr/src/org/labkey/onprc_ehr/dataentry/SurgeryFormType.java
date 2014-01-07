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

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.EncounterForm;
import org.labkey.api.ehr.dataentry.ExtendedAnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
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
public class SurgeryFormType extends EncounterForm
{
    public static final String NAME = "Surgeries";

    public SurgeryFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Surgeries", "Surgery", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new ClinicalEncountersFormSection(),
                new ExtendedAnimalDetailsFormSection(),
                new EncounterChildFormSection("ehr", "encounter_participants", "Staff", false, true),
                new EncounterChildFormSection("ehr", "encounter_summaries", "Narrative", true, true),
                new EncounterChildFormSection("study", "Drug Administration", "Medications/Treatments Given", true, true, "EHR.data.DrugAdministrationRunsClientStore", Arrays.asList(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js")), "Medications"),
                new EncounterChildFormSection("study", "Treatment Orders", "Medication/Treatment Orders", false, true, "EHR.data.DrugAdministrationRunsClientStore", Arrays.asList(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js")), "Medications"),
                new EncounterChildFormSection("study", "weight", "Weight", false),
                new EncounterChildFormSection("study", "blood", "Blood Draws", false, true),
                new EncounterChildFormSection("ehr", "snomed_tags", "Diagnostic Codes", true),
                new EncounterChildFormSection("onprc_billing", "miscCharges", "Misc. Charges", false, false, "EHR.data.MiscChargesClientStore", Arrays.asList(ClientDependency.fromFilePath("ehr/data/MiscChargesClientStore.js")), null)
        ));

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Surgery.js"));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("Surgery");
        }
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();
        ret.add("OPENSURGERYCASES");

        return ret;
    }
}
