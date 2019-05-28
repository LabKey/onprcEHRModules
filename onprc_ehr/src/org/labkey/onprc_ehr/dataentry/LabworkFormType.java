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

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRLabworkEntryPermission;
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
public class LabworkFormType extends TaskForm
{
    public static final String NAME = "Labwork";

    public LabworkFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Lab Results", "Lab Results", Arrays.asList(
                new TaskFormSection(),
                new ClinpathRunsFormSection(false),
                new AnimalDetailsFormSection(),
                new LabworkFormSection("study", "chemistryResults", "Biochemistry", true),
                new LabworkFormSection("study", "hematologyResults", "Hematology", true),
                new LabworkFormSection("study", "microbiology", "Microbiology", true),
                new LabworkFormSection("study", "antibioticSensitivity", "Antibiotic Sensitivity", true),
                new LabworkFormSection("study", "parasitologyResults", "Parasitology", true),
                new LabworkFormSection("study", "serology", "Serology/Virology"),
                new LabworkFormSection("study", "urinalysisResults", "Urinalysis", true),
                new LabworkFormSection("study", "miscTests", "Misc Tests", true)
        ));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("Labwork");
            s.addConfigSource("LabworkPanel");
            s.addConfigSource("LabworkTestPanel");
        }
             //Added 2-2-2016  Blasa
        addClientDependency(ClientDependency.fromPath("onprc_ehr/window/CopyFromRunsTemplateWindow.js"));
            //Added 2-5-2016 Blasa
        addClientDependency(ClientDependency.fromPath("onprc_ehr/model/sources/labworkTestPanel.js"));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/model/sources/labworkPanel.js"));

        addClientDependency(ClientDependency.fromPath("onprc_ehr/buttons/labworkButtons.js"));

        //Added 3-25-2015 Blasa
        addClientDependency(ClientDependency.fromPath("onprc_ehr/window/BulkSerologyVirologyWindow.js"));
        //Added 4-6-2015 Blasa
        addClientDependency(ClientDependency.fromPath("onprc_ehr/window/BulkSerologyScanWindow.js"));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRLabworkEntryPermission.class))
            return false;

        return super.canInsert();
    }

    //Added 3-25-2015 Blasa
    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.addAll(super.getMoreActionButtonConfigs()) ;
        defaultButtons.add("SEROLOGY_IMPORT");
        defaultButtons.add("SEROLOGY_SCAN_IMPORT");

        return defaultButtons;
    }


    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        int idx = ret.indexOf("SUBMIT");
        assert idx > -1;
        ret.remove("SUBMIT");
        if (idx > -1)
            ret.add(idx, "LABWORK_SUBMIT");
        else
            ret.add("LABWORK_SUBMIT");

        return ret;
    }
}
