/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
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
    public static final String NAME = "Clinical Report";
    public static final String LABEL = "Exams/Cases";

    public ClinicalReportFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Clinical", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleFormPanelSection("study", "Clinical Remarks", "SOAP", false),
                new ExtendedAnimalDetailsFormSection(),
                new ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new SimpleGridPanel("study", "encounters", "Procedures", EHRService.FORM_SECTION_LOCATION.Tabs),
                new DrugAdministrationFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new TreatmentOrdersFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new WeightFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new SimpleGridPanel("study", "blood", "Blood Draws", EHRService.FORM_SECTION_LOCATION.Tabs),
                new SimpleGridPanel("ehr", "snomed_tags", "Diagnostic Codes", EHRService.FORM_SECTION_LOCATION.Tabs)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalDefaults");
            s.addConfigSource("ClinicalReport");

            if (!s.getName().equals("Clinical Remarks"))
                s.addConfigSource("ClinicalReportChild");

            if (s instanceof AbstractFormSection)
                ((AbstractFormSection)s).setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NO_ID);
        }

        setStoreCollectionClass("EHR.data.ClinicalReportStoreCollection");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/ClinicalReportStoreCollection.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ClinicalDefaults.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ClinicalReport.js"));

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ClinicalReportChild.js"));
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        int idx = ret.indexOf("SUBMIT");
        assert idx > -1;

        ret.add(idx, "REVIEW");
        ret.add("OPENCLINICALCASE");

        return ret;
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.remove("REVIEW");

        return ret;
    }
}
