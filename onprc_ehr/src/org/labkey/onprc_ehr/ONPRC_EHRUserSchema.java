package org.labkey.onprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.ehr.security.EHRRequestPermission;
import org.labkey.api.ehr.security.EHRVeternarianPermission;
import org.labkey.api.ldk.table.CustomPermissionsTable;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.onprc_ehr.security.ONPRC_EHRCustomerEditPermission;

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
        else if (ONPRC_EHRSchema.TABLE_HOUSING_TRANFER_REQUESTS.equalsIgnoreCase(name))
        {
            CustomPermissionsTable ti = new CustomPermissionsTable(this, schemaTable).init();
            ti.addPermissionMapping(InsertPermission.class, EHRRequestPermission.class);
            ti.addPermissionMapping(UpdatePermission.class, EHRRequestPermission.class);
            ti.addPermissionMapping(DeletePermission.class, EHRRequestPermission.class);
            return ti;
        }

        return super.createWrappedTable(name, schemaTable);
    }
}
