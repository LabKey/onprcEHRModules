/*
 * Copyright (c) 2016-2018 LabKey Corporation
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

//Created: 19-9-2022 R.Blasa
public class EnvironmentalFormSection extends SimpleGridPanel
{
    public EnvironmentalFormSection()
    {
        super("onprc_ehr", "Environmental_Assessment", "Environmental Assessment");
        setTemplateMode(TEMPLATE_MODE.NONE);
        addExtraProperty(BY_PASS_ANIMAL_ID, "true");

    }
    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.addAll(super.getTbarButtons());

        int idx = 0;
        if (defaultButtons.contains("ADDANIMALS"))
        {
            idx = defaultButtons.indexOf("ADDANIMALS");
            defaultButtons.remove("ADDANIMALS");
        }

        return defaultButtons;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.remove("GUESSPROJECT");
        defaultButtons.remove("COPY_IDS");
        defaultButtons.remove("COPYFROMSECTION");


        return defaultButtons;
    }



}
