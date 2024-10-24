/*
 * Copyright (c) 2014-2018 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.dataentry.UnsaveableTask;
import org.labkey.api.module.Module;
import org.labkey.api.security.Group;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.Permission;
import org.labkey.security.xml.GroupEnumType;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class FlagsFormType extends UnsaveableTask
{
    public static final String NAME = "flags";

    public FlagsFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Flags", "Colony Management", Arrays.asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "flags", "Flags")
        ));


    }


    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.add("REVIEW");
        defaultButtons.add("SUBMIT");

        return defaultButtons;
    }

    @Override
    protected boolean canInsert()
    {
        boolean canInsert = true;
        for (FormSection section : getFormSections())
        {
            for (Class<? extends Permission> clazz : getAvailabilityPermissions())
            {
                if (!section.hasPermission(getCtx(), clazz))
                {
                    canInsert = false;
                    break;
                }
            }
        }

        return canInsert;
    }

    //Added: 8-7-2024 R.Blasa
    @Override
    public boolean isVisible()
    {
        Group g = GroupManager.getGroup(getCtx().getContainer(), "Death Entry", GroupEnumType.SITE);
        if (g != null && getCtx().getUser().isInGroup(g.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
        {
            return false;
        }
        return super.isVisible();
    }
}
