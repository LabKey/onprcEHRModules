/*
 * Copyright (c) 2016-2017 LabKey Corporation
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

import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.view.template.ClientDependency;

//Added: R.Blasa 5-9-2016
public class AnimalDetailsRoundsFormSection extends NonStoreFormSection
{
    public AnimalDetailsRoundsFormSection()
    {
        //    //Modified 5-4-2016 R.Blasa
        super("AnimalDetails", "Animal Details", "onprc_ehr-animaldetailscasepanel" );

        //Modified 5-4-2016 R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/panel/AnimalDetailsCasePanel.js"));

    }
}
