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

import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class ClinicalRoundsRemarksFormSection extends RoundsRemarksFormSection
{
    public ClinicalRoundsRemarksFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public ClinicalRoundsRemarksFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("Remarks", location);
        setConfigSources(Collections.singletonList("Task"));

        addClientDependency(ClientDependency.fromPath("ehr/window/AddClinicalCasesWindow.js"));

        _showLocation = true;
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "ADDCLINICALCASES");

        return defaultButtons;
    }
}
