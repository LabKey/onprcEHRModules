package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
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
public class ClinicalRoundsFormType extends TaskForm
{
    public ClinicalRoundsFormType(Module owner)
    {
        super(owner, "Clinical Rounds", "Clinical Rounds", "Clinical", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new ClinicalRoundsRemarksFormSection(),
            new BloodDrawFormSection(false, EHRService.FORM_SECTION_LOCATION.Tabs),
            new TreatmentsTaskFormSection(false, EHRService.FORM_SECTION_LOCATION.Tabs),
            new WeightFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
            new ClinicalObservationsFormPanel(EHRService.FORM_SECTION_LOCATION.Tabs)
            //new SimpleFormSection("study", "encounters", "Procedures", "ehr-gridpanel", EHRService.FORM_SECTION_LOCATION.Tabs)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalRounds");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ClinicalRounds.js"));
    }
}
