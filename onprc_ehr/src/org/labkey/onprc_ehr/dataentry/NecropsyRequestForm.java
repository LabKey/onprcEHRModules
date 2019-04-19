package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

public class NecropsyRequestForm extends RequestForm
{
    public static final String NAME = "Necropsy Request";

    public NecropsyRequestForm(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Requests", Arrays.asList(
                new NecropsyRequestInfoFormSection(),
                new ClinicalEncountersFormPanelSection("Necropsy"),
                new AnimalDetailsFormSection(),
                new SimpleFormSection("study", "tissue_samples", "Tissue Samples", "onprc_ehr-dragdropgridpanel"),
                new SimpleFormSection("study", "organ_weights", "Organ Weights", "onprc_ehr-dragdropgridpanel")
                ));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/grid/DragDropGridPanel.js"));

    }
}
