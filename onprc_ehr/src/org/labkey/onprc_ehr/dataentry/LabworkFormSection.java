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
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

/**
 * User: bimber
 * Date: 7/30/13
 * Time: 2:05 PM
 */
public class LabworkFormSection extends SimpleGridPanel
{
    public LabworkFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label, EHRService.FORM_SECTION_LOCATION.Tabs);
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/labworkButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/LabworkChild.js"));
        addConfigSource("LabworkChild");
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("COPYFROMCLINPATHRUNS");
        defaultButtons.addAll(super.getTbarButtons());
        defaultButtons.remove("ADDANIMALS");
        defaultButtons.remove("TEMPLATE");
        if (defaultButtons.contains("ADDRECORD"))
        {
            int idx = defaultButtons.indexOf("ADDRECORD");
            defaultButtons.remove("ADDRECORD");
            defaultButtons.add(idx, "LABWORKADD");
        }

        return defaultButtons;
    }
}
