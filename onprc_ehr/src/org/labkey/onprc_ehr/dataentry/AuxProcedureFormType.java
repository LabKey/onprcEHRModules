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
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class AuxProcedureFormType extends TaskForm
{
    public static final String NAME = "Research Procedures";

    public AuxProcedureFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Research", Arrays.asList(
                //Added 2-24-2016  Blasa
            new NonStoreFormSection("Apply Form Template", "Apply Form Template", "onprc-applyformtemplatepanel", Arrays.asList(ClientDependency.fromPath("/onprc_ehr/panel/ApplyFormTemplatePanel.js"))),


            new TaskFormSection(),
            new AnimalDetailsFormSection(),
          //  new SimpleGridPanel("study", "encounters", "Procedures" ),
            new ClinicalEncountersFormSection(),   //Added 5-4-2015  Blasa
            new BloodDrawFormSection(false),
            new WeightFormSection(),
            new DrugAdministrationFormSection(),
            new TreatmentOrdersFormSection()
        ));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("ResearchProcedures");
        }

        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ResearchProcedures.js"));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/window/BulkBloodDrawWindow.js"));
        setDisplayReviewRequired(true);
    }
    //Added 2-24-2016  Blasa
    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        ret.add("APPLYFORMTEMPLATE");

        return ret;
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = super.getMoreActionButtonConfigs();
        defaultButtons.add("COPY_TASK");
        defaultButtons.add("BULK_BLOOD_DRAW");

        return defaultButtons;
    }
}
