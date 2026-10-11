/*
 * Copyright (c) 2024-2026 LabKey Corporation
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
