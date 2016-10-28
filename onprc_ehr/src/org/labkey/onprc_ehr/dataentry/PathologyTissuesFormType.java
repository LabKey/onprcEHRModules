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

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.PrincipalType;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class PathologyTissuesFormType extends TaskForm
{
    public static final String NAME = "PathologyTissues";
    public static final String LABEL = "Pathology Tissues";

    public PathologyTissuesFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Pathology", Arrays.asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new DrugAdministrationFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new SimpleFormSection("study", "tissue_samples", "Tissues/Weights", "onprc_ehr-dragdropgridpanel", EHRService.FORM_SECTION_LOCATION.Tabs),
                new TissueDistFormSection(),
                new SimpleFormSection("study", "measurements", "Measurements", "onprc_ehr-dragdropgridpanel", EHRService.FORM_SECTION_LOCATION.Tabs)
        ));

        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
        {
            addSection(new MiscChargesByAccountFormSection(EHRService.FORM_SECTION_LOCATION.Tabs));
        }

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Pathology");
            s.addConfigSource("Necropsy");
        }

        addClientDependency(ClientDependency.fromPath("ehr/model/sources/Pathology.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/Necropsy.js"));
        addClientDependency(ClientDependency.fromPath("ehr/form/field/PathologyCaseNoField.js"));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/buttons/pathologyButtons.js"));
        addClientDependency(ClientDependency.fromPath("ehr/window/CopyFromCaseWindow.js"));

        addClientDependency(ClientDependency.fromPath("onprc_ehr/grid/DragDropGridPanel.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.add("ENTERDEATH_FOR_TISSUES");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRPathologyEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    protected Integer getDefaultAssignedTo()
    {
        UserPrincipal up = org.labkey.api.security.SecurityManager.getPrincipal(NecropsyFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }

    @Override
    protected Integer getDefaultReviewRequiredPrincipal()
    {
        UserPrincipal up = org.labkey.api.security.SecurityManager.getPrincipal(NecropsyFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }
}
