package org.labkey.ONPRCEHR_ComplianceDB.dataentry;

import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.ONPRCEHR_ComplianceDB.dataentry.EmployeeRequirementsFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBEntryPermission;
import java.util.Arrays;



public class EmployeeRecordsFormType extends  TaskForm
{
    public static final String NAME = "employeerecords";

    public EmployeeRecordsFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Employee Records", "Employee Training Records", Arrays.asList(
                new TaskFormSection(),
                new EmployeeRequirementsFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("EHR_ComplianceDB/model/sources/EmployeeRecords.js"));
        for  (FormSection s : getFormSections())
        {
            s.addConfigSource("EmployeeRecords");
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

