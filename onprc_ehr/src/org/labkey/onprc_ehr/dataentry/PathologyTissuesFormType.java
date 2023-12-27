/*
 * Copyright (c) 2013-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.onprc_ehr.dataentry.TissueInstructionFormSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.dataentry.DrugAdministrationFormSection;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.PrincipalType;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;


//Modified: 11-15-2023 R. Blasa

public class PathologyTissuesFormType extends TaskForm
{
    public static final String NAME = "PathologyTissues";
    public static final String LABEL = "Pathology Tissues";

    public PathologyTissuesFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Pathology", Arrays.asList(
                new TaskFormSection(),
                new TissueInstructionFormSection(),
                new AnimalDetailsFormSection(),
                //                Added:5-31-2017  R.Blasa
                new ClinicalEncountersFormPanelSection("Pathology Tissues"),

                new DrugAdministrationFormSection(EHRService.FORM_SECTION_LOCATION.Tabs, DrugAdministrationFormSection.LABEL, ClientDependency.supplierFromPath("onprc_ehr/window/ONPRC_AddScheduledTreatmentWindow.js")),

                //                Added: 6-26-2017   R.Blasa
                new TissueWeightsFormSection(),
                new TissueDistFormSection(),

//                Added: 6-26-2017   R.Blasa
                new TissueMeasurementsFormSection()
        ));

        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
        {
            addSection(new MiscChargesByAccountFormSection(EHRService.FORM_SECTION_LOCATION.Tabs));
        }

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Pathology");
            s.addConfigSource("Necropsy");
            s.addConfigSource("PathTissues");

//            Added: 6-1-2017 R.Blasa
            if (s instanceof SimpleFormSection )
                s.setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NO_ID);

        }



        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/DragDropGridPanel.js"));
        //Added: 5-5-2017   R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PathologyTissues.js"));

//        //Added: 5-24-2017  R.Blasa
        setStoreCollectionClass("onprc_ehr.data.sources.PathologyTissuesStoreCollection");
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/data/sources/PathologyTissuesStoreCollection.js"));

        //Added 7-14-2022  R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/PathologyTissuesField.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.add("ENTERDEATH_FOR_TISSUES");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRPathologyEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    protected Integer getDefaultAssignedTo()
    {
        UserPrincipal up = org.labkey.api.security.SecurityManager.getPrincipal(NecropsyFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }

    @Override
    protected Integer getDefaultReviewRequiredPrincipal()
    {
        UserPrincipal up = org.labkey.api.security.SecurityManager.getPrincipal(NecropsyFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }
}
