/*
 * Copyright (c) 2016-2026 LabKey Corporation
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
package org.labkey.extscheduler.query;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.DefaultQueryUpdateService;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.security.permissions.ReadPermission;

public class ResourcesTable extends FilteredTable<ExtSchedulerQuerySchema>
{
    public ResourcesTable(TableInfo table, ExtSchedulerQuerySchema schema, ContainerFilter cf)
    {
        super(table, schema, cf);
        wrapAllColumns(true);

        if (!getContainer().hasPermission(schema.getUser(), AdminPermission.class))
        {
            setImportURL(AbstractTableInfo.LINK_DISABLER);
            setInsertURL(AbstractTableInfo.LINK_DISABLER);
            setUpdateURL(AbstractTableInfo.LINK_DISABLER);
            setDeleteURL(AbstractTableInfo.LINK_DISABLER);
        }
    }

    @Override
    public boolean hasPermission(@NotNull UserPrincipal user, @NotNull Class<? extends Permission> perm)
    {
        return ReadPermission.class == perm && getContainer().hasPermission(user, perm) ||
                getContainer().hasPermission(user, AdminPermission.class);
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new DefaultQueryUpdateService(this, getRealTable());
    }
}