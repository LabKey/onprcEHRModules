package org.labkey.onprc_ehr.dataentry;

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
public class ClinicalProcedureFormType extends TaskForm
{
    public static final String NAME = "Clinical Procedures";

    public ClinicalProcedureFormType(Module owner)
    {
        super(owner, NAME, NAME, "Clinical", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new ClinicalEncountersFormSection(),
                new AnimalDetailsFormSection(),
                new EncounterChildFormSection("study", "Clinical Remarks", "SOAPs", false),
                new EncounterObservationsFormSection(),
                new EncounterChildFormSection("study", "Drug Administration", "Medications/Treatments", true),
                new EncounterChildFormSection("study", "weight", "Weight", false),
                new EncounterChildFormSection("study", "blood", "Blood Draws", false),
                new EncounterChildFormSection("ehr", "snomed_tags", "Diagnostic Codes", true)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("ClinicalProcedure");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ClinicalProcedure.js"));
    }
}
