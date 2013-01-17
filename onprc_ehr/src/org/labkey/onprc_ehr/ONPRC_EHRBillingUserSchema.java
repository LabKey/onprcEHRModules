package org.labkey.onprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.SchemaTableInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.onprc_ehr.query.CustomPermissionsTable;
import org.labkey.onprc_ehr.security.ONPRCBillingPermission;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 1/9/13
 * Time: 1:23 PM
 */
public class ONPRC_EHRBillingUserSchema extends SimpleUserSchema
{
    public ONPRC_EHRBillingUserSchema(User user, Container container)
    {
        super(ONPRC_EHRSchema.BILLING_SCHEMA_NAME, null, user, container, DbSchema.get(ONPRC_EHRSchema.BILLING_SCHEMA_NAME));
    }

    @Override
    @Nullable
    protected TableInfo createTable(String name, @NotNull SchemaTableInfo schematable)
    {
        CustomPermissionsTable ti = new CustomPermissionsTable(this, schematable);
        ti.addPermissionMapping(InsertPermission.class, ONPRCBillingPermission.class);
        ti.addPermissionMapping(UpdatePermission.class, ONPRCBillingPermission.class);
        ti.addPermissionMapping(DeletePermission.class, ONPRCBillingPermission.class);

        return ti;
    }

    @Override
    protected boolean canReadSchema()
    {
        User user = getUser();
        if (user == null)
            return false;
        return getContainer().hasPermission(user, ReadPermission.class);
    }
}
