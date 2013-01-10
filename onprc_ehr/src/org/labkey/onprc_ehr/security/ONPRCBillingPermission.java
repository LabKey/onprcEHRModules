package org.labkey.onprc_ehr.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 1/7/13
 * Time: 4:52 PM
 */
public class ONPRCBillingPermission extends AbstractPermission
{
    public ONPRCBillingPermission()
    {
        super("ONPRCBillingPermission", "Can insert and update data in the ONPRC Billing tables");
    }
}
