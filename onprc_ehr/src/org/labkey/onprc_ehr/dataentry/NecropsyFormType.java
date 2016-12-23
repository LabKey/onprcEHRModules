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
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.security.*;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class NecropsyFormType extends EncounterForm
{
    public static final String NAME = "Necropsies";
    public static final String LABEL = "Necropsy";
    public static final String DEFAULT_GROUP = "DCM Pathology";

    public NecropsyFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Pathology", Arrays.asList(
                new NonStoreFormSection("Instructions", "Instructions", "ehr-necropsyinstructionspanel", Arrays.asList(ClientDependency.fromPath("ehr/panel/NecropsyInstructionsPanel.js"))),
                new TaskFormSection(),
                new ClinicalEncountersFormPanelSection("Necropsy"),
                new AnimalDetailsFormSection(),
                new GrossFindingsFormPanelSection(),
                new PathologyFormSection("ehr", "encounter_participants", "Staff"),
                new PathologyNotesFormPanelSection(),
                new PathologyNotesFormPanelSection2(),
                //new PathologyMedicationsFormSection("study", "Drug Administration", "Medications/Treatments"),
                //new PathologyFormSection("study", "tissue_samples", "Tissues/Weights"),
                //new PathologyTissueDistFormSection(),
                //new PathologyFormSection("study", "measurements", "Measurements"),
                new PathologyDiagnosesFormSection("study", "histology", "Histologic Findings"),
                new PathologyDiagnosesFormSection("study", "pathologyDiagnoses", "Diagnoses")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("Pathology");
            s.addConfigSource("Necropsy");
            //Added 5-25-2016 R.Blasa
            s.addConfigSource("Necropsy_Notes");
        }

        addClientDependency(ClientDependency.fromPath("ehr/model/sources/Pathology.js"));
        //Added 5-25-2016 R.Blasa
        addClientDependency(ClientDependency.fromPath("onprc_ehr/model/sources/Pathology_Notes.js"));

        addClientDependency(ClientDependency.fromPath("ehr/model/sources/Necropsy.js"));
        addClientDependency(ClientDependency.fromPath("ehr/form/field/PathologyCaseNoField.js"));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/buttons/pathologyButtons.js"));
        addClientDependency(ClientDependency.fromPath("ehr/window/CopyFromCaseWindow.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.add("COPYFROMCASE");
        ret.add("ENTERDEATH");

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
        UserPrincipal up = org.labkey.api.security.SecurityManager.getPrincipal(DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }

    @Override
    protected Integer getDefaultReviewRequiredPrincipal()
    {
        UserPrincipal up = SecurityManager.getPrincipal(DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
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
