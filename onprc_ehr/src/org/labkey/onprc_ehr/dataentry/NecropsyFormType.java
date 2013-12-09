package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
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
public class NecropsyFormType extends TaskForm
{
    public static final String NAME = "Necropsies";

    public NecropsyFormType(Module owner)
    {
        super(owner, NAME, NAME, "Pathology", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleFormPanelSection("study", "encounters", "Necropsy"),
                new AnimalDetailsFormSection(),
                new NecropsyFormSection("ehr", "encounter_participants", "Staff"),
                //new NecropsyFormSection("ehr", "encounter_summaries", "Narrative"),
                new NecropsyFormSection("study", "Drug Administration", "Medications/Treatments"),
                new NecropsyFormSection("study", "weight", "Weight"),
                new NecropsyFormSection("study", "blood", "Blood Draws"),
                new NecropsyFormSection("study", "tissue_samples", "Tissues/Weights"),
                new NecropsyFormSection("study", "tissueDistributions", "Tissue Distributions"),
                new NecropsyFormSection("study", "measurements", "Measurements"),
                new NecropsyFormSection("study", "histology", "Histology"),
                new NecropsyFormSection("ehr", "snomed_tags", "SNOMED Codes")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("Necropsy");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Necropsy.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/PathologyCaseNoField.js"));
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/pathologyButtons.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.add("ENTERDEATH");

        return ret;
    }
}
