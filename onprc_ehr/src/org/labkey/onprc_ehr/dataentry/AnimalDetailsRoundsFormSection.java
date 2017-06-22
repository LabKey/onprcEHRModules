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

import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.FormElement;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.security.User;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//Added: R.Blasa 5-9-2016
public class AnimalDetailsRoundsFormSection extends NonStoreFormSection
{
    public AnimalDetailsRoundsFormSection()
    {
        //    //Modified 5-4-2016 R.Blasa
        super("AnimalDetails", "Animal Details", "onprc_ehr-animaldetailspanel" );

        //Modified 5-4-2016 R.Blasa
        addClientDependency(ClientDependency.fromPath("onprc_ehr/panel/AnimalDetailsCasePanel.js"));

    }
}
