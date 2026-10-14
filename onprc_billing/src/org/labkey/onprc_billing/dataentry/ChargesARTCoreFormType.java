/*
 * Copyright (c) 2022-2026 LabKey Corporation
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
package org.labkey.onprc_billing.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_billing.security.ONPRCArtCoreChargesEntryPermission;
import org.labkey.api.onprc_ehr.ONPRC_EHRService;

import java.util.Arrays;
import java.util.List;

//Kollil: 10/27/2021. ART Core Misc charges screen

public class ChargesARTCoreFormType extends TaskForm
{
    public static final String NAME = "ARTCoreCharges";

    public ChargesARTCoreFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "ART Core Charges", "Billing", Arrays.<FormSection>asList(
                new TaskFormSection(),
                (FormSection) ONPRC_EHRService.get().getAnimalDetailsFormSection(),
                new ChargesInstructionFormSection(),
                new ChargesARTCoreFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("onprc_billing/panel/ChargesInstructionPanel.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_billing/buttons/financeButtons.js"));
    }


    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = super.getMoreActionButtonConfigs();
        defaultButtons.add("COPY_TASK");

        return defaultButtons;
    }

//Added: 5-14-2024  R.Blasa  Created new permissions
    @Override
    public boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCArtCoreChargesEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    public boolean canRead()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCArtCoreChargesEntryPermission.class))
            return false;

        return super.canRead();
    }
}
