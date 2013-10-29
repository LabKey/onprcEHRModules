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
 * Date: 8/23/13
 * Time: 11:32 AM
 */
public class ClinicalEncountersFormSection extends SimpleGridPanel
{
    public ClinicalEncountersFormSection()
    {
        super("study", "encounters", "Procedures", EHRService.FORM_SECTION_LOCATION.Body);
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/surgeryButtons.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.addAll(super.getTbarButtons());

        int idx = 0;
        if (defaultButtons.contains("DELETERECORD"))
        {
            idx = defaultButtons.indexOf("DELETERECORD");
            defaultButtons.remove("DELETERECORD");
        }
        defaultButtons.add(idx, "SURGERYDELETE");

        return defaultButtons;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.add("GUESSPROJECT");

        return defaultButtons;
    }
}
