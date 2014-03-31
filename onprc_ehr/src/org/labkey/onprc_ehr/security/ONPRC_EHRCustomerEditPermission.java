package org.labkey.onprc_ehr.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**

 */
public class ONPRC_EHRCustomerEditPermission extends AbstractPermission
{
    public ONPRC_EHRCustomerEditPermission()
    {
        super("ONPRC_EHRCustomerEditPermission", "This is the base permission used to control editing of the customers table");
    }
}
