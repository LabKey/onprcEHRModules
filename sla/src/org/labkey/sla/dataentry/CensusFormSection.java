/*
 * Copyright (c) 2014-2026 LabKey Corporation
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
package org.labkey.sla.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class CensusFormSection extends SimpleFormSection
{
    public CensusFormSection()
    {
        super("sla", "census", "Census", "ehr-gridpanel");
        setTemplateMode(TEMPLATE_MODE.NONE);

        addClientDependency(ClientDependency.supplierFromPath("sla/window/AddCensusWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.addFirst("CENSUS_ADD");
        defaultButtons.remove("ADDANIMALS");

        return defaultButtons;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.remove("GUESSPROJECT");
        defaultButtons.remove("COPY_IDS");

        return defaultButtons;
    }
}
