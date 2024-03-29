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

import org.json.JSONObject;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.EncounterForm;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.security.Group;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.PrincipalType;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.security.xml.GroupEnumType;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class BiopsyFormType extends EncounterForm
{
    public static final String NAME = "Biopsy";

    public BiopsyFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Pathology", Arrays.asList(
                new TaskFormSection(),
                new ClinicalEncountersFormPanelSection("Biopsy"),
                new AnimalDetailsFormSection(),
                new PathologyFormSection("ehr", "encounter_participants", "Staff"),
                new PathologyFormSection("study", "tissue_samples", "Tissues/Weights"),
                new PathologyFormSection("study", "measurements", "Measurements"),

//           Added; 2-24-2021  R.Blasa
                new PathologyDiagnosesFormSection("study", "histology", "Histologic Findings"),
                new PathologyDiagnosesFormSection("study", "pathologyDiagnoses", "Diagnoses")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("Pathology");
            s.addConfigSource("Biopsy");
            s.addConfigSource("Biopsy_Staff");
            s.addConfigSource("Biopsy_Notes");
        }

        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/Pathology.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/Biopsy.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/form/field/PathologyCaseNoField.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/buttons/pathologyButtons.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/window/CopyFromCaseWindow.js"));

//        Added: 2-24-2021 R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/BiopsyNotes.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.add("COPYFROMCASE");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRPathologyEntryPermission.class))
            return false;

        return super.canInsert();
    }

    /**
     * The intent is to prevent read access to the majority of users
     */
    @Override
    public boolean canRead()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRPathologyEntryPermission.class))
            return false;

        return super.canRead();
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
    //Modified: 12-3-2019  R.Blasa
    @Override
    public boolean isVisible()
    {
        Group g = GroupManager.getGroup(getCtx().getContainer(), "Pathology External Entry", GroupEnumType.SITE);
        if (g != null && getCtx().getUser().isInGroup(g.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }

        return super.isVisible();
    }

        @Override
    public JSONObject toJSON()
    {
        JSONObject ret = super.toJSON();
        Map<String, Object> map = new HashMap<>();
        map.put("allowDatesInDistantPast", true);
        ret.put("extraContext", map);

        return ret;
    }
}
