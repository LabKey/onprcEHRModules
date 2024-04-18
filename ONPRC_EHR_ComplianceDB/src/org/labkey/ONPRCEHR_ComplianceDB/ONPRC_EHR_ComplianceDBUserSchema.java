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
package org.labkey.ONPRCEHR_ComplianceDB;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ldk.table.ContainerScopedTable;
import org.labkey.api.ldk.table.CustomPermissionsTable;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBAdminPermission;
import org.labkey.ONPRCEHR_ComplianceDB.security.ONPRC_ComplianceDBEntryPermission;

//Created: R. Blasa 4-18-2024
public class ONPRC_EHR_ComplianceDBUserSchema extends SimpleUserSchema
{
    public ONPRC_EHR_ComplianceDBUserSchema(User user, Container container)
    {
        super(ONPRC_EHR_ComplianceDBSchema.NAME, null, user, container, DbSchema.get(ONPRC_EHR_ComplianceDBSchema.NAME));
    }

    @Override
    @Nullable
    protected TableInfo createWrappedTable(String name, @NotNull TableInfo schemaTable, ContainerFilter cf)
    {
        if (ONPRC_EHR_ComplianceDBSchema.TABLE_EMPLOYEEPERUNIT_DATA.equalsIgnoreCase(name))
        {
            CustomPermissionsTable ti = new CustomPermissionsTable(this, schemaTable, cf).init();
          ti.addPermissionMapping(InsertPermission.class, ONPRC_ComplianceDBEntryPermission.class);
            ti.addPermissionMapping(UpdatePermission.class, ONPRC_ComplianceDBEntryPermission.class);
            ti.addPermissionMapping(DeletePermission.class, ONPRC_ComplianceDBEntryPermission.class);
//           ti.addPermissionMapping(InsertPermission.class, ONPRC_ComplianceDBEntryPermission.class);
//            ti.addPermissionMapping(UpdatePermission.class, ONPRC_ComplianceDBEntryPermission.class);
//            ti.addPermissionMapping(DeletePermission.class, ONPRC_ComplianceDBEntryPermission.class);
            return ti;
        }
        else if (ONPRC_EHR_ComplianceDBSchema.TABLE_COMPLETIONDATES_DATA.equalsIgnoreCase(name))
        {
            CustomPermissionsTable ti = new CustomPermissionsTable(this, schemaTable, cf).init();
            ti.addPermissionMapping(InsertPermission.class,ONPRC_ComplianceDBEntryPermission.class);
            ti.addPermissionMapping(UpdatePermission.class,ONPRC_ComplianceDBEntryPermission.class);
            ti.addPermissionMapping(DeletePermission.class,ONPRC_ComplianceDBEntryPermission.class);
            return ti;
        }


        return super.createWrappedTable(name, schemaTable, cf);
    }
}
