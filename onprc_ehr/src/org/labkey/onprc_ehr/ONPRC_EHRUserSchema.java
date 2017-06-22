/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
package org.labkey.onprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.security.EHRProjectEditPermission;
import org.labkey.onprc_ehr.security.ONPRC_EHRTransferRequestPermission;
import org.labkey.api.ehr.security.EHRVeternarianPermission;
import org.labkey.api.ldk.table.ContainerScopedTable;
import org.labkey.api.ldk.table.CustomPermissionsTable;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.onprc_ehr.security.ONPRC_EHRCustomerEditPermission;
import org.labkey.onprc_ehr.security.ONPRC_EHRCMUAdministrationPermission;

/**

 */
public class ONPRC_EHRUserSchema extends SimpleUserSchema
{
    public ONPRC_EHRUserSchema(User user, Container container)
    {
        super(ONPRC_EHRSchema.SCHEMA_NAME, null, user, container, DbSchema.get(ONPRC_EHRSchema.SCHEMA_NAME));
    }

    @Override
    @Nullable
    protected TableInfo createWrappedTable(String name, @NotNull TableInfo schemaTable)
    {
        if (ONPRC_EHRSchema.TABLE_VET_ASSIGNMENT.equalsIgnoreCase(name))
        {
            CustomPermissionsTable ti = new CustomPermissionsTable(this, schemaTable).init();
          ti.addPermissionMapping(InsertPermission.class, EHRVeternarianPermission.class);
            ti.addPermissionMapping(UpdatePermission.class, EHRVeternarianPermission.class);
            ti.addPermissionMapping(DeletePermission.class, EHRVeternarianPermission.class);
           ti.addPermissionMapping(InsertPermission.class, ONPRC_EHRCMUAdministrationPermission.class);
            ti.addPermissionMapping(UpdatePermission.class, ONPRC_EHRCMUAdministrationPermission.class);
            ti.addPermissionMapping(DeletePermission.class, ONPRC_EHRCMUAdministrationPermission.class);
            return ti;
        }
        else if (ONPRC_EHRSchema.TABLE_CUSTOMERS.equalsIgnoreCase(name))
        {
            CustomPermissionsTable ti = new CustomPermissionsTable(this, schemaTable).init();
            ti.addPermissionMapping(InsertPermission.class, ONPRC_EHRCustomerEditPermission.class);
            ti.addPermissionMapping(UpdatePermission.class, ONPRC_EHRCustomerEditPermission.class);
            ti.addPermissionMapping(DeletePermission.class, ONPRC_EHRCustomerEditPermission.class);
            return ti;
        }
        else if (ONPRC_EHRSchema.TABLE_INVESTIGATORS.equalsIgnoreCase(name))
        {
            CustomPermissionsTable ti = new CustomPermissionsTable(this, schemaTable).init();
            ti.addPermissionMapping(InsertPermission.class, EHRProjectEditPermission.class);
            ti.addPermissionMapping(UpdatePermission.class, EHRProjectEditPermission.class);
            ti.addPermissionMapping(DeletePermission.class, EHRProjectEditPermission.class);
            return ti;
        }
        else if (ONPRC_EHRSchema.TABLE_BIRTH_CONDITION.equalsIgnoreCase(name))
        {
            return new ContainerScopedTable(this, schemaTable, "value").init();
        }
        else if (ONPRC_EHRSchema.TABLE_HOUSING_TRANFER_REQUESTS.equalsIgnoreCase(name))
        {
            CustomPermissionsTable ti = new CustomPermissionsTable(this, schemaTable).init();
            ti.addPermissionMapping(InsertPermission.class, ONPRC_EHRTransferRequestPermission.class);
            ti.addPermissionMapping(UpdatePermission.class, ONPRC_EHRTransferRequestPermission.class);
            ti.addPermissionMapping(DeletePermission.class, ONPRC_EHRTransferRequestPermission.class);
            return ti;
        }

        return super.createWrappedTable(name, schemaTable);
    }
}
