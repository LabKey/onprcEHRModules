/*
 * Copyright (c) 2014-2026 LabKey Corporation
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
package org.labkey.sla.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.sla.security.SLAEntryPermission;

import java.util.Arrays;

/**

 */
public class CensusFormType extends TaskForm
{
    public static final String NAME = "SLA Census";

    public CensusFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "SLA", Arrays.asList(
                        new TaskFormSection(),
                        new CensusFormSection())
        );

        addClientDependency(ClientDependency.supplierFromPath("sla/model/sources/SLA.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/ONPRC_ProjectField.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/onprc_SlaCensusConfig.js"));


        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("SLA");
        }
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), SLAEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
