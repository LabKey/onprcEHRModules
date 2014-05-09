package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.BulkEditFormType;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**

 */
public class DrugRequestBulkEditFormType extends BulkEditFormType
{
    public static final String NAME = "DrugBulkEdit";
    public DrugRequestBulkEditFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, "DrugBulkEdit", "Medication/Injection Requests", "Clinical", "lsid", Arrays.<FormSection>asList(
                new DrugAdministrationRequestFormSection()
        ));
    }
}
