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

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 1/10/14
 * Time: 10:09 AM
 */
public class EncounterMedicationsFormSection extends EncounterChildFormSection
{
    public EncounterMedicationsFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults)
    {
        super(schemaName, queryName, label, allowAddDefaults);

        setClientStoreClass("EHR.data.DrugAdministrationRunsClientStore");
        addClientDependency(ClientDependency.fromPath("ehr/data/DrugAdministrationRunsClientStore.js"));
        addClientDependency(ClientDependency.fromPath("ehr/window/CopyFromSectionWindow.js"));
        addClientDependency(ClientDependency.fromPath("ehr/window/SedationWindow.js"));
        addClientDependency(ClientDependency.fromPath("ehr/window/DrugAmountWindow.js"));
        addClientDependency(ClientDependency.fromPath("ehr/window/SurgeryPostOpMedsWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        if ("drug".equals(getQueryName()) || "Drug Administration".equals(getQueryName()))
        {
            defaultButtons.add(0, "SEDATIONHELPER");
        }

        defaultButtons.add("DRUGAMOUNTHELPER");

        if ("treatment_orders".equals(getQueryName()) || "Treatment Orders".equals(getQueryName()))
        {
            defaultButtons.add("SURGERYMEDS");
        }

        return defaultButtons;
    }
}
