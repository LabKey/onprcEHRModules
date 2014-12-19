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

import java.util.List;

/**
 * User: bimber
 * Date: 11/16/13
 * Time: 11:42 AM
 */
public class ClinicalObservationsFormSection extends SimpleFormSection
{
    private boolean _allowAdd = true;

    public ClinicalObservationsFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body, true);
    }

    public ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        this(location, true);
    }

    public ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION location, boolean allowAdd)
    {
        super("study", "Clinical Observations", "Observations", "ehr-clinicalobservationgridpanel", location);
        addClientDependency(ClientDependency.fromPath("ehr/plugin/ClinicalObservationsCellEditing.js"));
        addClientDependency(ClientDependency.fromPath("ehr/data/ClinicalObservationsClientStore.js"));
        addClientDependency(ClientDependency.fromPath("ehr/grid/ClinicalObservationGridPanel.js"));

        setClientStoreClass("EHR.data.ClinicalObservationsClientStore");

        _allowAdd = allowAdd;
        _allowRowEditing = false; //species behavior for value field does not work in forms
        setAllowBulkAdd(allowAdd);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();

        if (!_allowAdd)
        {
            defaultButtons.remove("ADDRECORD");
        }

        return defaultButtons;
    }
}
