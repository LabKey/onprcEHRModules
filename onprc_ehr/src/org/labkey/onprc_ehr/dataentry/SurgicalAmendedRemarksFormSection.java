/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

// Created: 8-1-2024  R. Blasa
public class SurgicalAmendedRemarksFormSection extends SimpleFormSection
{
    public SurgicalAmendedRemarksFormSection(String label, EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Remarks", label, "onprc_ehr-roundsremarksgridpanel", location);
//        addClientDependency(ClientDependency.supplierFromPath("onpc_ehr/plugin/ClinicalObservationsCellEditing.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/panel/ClinicalRemarkPanel.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/RoundsRemarksGridPanel.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/grid/ObservationsRowEditorGridPanel.js"));
//        MOdified: 8-1-2024 so that contents reset as ehr control types
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/plugin/ClinicalRemarksRowEditor.js"));

        addClientDependency(ClientDependency.supplierFromPath("ehr/data/ClinicalObservationsClientStore.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/buttons/roundsButtons.js"));
//        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/panel/AnimalDetailsExtendedPanel.js"));

        setTemplateMode(TEMPLATE_MODE.NONE);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.remove("COPYFROMSECTION");
        defaultButtons.remove("ADDRECORD");
        defaultButtons.remove("ADDANIMALS");

        if (defaultButtons.contains("DELETERECORD"))
        {
            int idx = defaultButtons.indexOf("DELETERECORD");
            defaultButtons.remove("DELETERECORD");
            defaultButtons.add(idx, "ROUNDSDELETE");
        }

        defaultButtons.add("MARK_ROUNDS_REVIEWED");

        return defaultButtons;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();
        defaultButtons.remove("DUPLICATE");

        return defaultButtons;
    }

    @Override
    public JSONObject toJSON(DataEntryFormContext ctx, boolean includeFormElements)
    {
        JSONObject ret = super.toJSON(ctx, includeFormElements);

        return ret;
    }

    @Override
    protected String getServerSort()
    {
        return "Id/curLocation/room,Id/curLocation/cage,Id";
    }
}
