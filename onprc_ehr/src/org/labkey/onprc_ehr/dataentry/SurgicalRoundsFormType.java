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
public class SurgicalRoundsFormType extends TaskForm
{
    public SurgicalRoundsFormType(Module owner)
    {
        super(owner, "Surgical Rounds", "Surgical Rounds", "Clinical", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new SurgicalRoundsRemarksFormSection(),
            new BloodDrawFormSection(false, EHRService.FORM_SECTION_LOCATION.Tabs),
            new ClinicalObservationsFormPanel(EHRService.FORM_SECTION_LOCATION.Tabs)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("SurgicalRounds");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/SurgicalRounds.js"));
    }
}
