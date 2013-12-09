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
public class ClinicalRemarkFormType extends TaskForm
{
    public static final String NAME = "Clinical Remarks";

    public ClinicalRemarkFormType(Module owner)
    {
        super(owner, NAME, NAME, "Clinical", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "Clinical Remarks", "SOAPs"),
                new ClinicalObservationsFormPanel(EHRService.FORM_SECTION_LOCATION.Body),
                new SimpleGridPanel("study", "Drug Administration", "Medications/Treatments"),
                new WeightFormSection(),
                new SimpleGridPanel("study", "blood", "Blood Draws"),
                new SimpleGridPanel("ehr", "snomed_tags", "Diagnostic Codes")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalProcedure");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ClinicalProcedure.js"));
    }
}
