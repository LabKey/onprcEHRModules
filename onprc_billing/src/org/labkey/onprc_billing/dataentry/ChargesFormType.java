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
import org.labkey.security.xml.GroupEnumType;

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

        return defaultButtons;
    }

    //Added: 8-22-2018  R.Blasa
    @Override
    public boolean isVisible()
    {
        Group g = GroupManager.getGroup(getCtx().getContainer(), "SLA Users", GroupEnumType.SITE);
        if (g != null && getCtx().getUser().isInGroup(g.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }
//        Added: 12-3-2019  R.blasa
        Group j = GroupManager.getGroup(getCtx().getContainer(), "Pathology External Entry", GroupEnumType.SITE);
        if (j != null && getCtx().getUser().isInGroup(j.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }

        //        Added: 12-3-2019  R.blasa
        Group L = GroupManager.getGroup(getCtx().getContainer(), "Virology Core", GroupEnumType.SITE);
        if (L != null && getCtx().getUser().isInGroup(L.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }
        return super.isVisible();
    }
}
