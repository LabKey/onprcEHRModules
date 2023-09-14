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
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Supplier;

/**
 * User: bimber
 * Date: 7/30/13
 * Time: 2:05 PM
 */
public class EncounterChildFormSection extends SimpleGridPanel
{
    private final boolean _allowAddDefaults;

    public EncounterChildFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults)
    {
        super(schemaName, queryName, label, EHRService.FORM_SECTION_LOCATION.Tabs);
        _allowAddDefaults = allowAddDefaults;

        addClientDependency(ClientDependency.supplierFromPath("ehr/buttons/encounterButtons.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/EncounterChild.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/window/EncounterAddRecordWindow.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/window/AddProcedureDefaultsWindow.js"));

        addConfigSource("Encounter");
        addConfigSource("EncounterChild");

        setTemplateMode(TEMPLATE_MODE.ENCOUNTER);
    }

    public EncounterChildFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults, String clientStoreClass, List<Supplier<ClientDependency>> extraDependencies, String tabName)
    {
        this(schemaName, queryName, label, allowAddDefaults);
        setClientStoreClass(clientStoreClass);
        for (Supplier<ClientDependency> cd : extraDependencies)
        {
            addClientDependency(cd);
        }

        if (tabName != null)
            setTabName(tabName);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<>();

        if (_allowAddDefaults)
            defaultButtons.add("ADDPROCEDUREDEFAULTS");

        defaultButtons.addAll(super.getTbarButtons());
        defaultButtons.remove("ADDANIMALS");

        if (defaultButtons.contains("ADDRECORD"))
        {
            int idx = defaultButtons.indexOf("ADDRECORD");
            defaultButtons.remove("ADDRECORD");
            defaultButtons.add(idx, "ENCOUNTERADD");
        }

        return defaultButtons;
    }
}
