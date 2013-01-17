package org.labkey.onprc_ehr.query;

import org.labkey.api.data.SchemaTableInfo;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.Permission;

import java.util.HashMap;
import java.util.Map;

/**
 * Experimental.  This goal is to allow a table to specify an additional permission which is required at insert/update/delete.
 * Table permissions are checked by calling hasPermission(), which tests for a specific Permission, such as InsertPermission, or UpdatePermission.
 * You are able to map an addition permission to any of these, which the user must also have.  Because InsertPermission and UpdatePermission are checked upstream anyway,
 * the user must also have these permissions.  This is just a way of enforcing more refined security, but not completely changing security.
 */
public class CustomPermissionsTable extends SimpleUserSchema.SimpleTable<UserSchema>
{
    private Map<Class<? extends Permission>, Class<? extends Permission>> _permMap = new HashMap<Class<? extends Permission>, Class<? extends Permission>>();

    public CustomPermissionsTable(UserSchema schema, SchemaTableInfo table)
    {
        super(schema, table);
    }

    @Override
    public boolean hasPermission(UserPrincipal user, Class<? extends Permission> perm)
    {
        if (!_userSchema.getContainer().hasPermission(user, perm))
        {
            return false;
        }

        if (_permMap.containsKey(perm))
        {
            return _userSchema.getContainer().hasPermission(user, _permMap.get(perm));
        }

        return true;
    }

    public void addPermissionMapping(Class<? extends Permission> perm1, Class<? extends Permission> perm2)
    {
        _permMap.put(perm1, perm2);
    }
}
