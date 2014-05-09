package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.BulkEditFormType;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**

 */
public class BloodRequestBulkEditFormType extends BulkEditFormType
{
    public static final String NAME = "BloodDrawBulkEdit";

    public BloodRequestBulkEditFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Blood Draw Requests", "Clinical", "lsid", Arrays.<FormSection>asList(
            new BloodDrawFormSection(false)
        ));
    }
}
