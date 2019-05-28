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
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRBehaviorEntryPermission;
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
public class BehaviorExamFormType extends TaskForm
{
    @Queryable
    public static final String NAME = "BSU Exam";
    public static final String LABEL = "BSU Exam";

    public BehaviorExamFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "BSU", Arrays.asList(
                new TaskFormSection(),
                new ExtendedAnimalDetailsFormSection(),
                new SimpleFormPanelSection("study", "Clinical Remarks", "SOAP", false, EHRService.FORM_SECTION_LOCATION.Tabs),
                new ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION.Tabs),
                new BSUTreatmentFormSection(EHRService.FORM_SECTION_LOCATION.Tabs)
        ));

        setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NO_ID);

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("BehaviorDefaults");

            if (!s.getName().equals("Clinical Remarks"))
                s.addConfigSource("ClinicalReportChild");

            if (s instanceof SimpleFormSection && !s.getName().equals("tasks"))
                s.setTemplateMode(AbstractFormSection.TEMPLATE_MODE.NO_ID);

            if (s instanceof AbstractFormSection)
            {
                ((AbstractFormSection)s).setAllowBulkAdd(false);
            }
        }

        addClientDependency(ClientDependency.fromPath("ehr/model/sources/BehaviorDefaults.js"));
        setStoreCollectionClass("EHR.data.ClinicalReportStoreCollection");
        addClientDependency(ClientDependency.fromPath("ehr/data/ClinicalReportStoreCollection.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalDefaults.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalReport.js"));
        addClientDependency(ClientDependency.fromPath("ehr/panel/ExamDataEntryPanel.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/ClinicalReportChild.js"));
        setJavascriptClass("EHR.panel.ExamDataEntryPanel");
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        ret.add("OPENBEHAVIORCASE");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRBehaviorEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
