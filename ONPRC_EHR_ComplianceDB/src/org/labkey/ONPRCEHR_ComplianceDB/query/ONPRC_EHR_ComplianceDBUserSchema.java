package org.labkey.ONPRCEHR_ComplianceDB.query;

import org.labkey.ONPRCEHR_ComplianceDB.ONPRC_EHR_ComplianceDBSchema;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.ReadPermission;

public class ONPRC_EHR_ComplianceDBUserSchema extends SimpleUserSchema
{
    public ONPRC_EHR_ComplianceDBUserSchema(User user, Container container)
    {
        super(ONPRC_EHR_ComplianceDBSchema.NAME, null, user, container, DbSchema.get(ONPRC_EHR_ComplianceDBSchema.NAME));
    }

    @Override
    public boolean canReadSchema()
    {
        User user = getUser();
        if (user == null)
            return false;

        return getContainer().hasPermission(user, ReadPermission.class);
    }
}
