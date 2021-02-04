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
package org.labkey.onprc_billing.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;
import org.json.JSONObject;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;

import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class ChargesFormSection extends SimpleFormSection
{
    public ChargesFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public ChargesFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("onprc_billing", "miscCharges", "Misc. Charges", "ehr-gridpanel", location);
        setConfigSources(Collections.singletonList("Task"));
        setClientStoreClass("EHR.data.MiscChargesClientStore");
        addClientDependency(ClientDependency.supplierFromPath("ehr/data/MiscChargesClientStore.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/data/MiscChargesClientStore.js"));

        //            Added: 1-19-2018 R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/AddAnimalsWindow.js"));

    }
    //            Added: 3-8-2018 R.Blasa
    @Override
    public JSONObject toJSON(DataEntryFormContext ctx, boolean includeFormElements)
    {
        JSONObject jsonObject = super.toJSON(ctx, includeFormElements);
        jsonObject.put("topAndBottomButtons", true);
        return jsonObject;
    }



    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.remove("ADDANIMALS");
        defaultButtons.add(0, "ADDANIMALST");

        return defaultButtons;
    }
}
