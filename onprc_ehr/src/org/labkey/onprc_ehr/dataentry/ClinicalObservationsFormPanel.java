/*
 * Copyright (c) 2013 LabKey Corporation
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

/**
 * User: bimber
 * Date: 11/16/13
 * Time: 11:42 AM
 */
public class ClinicalObservationsFormPanel extends SimpleFormSection
{
    public ClinicalObservationsFormPanel()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public ClinicalObservationsFormPanel(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Observations", "Observations", "ehr-gridpanel", location);
        addClientDependency(ClientDependency.fromFilePath("ehr/data/ClinicalObservationsClientStore.js"));
        setClientStoreClass("EHR.data.ClinicalObservationsClientStore");
    }
}
