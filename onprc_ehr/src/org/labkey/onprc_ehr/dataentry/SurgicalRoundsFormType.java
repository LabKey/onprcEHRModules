/*
 * Copyright (c) 2013-2016 LabKey Corporation
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
import org.labkey.api.ehr.security.EHRSurgeryEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.security.PrincipalType;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.security.xml.GroupEnumType;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.Group;
import org.labkey.api.security.permissions.AdminPermission;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class SurgicalRoundsFormType extends TaskForm
{
    public SurgicalRoundsFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, "Surgical Rounds", "Surgical Rounds", "Surgery", Arrays.asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new SurgicalRoundsRemarksFormSection(),
            new ClinicalObservationsFormSection()
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("SurgicalRounds");

            if (s instanceof ClinicalObservationsFormSection)
            {
                ((ClinicalObservationsFormSection)s).setHidden(true);
            }
        }

        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/SurgicalRounds.js"));
        setDisplayReviewRequired(true);
    }

    //Added: 7-26-2018  R.Blasa
    @Override
    public boolean isVisible()
    {
        Group g = GroupManager.getGroup(getCtx().getContainer(), "Surgery Research", GroupEnumType.SITE);
        if (g != null && getCtx().getUser().isInGroup(g.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }
        return super.isVisible();
    }


    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRSurgeryEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    protected Integer getDefaultAssignedTo()
    {
        UserPrincipal up = SecurityManager.getPrincipal(SurgeryFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }

    @Override
    protected Integer getDefaultReviewRequiredPrincipal()
    {
        UserPrincipal up = SecurityManager.getPrincipal(SurgeryFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }
}
