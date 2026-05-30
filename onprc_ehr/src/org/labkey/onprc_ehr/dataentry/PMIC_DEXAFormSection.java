/*
 * Copyright (c) 2021-2026 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.SimpleGridPanel;

/**
 * User: Kolli
 * Date: 7/7/19
 * Time: 10:36 AM
 */
public class PMIC_DEXAFormSection extends SimpleGridPanel
{
    public PMIC_DEXAFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public PMIC_DEXAFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "PMIC_DEXAImagingData", "DEXA", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PMIC_DEXA.js"));
        addConfigSource("DEXA");
//        _showLocation = true;
    }
}