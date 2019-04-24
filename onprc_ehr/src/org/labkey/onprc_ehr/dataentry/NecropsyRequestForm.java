package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class NecropsyRequestForm extends RequestForm
{
    public static final String NAME = "Necropsy Request";

    public NecropsyRequestForm(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Requests", Arrays.asList(
                new NecropsyRequestInfoFormSection(),
                new ClinicalEncountersFormPanelSection("study", "encounters","Necropsy", false),
                new AnimalDetailsFormSection(),
                new SimpleFormSection("study", "tissue_samples", "Tissue Samples", "onprc_ehr-dragdropgridpanel"),
                new SimpleFormSection("study", "organ_weights", "Organ Weights", "onprc_ehr-dragdropgridpanel")
                ));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/grid/DragDropGridPanel.js"));

    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.add("DISCARD");
        defaultButtons.add("REQUEST");
        defaultButtons.add("APPROVE");
        return defaultButtons;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRPathologyEntryPermission.class))
            return false;

        return super.canInsert();
    }

    /**
     * The intent is to prevent read access to the majority of users
     */
    @Override
    public boolean canRead()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRPathologyEntryPermission.class))
            return false;

        return super.canRead();
    }
}
