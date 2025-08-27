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
