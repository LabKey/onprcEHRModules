package org.labkey.onprc_ehr.security;

import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.security.roles.AbstractRole;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 1/7/13
 * Time: 4:53 PM
 */
public class ONPRCBillingAdminRole extends AbstractRole
{
    public ONPRCBillingAdminRole()
    {
        super("ONPRC Billing Admin", "Users with this role are able to make changes to the billing and finance tables", ONPRC_EHRModule.class,
            ReadPermission.class,
            InsertPermission.class,
            UpdatePermission.class,
            DeletePermission.class,
            ONPRCBillingPermission.class
        );
    }
}
