/*
 * Copyright (c) 2013-2018 LabKey Corporation
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


import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.dataentry.WeightFormSection;
import org.labkey.api.ehr.dataentry.DrugAdministrationFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.Group;
import org.labkey.security.xml.GroupEnumType;

import java.util.Arrays;


/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class WeightFormType extends TaskForm
{
    public static final String NAME = "weight";

    public WeightFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Weights", "Clinical", Arrays.asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new WeightFormSection(),
            new DrugAdministrationFormSection(ClientDependency.supplierFromPath("onprc_ehr/window/ONPRC_AddScheduledTreatmentWindow.js")),
            new TBProcedureFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/Weight.js"));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("Task");
            s.addConfigSource("Weight");
        }
        setDisplayReviewRequired(true);
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }

}
