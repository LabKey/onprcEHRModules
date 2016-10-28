/*
 * Copyright (c) 2014-2016 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class ArrivalFormType extends TaskForm
{
    public static final String NAME = "arrival";

    public ArrivalFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Arrival", "Colony Management", Arrays.asList(
                new LockAnimalsFormSection(),
                new ArrivalInstructionsFormSection(),
                new TaskFormSection(),
                new DocumentArchiveFormSection(),
                new AnimalDetailsFormSection(),
                new NewAnimalFormSection("study", "arrival", "Arrivals", false),
                new WeightFormSection()
        ));

        //setJavascriptClass("ONPRC_EHR.panel.NewAnimalDataEntryPanel");

        //addClientDependency(ClientDependency.fromFilePath("onprc_ehr/panel/NewAnimalDataEntryPanel.js"));
    }

    @Override
    public JSONObject toJSON()
    {
        JSONObject ret = super.toJSON();

        //this form involves extra work on save, so relax warning thresholds to reduce error logging
        ret.put("perRowWarningThreshold", 0.5);
        ret.put("totalTransactionWarningThrehsold", 60);
        ret.put("perRowValidationWarningThrehsold", 6);
        ret.put("totalValidationTransactionWarningThrehsold", 60);
        return ret;
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        List<String> defaultButtons = new ArrayList<String>();

        defaultButtons.add("BIRTHARRIVALFINAL");
        defaultButtons.add("BIRTHARRIVALREVIEW");

        return defaultButtons;
    }

}
