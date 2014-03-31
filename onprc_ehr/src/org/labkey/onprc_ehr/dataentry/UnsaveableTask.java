package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;

import java.util.ArrayList;
import java.util.List;

/**

 */
abstract public class UnsaveableTask extends TaskForm
{
    protected UnsaveableTask(DataEntryFormContext ctx, Module owner, String name, String label, String category, List<FormSection> sections)
    {
        super(ctx, owner, name, label, category, sections);
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("SUBMIT");

        return defaultButtons;
    }

    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("VALIDATEALL");

        defaultButtons.add("FORCESUBMIT");
        defaultButtons.add("DISCARD");

        return defaultButtons;
    }
}
