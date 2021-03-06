/*
 * Copyright (c) 2014 LabKey Corporation
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

import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 1/17/14
 * Time: 3:48 PM
 */
public class GrossFindingsFormPanelSection extends SimpleFormPanelSection
{
    public GrossFindingsFormPanelSection()
    {
        super("study", "grossFindings", "Gross Findings", false);

        addClientDependency(ClientDependency.supplierFromPath("ehr/buttons/encounterButtons.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/EncounterChild.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/window/EncounterAddRecordWindow.js"));

        //Added: 5-17-2018  R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/Gross_Finding.css"));

        addConfigSource("Encounter");
        addConfigSource("EncounterChild");
    }
}
