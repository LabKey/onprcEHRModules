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

import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 12/2/13
 * Time: 1:12 PM
 */
public class EncounterObservationsFormSection extends EncounterChildFormSection
{
    public EncounterObservationsFormSection()
    {
        super("study", "Clinical Observations", "Observations", false);

        addClientDependency(ClientDependency.fromPath("ehr/data/ClinicalObservationsClientStore.js"));
        setClientStoreClass("EHR.data.ClinicalObservationsClientStore");
        _allowRowEditing = false; //species behavior for value field does not work in forms
    }
}
