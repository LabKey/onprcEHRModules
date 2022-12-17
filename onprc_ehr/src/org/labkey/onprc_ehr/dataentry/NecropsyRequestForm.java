package org.labkey.onprc_ehr.dataentry;

import org.json.JSONObject;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.ehr.security.EHRRequestPermission;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
        {
            MiscChargesByAccountFormSection miscChargesSection = new MiscChargesByAccountFormSection(EHRService.FORM_SECTION_LOCATION.Tabs);
                    //    Added: 8-1-2022  R.Blasa
            miscChargesSection.setClientStoreClass("onprc_ehr.data.PathTissuesClientStore");
            miscChargesSection.addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/data/sources/PathTissuesClientStore.js"));



            addSection(miscChargesSection);
        }


        for (FormSection s : getFormSections())
        {
            s.addConfigSource("PathTissues");
        }

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/DragDropGridPanel.js"));

        //        Added: 1-20-2021  R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/NecropsyRequest.js"));

        //Added 2-17-2021  R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/PathologyTissuesField.js"));

        //Added 12-16-2022 Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/BulkPathTissuesWindow.js"));


       //    Added: 7-20-2022  R.Blasa
        setStoreCollectionClass("onprc_ehr.data.sources.PathTissueRequestStoreCollection");
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/data/sources/PathTissueRequestStoreCollection.js"));

   }


    @Override
    public JSONObject toJSON()
    {
        JSONObject ret = super.toJSON();
        Map<String, Object> map = new HashMap<>();
        map.put("allowRequestsInDistantFuture", true);
        ret.put("extraContext", map);
        return ret;
    }

    //Added 12-16-2022 Blasa
    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.addAll(super.getMoreActionButtonConfigs()) ;
        defaultButtons.add("Tissues_IMPORT");

        return defaultButtons;
    }


    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.add("DISCARD");
        defaultButtons.add("REQUEST");
        defaultButtons.add("SAVEDRAFT");
        return defaultButtons;
    }



}
