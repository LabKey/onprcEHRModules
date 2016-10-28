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

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.RequestFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class ClinicRequestFormType extends RequestForm
{
    public static final String NAME = "Clinical Services Request";

    public ClinicRequestFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Requests", Arrays.asList(
                new RequestFormSection(),
                //new RequestInstructionsFormSection(),
                new AnimalDetailsFormSection(),
                new BloodDrawFormSection(true),
                new DrugAdministrationRequestFormSection(),
                new SurgeryRequestFormSection()
        ));

        addClientDependency(ClientDependency.fromPath("onprc_ehr/model/sources/Clinical_Services.js"));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("Clinical_Services");
        }
    }
}
