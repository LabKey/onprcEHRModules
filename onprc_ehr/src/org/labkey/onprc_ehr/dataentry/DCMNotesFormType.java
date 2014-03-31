package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**

 */
public class DCMNotesFormType extends UnsaveableTask
{
    public static final String NAME = "notes";

    public DCMNotesFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "DCM Notes", "Colony Management", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "notes", "DCM Notes")
        ));
    }
}
