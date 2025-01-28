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
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.onprc_ehr.security.ONPRC_EHRCMUMedicationEntryPermission;
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
public class CMUTreatmentsFormType extends TaskForm
{
    public static final String NAME = "treatments";
    public static final String LABEL = "Medications/Diet";

    public CMUTreatmentsFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "CMU", Arrays.asList(
            new TaskFormSection(),

            new AnimalDetailsFormSection(),
            new TreatmentOrdersFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/CMU_Services.js"));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("CMU_Services");
        }
        setDisplayReviewRequired(true);

       //Added 4-24-2024  R. Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/FormTemplateWindow.js"));


        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
        {
            addSection(new MiscChargesFormSection(EHRService.FORM_SECTION_LOCATION.Body));
        }

    }






    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_EHRCMUMedicationEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
