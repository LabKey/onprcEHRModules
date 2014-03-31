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
import org.labkey.api.security.roles.AbstractRole;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

/**

 */
public class ONPRC_EHRCustomerEditRole extends AbstractRole
{
    public ONPRC_EHRCustomerEditRole()
    {
        super("ONPRC EHR Customer Editor", "This role is used to track vets, which grants those users additional editing permissions and is used to populate the table ehr_lookups.veternarians.",
                ReadPermission.class,
                InsertPermission.class,
                UpdatePermission.class,
                DeletePermission.class,
                ONPRC_EHRCustomerEditPermission.class
        );
    }

    @Override
    public boolean isApplicable(SecurityPolicy policy, SecurableResource resource)
    {
        return resource instanceof Container ? ((Container)resource).getActiveModules().contains(ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class)) : false;
    }
}
