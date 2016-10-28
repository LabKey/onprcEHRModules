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
import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.ExtendedAnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.query.Queryable;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 12/3/13
 * Time: 8:13 PM
 */
public class ClinicalReportFormType extends TaskForm
{
    @Queryable
    public static final String NAME = "Clinical Report";
    public static final String LABEL = "Exams/Cases";

    public ClinicalReportFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Clinical", Arrays.asList(
                new NonStoreFormSection("Instructions", "Instructions", "ehr-examinstructionspanel", Arrays.asList(ClientDependency.fromPath("ehr/panel/ExamInstructionsPanel.js"))),
                new TaskFormSection(),
                new ExtendedAnimalDetailsFormSection(),
                new SimpleFormPanelSection("study", "Clinical Remarks", "SOAP", false, EHRService.FORM_SECTION_LOCATION.Tabs),
                new ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new SimpleGridPanel("study", "encounters", "Procedures", EHRService.FORM_SECTION_LOCATION.Tabs),
                new WeightFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new DrugAdministrationFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new TreatmentOrdersFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new SimpleGridPanel("study", "blood", "Blood Draws", EHRService.FORM_SECTION_LOCATION.Tabs),
                new SimpleGridPanel("ehr", "snomed_tags", "Diagnostic Codes", EHRService.FORM_SECTION_LOCATION.Tabs),
                //Added 5-23-2015   Blasa
                new SimpleGridPanel("study", "housing", "Housing Transfers",EHRService.FORM_SECTION_LOCATION.Tabs)
                //Removed temporarily  7-2-2015   Blasa
               // new SimpleGridPanel("study", "encounters", "TB Tests",EHRService.FORM_SECTION_LOCATION.Tabs)

        ));

        setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NO_ID);
        setDisplayReviewRequired(true);

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalDefaults");
            s.addConfigSource("ClinicalReport");

            //Removed temporarily  7-2-2015   Blasa
           // s.addConfigSource("TBProcedure");

            if (!s.getName().equals("Clinical Remarks"))
                s.addConfigSource("ClinicalReportChild");

            if (s instanceof SimpleFormSection && !s.getName().equals("tasks"))
                s.setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NO_ID);

            if (s instanceof AbstractFormSection)
            {
                ((AbstractFormSection)s).setAllowBulkAdd(false);
            }
        }

        setStoreCollectionClass("EHR.data.ClinicalReportStoreCollection");
        addClientDependency(ClientDependency.fromPath("ehr/data/ClinicalReportStoreCollection.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalDefaults.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalReport.js"));
        addClientDependency(ClientDependency.fromPath("ehr/panel/ExamDataEntryPanel.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalReportChild.js"));
        setJavascriptClass("EHR.panel.ExamDataEntryPanel");

        //Added 4-3-2015 Blasa
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/panel/HousingDataEntryPanel.js"));
        setJavascriptClass("ONPRC_EHR.panel.HousingDataEntryPanel");

        //Removed temporarily  7-2-2015   Blasa
       // addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/TBProcedure.js"));

    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        ret.add("OPENCLINICALCASE");

        int idx = ret.indexOf("REVIEW");
        assert idx > -1;
        ret.remove("REVIEW");
        if (idx > -1)
            ret.add(idx, "VET_REVIEW");
        else
            ret.add("VET_REVIEW");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
