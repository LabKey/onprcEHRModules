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
package org.labkey.ONPRCEHR_ComplianceDB.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.view.template.ClientDependency;

//import org.labkey.api.ehr.dataentry.SimpleFormSection;

//Created: 7-6-2021  R.Blasa

public class EmployeeListFormSection extends SimpleGridPanel
{
    public EmployeeListFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }


    public EmployeeListFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("ehr_compliancedb", "EmployeePerEssential", "Employee Per Essential");

        _allowRowEditing = false;
        addExtraProperty(BY_PASS_ANIMAL_ID, "true");
        addClientDependency(ClientDependency.supplierFromPath("EHR_ComplianceDB/model/sources/EmployeeClientStore.js"));
        setClientStoreClass("ONPRC_EHR.data.EmployeeClientStore");
    }
}

