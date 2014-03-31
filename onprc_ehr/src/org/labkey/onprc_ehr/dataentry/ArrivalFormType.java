package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class ArrivalFormType extends UnsaveableTask
{
    public static final String NAME = "arrival";

    public ArrivalFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Arrival", "Colony Management", Arrays.<FormSection>asList(
                new LockAnimalsFormSection(),
                new TaskFormSection(),
                new DocumentArchiveFormSection(),
                new AnimalDetailsFormSection(),
                new NewAnimalFormSection("study", "arrival", "Arrivals")
        ));
    }
}
