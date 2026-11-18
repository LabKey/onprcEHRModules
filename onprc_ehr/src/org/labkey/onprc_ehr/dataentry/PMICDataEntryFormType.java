/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.labkey.onprc_ehr.dataentry;

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
                new DrugAdministrationFormSection(),
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