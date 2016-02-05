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
package org.labkey.onprc_ehr.security;

import org.labkey.api.data.Container;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.ehr.security.EHRVeternarianPermission;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.SecurableResource;
import org.labkey.api.security.SecurityPolicy;
import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.security.roles.AbstractModuleScopedRole;
import org.labkey.api.security.roles.AbstractRole;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

/**

 */
public class ONPRC_EHRCustomerEditRole extends AbstractModuleScopedRole
{
    public ONPRC_EHRCustomerEditRole()
    {
        super("ONPRC EHR Customer Editor", "This role is to track which users can edit the table onprc_ehr.customers.",
                ONPRC_EHRModule.class,
                ReadPermission.class,
                InsertPermission.class,
                UpdatePermission.class,
                DeletePermission.class,
                ONPRC_EHRCustomerEditPermission.class
        );
    }
}
