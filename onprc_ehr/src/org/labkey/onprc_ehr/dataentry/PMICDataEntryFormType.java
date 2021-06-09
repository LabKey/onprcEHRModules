
package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: Kolli
 * Date: 7/7/19
 * Time: 10:36 AM
 */
public class PMICDataEntryFormType extends TaskForm
{
    public static final String NAME = "PMIC";

    public PMICDataEntryFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "PMIC Data Entry", "Imaging", Arrays.asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new ClinicalEncountersFormSection(),
                new PMIC_PETFormSection(),
                new PMIC_CTFormSection(),
                new PMIC_SPECTFormSection(),
                new PMIC_AngioFormSection(),
                new PMIC_USFormSection(),
                new PMIC_DEXAFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PMIC_Services.js"));


        for (FormSection s : getFormSections())
        {
            s.addConfigSource("PMIC_Services");
        }

    }

//    //    Added: 12-5-2019  R.Blasa  Allow access only to PMIC Access group.
//    @Override
//    protected boolean canInsert()
//    {
//        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_EHRPMICEditPermission.class))
//            return false;
//
//        return super.canInsert();
//    }

}