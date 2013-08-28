package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.EncounterForm;
import org.labkey.api.ehr.dataentry.EncounterFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 8/3/13
 * Time: 10:12 PM
 */
public class DiagnosisFormType extends EncounterForm
{
    public DiagnosisFormType(Module owner)
    {
        super(owner, "diagnosis", "Diagnosis", "Clinical", Arrays.<FormSection>asList(
            new TaskFormSection(),
            //new EncounterFormSection(),
            new ClinicalRemarksFormSection(),
            new ClinicalObservationsFormSection()
        ));
    }
}
