package org.labkey.ONPRCEHR_ComplianceDB.dataentry;

import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBEntryPermission;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


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
        addClientDependency(ClientDependency.supplierFromPath("ehr_compliancedb/panel/EmployeeRecords.js"));

        for  (FormSection s : getFormSections())
        {
            s.addConfigSource("EmployeeRequiredUnit");
        }

    }

//  Added: 11-18-2021  R.Blasa
    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        int idx = ret.indexOf("SUBMIT");
        assert idx > -1;
        ret.remove("SUBMIT");
        if (idx > -1)
             ret.add(idx, "EMPLOYEERUN");
         else
            ret.add("EMPLOYEERUN");

        int idx2 = ret.indexOf("CLOSE");
        assert idx2 > -1;
        ret.remove("CLOSE");
        if (idx2 > -1)
            ret.add(idx2, "EMPLOYEECLOSE");
        else
            ret.add("EMPLOYEECLOSE");

        return ret;
    };

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_ComplianceDBEntryPermission.class))
            return false;

        return super.canInsert();
    }


}