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
import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;


//Created: 6-27-2019  R.Blasa

public class TBObservationFormSection extends SimpleGridPanel
{
    public TBObservationFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
        setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NONE);
    }

    public TBObservationFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Observations", "TB TST Scores",  location);



    }
}
