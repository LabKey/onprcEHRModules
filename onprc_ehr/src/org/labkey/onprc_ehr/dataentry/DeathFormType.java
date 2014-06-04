package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRCompletedInsertPermission;
import org.labkey.api.ehr.security.EHRSurgeryEntryPermission;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class DeathFormType extends UnsaveableTask
{
    public static final String NAME = "death";

    public DeathFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Death", "Colony Management", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "deaths", "Deaths")
        ));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRSurgeryEntryPermission.class))
            return false;

        return EHRService.get().hasPermission("study", "deaths", getCtx().getContainer(), getCtx().getUser(), EHRCompletedInsertPermission.class);
    }
}
