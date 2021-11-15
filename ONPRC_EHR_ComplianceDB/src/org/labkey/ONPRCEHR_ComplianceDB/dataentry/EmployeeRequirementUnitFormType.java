package org.labkey.ONPRCEHR_ComplianceDB.dataentry;

import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBEntryPermission;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;


public class EmployeeRequirementUnitFormType extends  TaskForm
{
    public static final String NAME = "employeeunitrecords";

    public EmployeeRequirementUnitFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Employee Requirements Per Unit", "Employee Training Records", Arrays.asList(
                new TaskFormSection(),
                new EmployeeRequirementUnitFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("EHR_ComplianceDB/model/sources/EmployeeUnit.js"));
        for  (FormSection s : getFormSections())
        {
            s.addConfigSource("EmployeeRequiredUnit");
        }

    }
    @Override

    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_ComplianceDBEntryPermission.class))
            return false;

        return super.canInsert();
    }


}