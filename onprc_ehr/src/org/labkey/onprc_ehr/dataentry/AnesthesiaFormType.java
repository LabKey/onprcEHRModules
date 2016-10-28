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
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**

 */
public class AnesthesiaFormType extends TaskForm
{
    public static final String NAME = "Anesthesia";

    public AnesthesiaFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME + " Monitoring", "Clinical", Arrays.asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "encounters", "Procedures"),
                new AnesthesiaFormSection()
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Anesthesia");
        }

        addClientDependency(ClientDependency.fromPath("ehr/model/sources/Anesthesia.js"));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    public boolean isVisible()
    {
        return false;
    }
}
