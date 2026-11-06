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

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class SurgicalAmendedRemarksFormSection extends SimpleFormSection
{
    public SurgicalAmendedRemarksFormSection(String label, EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Remarks", label, "onprc_ehr-surgroundsremarksgridpanel", location);
        addClientDependency(ClientDependency.supplierFromPath("ehr/plugin/ClinicalObservationsCellEditing.js"));    //No changes here.  Not important
        addClientDependency(ClientDependency.supplierFromPath("ehr/panel/ClinicalRemarkPanel.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/SurgicalRoundsRemarksGridPanel.js"));  //points to ONPRC_EHR.plugin.SurgicalRemarksRowEditor
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/ObservationsRowEditorGridPanel.js"));  //Modified //Modified  from ehr to onprc_ehr added new clinical observation columns
//        MOdified: 8-1-2024 so that contents reset as ehr control types
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/plugin/SurgicalRemarksRowEditor.js"));  //edited //edited  points to onprc_ehr.ObservationRowEditorGridPanel.js


        addClientDependency(ClientDependency.supplierFromPath("ehr/data/ClinicalObservationsClientStore.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/buttons/roundsButtons.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/SurgeryEntryField.js"));

        setTemplateMode(TEMPLATE_MODE.NONE);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "ADDSURGICALCASES");
        defaultButtons.add("BULK_CHANGE_CASES");

        return defaultButtons;
    }
}
