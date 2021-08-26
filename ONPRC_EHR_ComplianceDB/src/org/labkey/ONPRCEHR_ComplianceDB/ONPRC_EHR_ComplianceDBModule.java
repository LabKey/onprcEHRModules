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

import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.DefaultDataEntryFormFactory;
import org.labkey.ONPRCEHR_ComplianceDB.dataentry.EmployeeRecordsFormType;
import org.labkey.ONPRCEHR_ComplianceDB.dataentry.EmployeeRequirementCategoryFormType;
import org.labkey.ONPRCEHR_ComplianceDB.dataentry.EmployeeListFormType;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBRole;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.security.roles.RoleManager;

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
        return 20.11;

    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    protected void init()
    {
        addController(CONTROLLER_NAME,ONPRC_EHR_ComplianceDBController.class);

        RoleManager.registerRole(new ONPRC_ComplianceDBRole(ONPRC_EHR_ComplianceDBModule.class));
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {

//        Added: 11-17-2020 R. Blasa
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(EmployeeRecordsFormType.class, this));

       // Added: 7-6-2021 R. Blasa
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(EmployeeRequirementCategoryFormType.class, this));

        // Added: 7-6-2021 R. Blasa
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(EmployeeListFormType.class, this));
    }


}
