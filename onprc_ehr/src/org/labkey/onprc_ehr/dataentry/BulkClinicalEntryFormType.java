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

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
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
public class BulkClinicalEntryFormType extends TaskForm
{
    public static final String NAME = "Bulk Clinical Entry";

    public BulkClinicalEntryFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Bulk Clinical Entry", "Clinical", Arrays.asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),

                //Added 6-5-2015  Blasa
                new ClinicalEncountersFormSection(),
                new SimpleGridPanel("study", "Clinical Remarks", "SOAPs"),
                new ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION.Body),
                new DrugAdministrationFormSection(),
                new TreatmentOrdersFormSection(),
                new WeightFormSection(),
                new SimpleGridPanel("study", "blood", "Blood Draws"),
                new SimpleGridPanel("ehr", "snomed_tags", "Diagnostic Codes")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalDefaults");
            //Added 6-4-2015 Blasa
            s.addConfigSource("ClinicalProcedures");
        }

        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalDefaults.js"));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/window/MassBleedWindow.js"));
        //Added 1-6-2015 Blasa
       addClientDependency(ClientDependency.fromPath("onprc_ehr/window/BulkStrokeRoundsWindow.js"));
        //Added 6-4-2015 Blasa
        addClientDependency(ClientDependency.fromPath("onprc_ehr/model/sources/ClinicalProcedures.js"));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.addAll(super.getMoreActionButtonConfigs());
        defaultButtons.add("MASS_BLEED");

        // Added 1-6-2015 Blasa
        defaultButtons.add("STROKE_ROUNDS")  ;

        return defaultButtons;
    }
}
