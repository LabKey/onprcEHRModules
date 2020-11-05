

//Created: 10-9-2017   R.Blasa  ASB Service Request (Procedures)

package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.BulkEditFormType;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**

 */
public class ProcedureRequestBulkEditFormType extends BulkEditFormType
{
    public static final String NAME = "ProcedureBulkEdit";

    public ProcedureRequestBulkEditFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Procedure Requests", "Clinical", "lsid", Arrays.<FormSection>asList(
                new EncounterProcedureFormSection()
        ));
    }
}
