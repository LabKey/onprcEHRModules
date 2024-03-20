/*
 * Copyright (c) 2013-2017 LabKey Corporation
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
package org.labkey.ONPRCEHR_ComplianceDB;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.ONPRCEHR_ComplianceDB.dataentry.EmployeeRequirementCategoryFormType;
import org.labkey.ONPRCEHR_ComplianceDB.dataentry.EmployeeRequirementUnitFormType;
import org.labkey.ONPRCEHR_ComplianceDB.query.ONPRC_EHR_ComplianceDBUserSchema;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBAdminRole;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBEntryPermission;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBRole;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.DefaultDataEntryFormFactory;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.buttons.ShowEditUIButton;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collection;
import java.util.Collections;


//Created: 11-24-2020   R.Blasa

public class ONPRC_EHR_ComplianceDBModule extends ExtendedSimpleModule
{
    public static final String NAME = "ONPRC_EHR_ComplianceDB";
    public static final String CONTROLLER_NAME = "onprc_ehr_compliancedb";


    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public Double getSchemaVersion()
    {
        return 24.002;
    }

    @Override
    public @NotNull Collection<String> getSchemaNames()
    {
        return Collections.singleton(ONPRC_EHR_ComplianceDBSchema.NAME);
    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    @Override
    protected void registerSchemas()
    {
        DefaultSchema.registerProvider(ONPRC_EHR_ComplianceDBSchema.NAME, new DefaultSchema.SchemaProvider(this)
        {
            @Override
            public @Nullable QuerySchema createSchema(final DefaultSchema schema, Module module)
            {
                return new ONPRC_EHR_ComplianceDBUserSchema(schema.getUser(), schema.getContainer());
            }
        });
    }

    protected void init()
    {
        addController(CONTROLLER_NAME,ONPRC_EHR_ComplianceDBController.class);

        RoleManager.registerRole(new ONPRC_ComplianceDBRole(ONPRC_EHR_ComplianceDBModule.class));

        RoleManager.registerRole(new ONPRC_ComplianceDBAdminRole(ONPRC_EHR_ComplianceDBModule.class));
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {

        // Added: 7-6-2021 R. Blasa
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(EmployeeRequirementCategoryFormType.class, this));


        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(EmployeeRequirementUnitFormType.class, this));
        // Added: 7-6-2021 R. Blasa
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("ehr_compliancedb/panel/EnterDataPanel.js"), this);



//               Added: 10-24-2022  R.Blasa
        EHRService.get().registerMoreActionsButton(new ShowEditUIButton(this, "ehr_compliancedb", "completiondates", ONPRC_ComplianceDBEntryPermission.class), "ehr_compliancedb", "completiondates");




    }


}