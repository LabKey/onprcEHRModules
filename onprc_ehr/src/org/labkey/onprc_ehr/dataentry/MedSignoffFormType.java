/*
 * Copyright (c) 2013-2016 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class MedSignoffFormType extends TaskForm
{
    public static final String NAME = "medsignoff";
    public static final String LABEL = "Post Op Meds Sign Off";

    public MedSignoffFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Clinical", Arrays.asList(
            new TaskFormSection(),
                 //Added 2-19-2016  Blasa
            new NonStoreFormSection("Treatment Template Helper", "Treatment Template Helper", "onprc_AddScheduledTreatmentPanel", Arrays.asList(ClientDependency.fromPath("/onprc_ehr/panel/AddScheduledTreatmentPanel.js"))),

            new AnimalDetailsFormSection(),
            new DrugAdministrationFormSection()
           /* new TreatmentOrdersFormSection()*/
        ));

        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
        {
            addSection(new MiscChargesFormSection(EHRService.FORM_SECTION_LOCATION.Body));
        }

    }



    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
