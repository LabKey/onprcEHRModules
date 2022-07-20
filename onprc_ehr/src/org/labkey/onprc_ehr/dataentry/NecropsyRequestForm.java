package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class NecropsyRequestForm extends RequestForm
{
    public static final String NAME = "Pathology Service Request";

    public NecropsyRequestForm(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Requests", Arrays.asList(
                new NecropsyRequestInfoFormSection(),
                new NonStoreFormSection("Instructions", "References", "onprc_ehr_necropsyRequestinstructionspanel", Arrays.asList(ClientDependency.supplierFromPath("onprc_ehr/panel/TissueRequestInstructionsPanel.js"))),
                new AnimalDetailsFormSection(),
                new ClinicalEncountersFormPanelSection("study", "encounters","Necropsy", false),
                new TissueDistRequestFormSection()
                ));

//        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
//        {
//            addSection(new MiscChargesByAccountFormSection(EHRService.FORM_SECTION_LOCATION.Tabs));
//        }


        for (FormSection s : getFormSections())
        {
            s.addConfigSource("PathTissues");
        }

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/DragDropGridPanel.js"));

        //        Added: 1-20-2021  R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/NecropsyRequest.js"));

        //Added 2-17-2021  R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/PathologyTissuesField.js"));

        //Added 7-18-2022  R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/buttons/Path_TissueRequest.js"));

        //    Added: 7-20-22  R.Blasa
        setStoreCollectionClass("onprc_ehr.data.sources.PathTissueRequestStoreCollection");
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/data/sources/PathTissueRequestStoreCollection.js"));




    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.add("DISCARD");
        defaultButtons.add("PATH_REQUEST");
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
