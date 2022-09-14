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

import org.json.JSONObject;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.query.FieldKey;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

//Kollil: 10/27/2021. ART Core Misc charges screen
public class ChargesARTCoreFormSection extends SimpleFormSection
{
    public ChargesARTCoreFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public ChargesARTCoreFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("onprc_billing", "miscCharges", "ART Core Charges", "ehr-gridpanel", location);
        setConfigSources(Collections.singletonList("Task"));
        setClientStoreClass("EHR.data.MiscChargesClientStore");
        addClientDependency(ClientDependency.supplierFromPath("ehr/data/MiscChargesClientStore.js"));

        //            Added: 1-19-2018 R.Blasa
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/AddAnimalsWindow.js"));

        addClientDependency(ClientDependency.supplierFromPath("onprc_billing/model/sources/ARTCoreMisc.js"));
        addConfigSource("ARTCoreMisc");

    }

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

//    @Override
//    protected List<FieldKey> getFieldKeys(TableInfo ti)
//    {
//        List<FieldKey> result = super.getFieldKeys(ti);
//
//        result.add(10,FieldKey.fromParts("lineItemTotal"));
//        return result;
//    }


}


