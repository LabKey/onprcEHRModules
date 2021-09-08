package org.labkey.ONPRCEHR_ComplianceDB.dataentry;

import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.ONPRCEHR_ComplianceDB.dataentry.EmployeeRequirementCategoryFormSection;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBEntryPermission;
import java.util.Arrays;


public class EmployeeRequirementCategoryFormType extends  TaskForm
{
    public static final String NAME = "employeecategory";

    public EmployeeRequirementCategoryFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Employee Requirements Category", "Employee Training Records", Arrays.asList(
                new TaskFormSection(),
                new EmployeeRequirementCategoryFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("EHR_ComplianceDB/model/sources/EmployeeCategory.js"));
        for  (FormSection s : getFormSections())
        {
            s.addConfigSource("EmployeeRequiredCategory");
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