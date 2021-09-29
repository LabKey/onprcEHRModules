package org.labkey.onprc_billing.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class ChargesARTCoreFormType extends TaskForm
{
    public static final String NAME = "ARTCoreCharges";

    public ChargesARTCoreFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "ART Core Charges", "Billing - ART Core", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new ChargesInstructionFormSection(),
                new ChargesARTCoreFormSection()
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

    @Override
    //Added a new button to the list that submits and reloads the data entry form
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.addAll(super.getButtonConfigs());
        defaultButtons.add("BILLINGSAVECLOSE");
        defaultButtons.add("BILLINGRELOAD");
        defaultButtons.add("BILLINGFINAL");
        defaultButtons.remove("SUBMIT");
        defaultButtons.remove("CLOSE");

        return defaultButtons;
    }


//    //    Added: 12-3-2019  R.Blasa
//    @Override
//    public boolean canInsert()
//    {
//        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCVirologyCoreEntryPermission.class))
//            return false;
//
//        return super.canInsert();
//    }
//
//    @Override
//    public boolean canRead()
//    {
//        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCVirologyCoreEntryPermission.class))
//            return false;
//
//        return super.canRead();
//    }
}
