package org.labkey.onprc_billing.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_billing.security.ONPRCVirologyCoreEntryPermission;
import org.labkey.api.onprc_ehr.ONPRC_EHRService;


import java.util.Arrays;
import java.util.List;


public class ChargesVirologyCoreFormType extends TaskForm
{
    public static final String NAME = "VirologyCoreCharges";

    public ChargesVirologyCoreFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Virology Charges", "Billing", Arrays.<FormSection>asList(
                new TaskFormSection(),
                (FormSection) ONPRC_EHRService.get().getAnimalDetailsFormSection(),
                new ChargesInstructionFormSection(),
                new ChargesVirologyCoreFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("onprc_billing/panel/ChargesInstructionPanel.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = super.getMoreActionButtonConfigs();
        defaultButtons.add("COPY_TASK");

        return defaultButtons;
    }

    //    Added: 12-3-2019  R.Blasa
    @Override
    public boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCVirologyCoreEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    public boolean canRead()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCVirologyCoreEntryPermission.class))
            return false;

        return super.canRead();
    }
}
