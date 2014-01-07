package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.EncounterForm;
import org.labkey.api.ehr.dataentry.ExtendedAnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
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
public class SingleSurgeryFormType extends EncounterForm
{
    public static final String NAME = "Surgery";

    public SingleSurgeryFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Surgery", "Surgery", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleFormPanelSection("study", "encounters", "Surgery"),
                new ExtendedAnimalDetailsFormSection(),
                new EncounterChildFormSection("ehr", "encounter_participants", "Staff", false, true),
                new EncounterChildFormSection("ehr", "encounter_summaries", "Narrative", true, true),
                new EncounterChildFormSection("study", "Drug Administration", "Medications/Treatments Given", true, true, "EHR.data.DrugAdministrationRunsClientStore", Arrays.asList(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js")), "Medications"),
                new EncounterChildFormSection("study", "Treatment Orders", "Medication/Treatment Orders", false, true, "EHR.data.DrugAdministrationRunsClientStore", Arrays.asList(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js")), "Medications"),
                new EncounterChildFormSection("study", "weight", "Weight", false, true),
                new EncounterChildFormSection("study", "blood", "Blood Draws", false, true),
                new EncounterChildFormSection("ehr", "snomed_tags", "Diagnostic Codes", true, true),
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
