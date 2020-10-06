
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
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.view.template.ClientDependency;

//Created: 3-30-2017 R.Blasa
public class EncounterProcedureFormSection extends SimpleGridPanel
{
    public EncounterProcedureFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public EncounterProcedureFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "encounters", "Procedures", location);
        //Added 3-30-2017  R.Blasa
        addClientDependency(ClientDependency.fromPath("ehr/data/ClinicalEncountersClientStore.js"));
        setClientStoreClass("EHR.data.ClinicalEncountersClientStore");


    }
}
