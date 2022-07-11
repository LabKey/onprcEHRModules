package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
//import org.labkey.sla.security.SLAEntryPermission;

import java.util.Arrays;

/**

 */
public class EnvironmentalFormType extends TaskForm
{
    public static final String NAME = "SLA Census";

    public EnvironmentalFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "SLA", Arrays.asList(
                new TaskFormSection(),
                new EnvironmentalFormSection())
        );

        addClientDependency(ClientDependency.supplierFromPath("sla/model/sources/SLA.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/ONPRC_ProjectField.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/onprc_SlaCensusConfig.js"));


        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("SLA");
        }
    }

//    @Override
//    protected boolean canInsert()
//    {
//        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), SLAEntryPermission.class))
//            return false;
//
//        return super.canInsert();
//    }
}
