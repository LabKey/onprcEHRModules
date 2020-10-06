package org.labkey.onprc_billing.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.security.xml.GroupEnumType;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.Group;

import java.util.Arrays;
import java.util.List;


public class ChargesVirologyCoreFormType extends TaskForm
{
    public static final String NAME = "VirologyCoreCharges";

    public ChargesVirologyCoreFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Virology Charges", "Billing - Virology Core", Arrays.<FormSection>asList(
                new TaskFormSection(),
//                new AnimalDetailsFormSection(),
                new ChargesInstructionFormSection(),
                new ChargesVirologyCoreFormSection()
        ));

        addClientDependency(ClientDependency.fromPath("onprc_billing/panel/ChargesInstructionPanel.js"));
    }


    //Added: 11/1/2018  R.Blasa  Hide this menu when SLA users are accessing their exit records
    @Override
    public boolean isVisible()
    {
        Group g = GroupManager.getGroup(getCtx().getContainer(), "SLA Users", GroupEnumType.SITE);
        if (g != null && getCtx().getUser().isInGroup(g.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }
        return super.isVisible();
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = super.getMoreActionButtonConfigs();
        defaultButtons.add("COPY_TASK");

        return defaultButtons;
    }
}
