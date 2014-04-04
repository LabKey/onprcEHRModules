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

 */
public class NewAnimalFormSection extends SimpleGridPanel
{
    public NewAnimalFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label);

        addClientDependency(ClientDependency.fromFilePath("ehr/window/AnimalIdSeriesWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/AnimalIdGeneratorField.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaults = super.getTbarButtons();

        int idx = defaults.indexOf("SELECTALL");
        assert idx > -1;
        defaults.add("ANIMAL_ID_SERIES");

        return defaults;
    }
}
