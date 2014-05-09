package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.BulkEditFormType;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**

 */
public class LabworkRequestBulkEditFormType extends BulkEditFormType
{
    public static final String NAME = "LabworkBulkEdit";

    public LabworkRequestBulkEditFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Labwork Requests", "Clinical", "lsid", Arrays.<FormSection>asList(
                new ClinpathRunsFormSection(true)
        ));
    }
}
