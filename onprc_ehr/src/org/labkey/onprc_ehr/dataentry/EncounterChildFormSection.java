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
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

/**
 * User: bimber
 * Date: 7/30/13
 * Time: 2:05 PM
 */
public class EncounterChildFormSection extends SimpleGridPanel
{
    private boolean _allowAddDefaults;
    private boolean _allowTemplates = false;

    public EncounterChildFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults)
    {
        this(schemaName, queryName, label, allowAddDefaults, false);
    }

    public EncounterChildFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults, boolean allowTemplates)
    {
        super(schemaName, queryName, label, EHRService.FORM_SECTION_LOCATION.Tabs);
        _allowAddDefaults = allowAddDefaults;
        _allowTemplates = allowTemplates;

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/encounterButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/EncounterChild.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SurgeryAddRecordWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromEncountersWindow.js"));

        addConfigSource("Encounter");
        addConfigSource("EncounterChild");

        setTemplateMode(TEMPLATE_MODE.ENCOUNTER);
    }

    public EncounterChildFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults, boolean allowTemplates, String clientStoreClass, List<ClientDependency> extraDependencies, String tabName)
    {
        this(schemaName, queryName, label, allowAddDefaults, allowTemplates);
        setClientStoreClass(clientStoreClass);
        for (ClientDependency cd : extraDependencies)
        {
            addClientDependency(cd);
        }

        if (tabName != null)
            setTabName(tabName);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<String>();

        if (_allowAddDefaults)
            defaultButtons.add("COPYFROMENCOUNTERS");

        defaultButtons.addAll(super.getTbarButtons());
        defaultButtons.remove("ADDANIMALS");

        if (defaultButtons.contains("ADDRECORD"))
        {
            int idx = defaultButtons.indexOf("ADDRECORD");
            defaultButtons.remove("ADDRECORD");
            defaultButtons.add(idx, "SURGERYADD");
        }

        return defaultButtons;
    }
}
