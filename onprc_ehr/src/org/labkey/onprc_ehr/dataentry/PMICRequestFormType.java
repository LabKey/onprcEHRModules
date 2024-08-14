/*
 * Copyright (c) 2013-2016 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.RequestFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

//Created: 5/23/2019 Kollil
public class PMICRequestFormType extends RequestForm
{
    public static final String NAME = "PMIC SERVICES REQUEST";
    public static final String DEFAULT_GROUP = "PMIC Services";

    public PMICRequestFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Requests", Arrays.asList(
                new RequestFormSection(),
                new AnimalDetailsFormSection(),
                new ClinicalEncountersFormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PMIC_Services.js"));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("PMIC_Services");
        }

    }

    //This function has a property that allows to schedule PMIC service requests in future with no num days restriction - By Kollil, 4/20/21
    @Override
    public JSONObject toJSON()
    {
        JSONObject ret = super.toJSON();
        Map<String, Object> map = new HashMap<>();
        map.put("allowRequestsInDistantFuture", true);
        ret.put("extraContext", map);
        return ret;
    }

    //    Added: 8-14-2024  R.Blasa  Allow access only to PMIC Access group.
    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_EHRPMICEditPermission.class))
            return false;

        return super.canInsert();
    }


}