package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class ProcedureFormType extends TaskForm
{
    public static final String NAME = "Clinical Procedures";

    public ProcedureFormType(Module owner)
    {
        super(owner, NAME, NAME, "Clinical", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new ClinicalEncountersFormSection(),
                new AnimalDetailsFormSection(),
                new SurgeryFormSection("study", "Clinical Remarks", "Clinical Remarks", false),
                new SurgeryFormSection("study", "Drug Administration", "Medications/Treatments", true),
                new SurgeryFormSection("study", "weight", "Weight", false),
                new SurgeryFormSection("study", "blood", "Blood Draws", false),
                new SurgeryFormSection("ehr", "snomed_tags", "SNOMED Codes", true),
                new SurgeryFormSection("study", "flags", "Flags", true),
                new SurgeryFormSection("onprc_billing", "miscCharges", "Misc. Charges", false)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Surgery");
        }
    }
}
