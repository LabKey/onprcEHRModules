/*
 * Copyright (c) 2013-2018 LabKey Corporation
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
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class TreatmentOrdersFormSection extends DrugAdministrationFormSection
{
    public TreatmentOrdersFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public TreatmentOrdersFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super(location, DrugAdministrationFormSection.LABEL, ClientDependency.supplierFromPath("onprc_ehr/window/ONPRC_AddScheduledTreatmentWindow.js"));
        setName("Treatment Orders");
        setLabel("Medication/Treatment Orders");
        setQueryName("Treatment Orders");
        _showAddTreatments = false;

//        Modified: 7-29-2020 Set Remarks information
        setClientStoreClass("ONPRC_EHR.data.TreatmentOrdersClientStore");
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/data/sources/TreatmentOrdersClientStore.js"));

//        Added:3-21-2024  R. Blasa  to override Template menu
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/ApplyTemplateWindow.js"));


    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.remove("SEDATIONHELPER");

        int idx = defaultButtons.indexOf("TEMPLATE");
        assert idx > -1;
        defaultButtons.add(idx+1, "TEMPLATEREV");

        return defaultButtons;
    }

    //Modified: 11-8-2016 R.Blasa
    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();
        defaultButtons.remove("REPEAT_SELECTED");

        return defaultButtons;
    }
}
