/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
import org.labkey.api.ehr.security.EHRBehaviorEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.security.Group;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.security.xml.GroupEnumType;

import java.util.Arrays;

//Created: 12-6-2016  R.Blasa

public class NHPTrainingFormType extends TaskForm
{
    public static final String NAME = "NHP Training";

    public NHPTrainingFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "NHP Training", "BSU", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new NHPTrainingFormSection()
        ));


        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/NHPTrainingProperties.js"));

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/ONPRC_TrainingType.js"));


        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("NHPTraining");
        }
    }
    //Added: 11-21-2025  R.Blasa
    @Override
    public boolean isVisible()
    {
        Group g = GroupManager.getGroup(getCtx().getContainer(), "Pairing Observations SF", GroupEnumType.SITE);
        if (g != null && getCtx().getUser().isInGroup(g.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }
        return super.isVisible();
    }
    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRBehaviorEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
