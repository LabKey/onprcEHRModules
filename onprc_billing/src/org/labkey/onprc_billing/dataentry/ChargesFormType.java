package org.labkey.onprc_billing.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.security.Group;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_billing.security.ONPRCMiscChargesEntryPermission;
import org.labkey.security.xml.GroupEnumType;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 11/12/13
 * Time: 5:25 PM
 */
public class ChargesFormType extends TaskForm
{
    public static final String NAME = "miscCharges";

    public ChargesFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Misc Charges", "Billing", Arrays.asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new ChargesInstructionFormSection(),
                new ChargesFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("onprc_billing/panel/ChargesInstructionPanel.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_billing/buttons/financeButtons.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/MiscCharges_ScanWindow.js"));

    }


    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = super.getMoreActionButtonConfigs();
        defaultButtons.add("COPY_TASK");
        defaultButtons.add("MISC_SCAN_IMPORT");

        return defaultButtons;
    }
//Modified   5-14-2024  R. Blasa  Created new permissions
@Override
public boolean canInsert()
{
    if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCMiscChargesEntryPermission.class))
        return false;

    return super.canInsert();
}

    @Override
    public boolean canRead()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRCMiscChargesEntryPermission.class))
            return false;

        return super.canRead();
    }

}
