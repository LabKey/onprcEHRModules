package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class DepartureFormType extends UnsaveableTask
{
    public static final String NAME = "departure";

    public DepartureFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Departure", "Colony Management", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new DocumentArchiveFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "departure", "Departures")
        ));
    }
}
