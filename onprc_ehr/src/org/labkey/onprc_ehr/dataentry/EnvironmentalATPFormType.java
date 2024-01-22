
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

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.onprc_ehr.security.ONPRC_EHREnvironmentalPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

//Created: 98-25-2023  R.Blasa

        public class EnvironmentalATPFormType extends TaskForm
        {
        public static final String NAME = "Environmental_ATP";

        public EnvironmentalATPFormType(DataEntryFormContext ctx, Module owner)
        {
            super(ctx, owner, NAME, "Environmental ATP", "Lab Results", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new EnvironmentalATPFormSection()
            ));


            addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/Env_Sanitation_ATP.js"));

            addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/EnvironmentalRecords.js"));

            addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/BulkEnvironmental_ATP_ScanWindow.js"));



        for (FormSection s : this.getFormSections())
        {
              s.addConfigSource("Environmental_ATP");

        }
      }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        int idx = ret.indexOf("SUBMIT");
        assert idx > -1;
        ret.remove("SUBMIT");
        if (idx > -1)
            ret.add(idx, "ENV_RUN");
        else
            ret.add("ENV_RUN");

        int idx2 = ret.indexOf("CLOSE");
        assert idx2 > -1;
        ret.remove("CLOSE");
        if (idx2 > -1)
            ret.add(idx2, "ENV_CLOSE");
        else
            ret.add("ENV_CLOSE");

        return ret;
    };

    //Added 1-19-2024 Blasa
    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.addAll(super.getMoreActionButtonConfigs()) ;
        defaultButtons.add("ENV_ATP_SCAN_IMPORT");

        return defaultButtons;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_EHREnvironmentalPermission.class))
            return false;

        return super.canInsert();
    }

}
