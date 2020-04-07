/*
 * Copyright (c) 2012 LabKey Corporation
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

package org.labkey.GeneticsCore;

import org.jetbrains.annotations.Nullable;
import org.labkey.GeneticsCore.notification.GeneticsCoreNotification;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.clientLibrary.xml.ModeTypeEnum;

public class GeneticsCoreModule extends ExtendedSimpleModule
{
    public static final String NAME = "GeneticsCore";
    public static final String CONTROLLER_NAME = "geneticscore";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public @Nullable Double getSchemaVersion()
    {
        return 17.10;
    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        SimpleButtonConfigFactory btn1 = new SimpleButtonConfigFactory(this, "Add Genetics Blood Draw Flags", "GeneticsCore.buttons.editGeneticsFlagsForSamples(dataRegionName, arguments[0] ? arguments[0].ownerCt : null, 'add')");
        btn1.setClientDependencies(ClientDependency.supplierFromModuleName("laboratory"), ClientDependency.supplierFromModuleName("ehr"), ClientDependency.supplierFromPath("geneticscore/window/ManageFlagsWindow.js", ModeTypeEnum.BOTH), ClientDependency.supplierFromPath("geneticscore/buttons.js", ModeTypeEnum.BOTH));
        LDKService.get().registerQueryButton(btn1, "laboratory", "samples");

        SimpleButtonConfigFactory btn2 = new SimpleButtonConfigFactory(this, "Remove Genetics Blood Draw Flags", "GeneticsCore.buttons.editGeneticsFlagsForSamples(dataRegionName, arguments[0] ? arguments[0].ownerCt : null, 'remove')");
        btn2.setClientDependencies(ClientDependency.supplierFromModuleName("laboratory"), ClientDependency.supplierFromModuleName("ehr"), ClientDependency.supplierFromPath("geneticscore/window/ManageFlagsWindow.js", ModeTypeEnum.BOTH), ClientDependency.supplierFromPath("geneticscore/buttons.js", ModeTypeEnum.BOTH));
        LDKService.get().registerQueryButton(btn2, "laboratory", "samples");

        NotificationService.get().registerNotification(new GeneticsCoreNotification());
    }

    @Override
    protected void init()
    {
        addController(CONTROLLER_NAME, GeneticsCoreController.class);
    }
}
