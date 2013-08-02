package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
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
public class ClinpathFormType extends TaskForm
{
    public ClinpathFormType(Module owner)
    {
        super(owner, "clinpath", "Lab Results", "Clinpath", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleGridPanel("study", "Clinpath Runs", "Panels / Services", EHRService.FORM_SECTION_LOCATION.Body),
                new AnimalDetailsFormSection(),
                new ClinpathFormSection("study", "Chemistry Results", "Biochemistry"),
                new ClinpathFormSection("study", "Hematology Results", "Hematology"),
                new ClinpathFormSection("study", "Microbiology Results", "Microbiology"),
                new ClinpathFormSection("study", "Parasitology Results", "Parasitology"),
                new ClinpathFormSection("study", "Serology Results", "Serology"),
                new ClinpathFormSection("study", "Urinalysis Results", "Urinalysis"),
                new ClinpathFormSection("study", "Misc Tests", "Misc Tests")
        ));
    }
}
