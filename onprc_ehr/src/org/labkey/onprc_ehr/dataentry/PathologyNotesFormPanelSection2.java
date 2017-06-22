/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.view.template.ClientDependency;

//Modified 5-24-2016 R.Blasa

public class PathologyNotesFormPanelSection2 extends SimpleFormPanelSection
{
    public PathologyNotesFormPanelSection2()
    {
        super("onprc_ehr", "encounter_summaries_remarks", "Notes-Secondary", false);

        setLocation(EHRService.FORM_SECTION_LOCATION.Tabs);


    }
}
