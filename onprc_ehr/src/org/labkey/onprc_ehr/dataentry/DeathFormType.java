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

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRCompletedInsertPermission;
import org.labkey.api.ehr.security.EHRSurgeryEntryPermission;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class DeathFormType extends UnsaveableTask
{
    public static final String NAME = "death";

    public DeathFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Death", "Colony Management", Arrays.asList(
                new DeathInstructionsFormSection(),
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "deaths", "Deaths")
        ));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRSurgeryEntryPermission.class))
            return false;

        return EHRService.get().hasPermission("study", "deaths", getCtx().getContainer(), getCtx().getUser(), EHRCompletedInsertPermission.class);
    }
}
