package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.forms.BloodDrawFormType;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

public class ONPRCBloodDrawFormType extends BloodDrawFormType
{
    public ONPRCBloodDrawFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner);
    }

    @Override
    public ClientDependency getAddScheduledTreatmentWindowDependency()
    {
        return ClientDependency.fromPath("onprc_ehr/window/ONPRC_AddScheduledTreatmentWindow.js");
    }
}
