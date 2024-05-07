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
import org.labkey.onprc_ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.onprc_ehr.dataentry.DrugAdministrationFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class TreatmentsFormType extends TaskForm
{
    public static final String NAME = "treatments";
    public static final String LABEL = "Medications/Diet";

    public TreatmentsFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Clinical", Arrays.asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new DrugAdministrationFormSection(ClientDependency.supplierFromPath("onprc_ehr/window/ONPRC_AddScheduledTreatmentWindow.js")),
            new TreatmentOrdersFormSection()
        ));

        //Added: 10-7-2019  R.Blasa
        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("TreatmentDrugsClinical");

        }
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/TreatmentDrugsClinical.js"));
        //Added 4-24-2024  R. Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/FormTemplateWindow.js"));

        //Added by Kollil, 3/12/24
        //This script was added to show a pop-up question box when the user selects MPA medication on the Medication order form.
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/panel/TreatmentOrdersDataEntryPanel.js"));
        setJavascriptClass("ONPRC_EHR.panel.TreatmentOrdersDataEntryPanel");

        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
        {
            addSection(new MiscChargesFormSection(EHRService.FORM_SECTION_LOCATION.Body));
        }

    }

    //Added 4-24-2024  R. Blasa
    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.remove("APPLYFORMTEMPLATE");
        ret.add("APPLYFORMTEMPLATEREV");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
