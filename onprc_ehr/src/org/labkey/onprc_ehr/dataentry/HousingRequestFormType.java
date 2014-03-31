package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.RequestFormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class HousingRequestFormType extends RequestForm
{
    public static final String NAME = "housing_request";

    public HousingRequestFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Housing Transfer Request", "Requests", Arrays.<FormSection>asList(
                new RequestFormSection(),
                //new RequestInstructionsFormSection(),
                new AnimalDetailsFormSection(),
                new HousingFormSection("onprc_ehr", "housing_transfer_requests", "Requested Housing Transfers")
        ));
    }
}
