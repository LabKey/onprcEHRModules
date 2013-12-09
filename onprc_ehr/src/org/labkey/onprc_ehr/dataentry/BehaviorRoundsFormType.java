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
public class BehaviorRoundsFormType extends TaskForm
{
    public BehaviorRoundsFormType(Module owner)
    {
        super(owner, "BSU Rounds", "BSU Rounds", "BSU", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new SurgicalRoundsRemarksFormSection(),
            new ClinicalObservationsFormPanel(EHRService.FORM_SECTION_LOCATION.Tabs)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("BehaviorRounds");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/BehaviorRounds.js"));
    }
}
