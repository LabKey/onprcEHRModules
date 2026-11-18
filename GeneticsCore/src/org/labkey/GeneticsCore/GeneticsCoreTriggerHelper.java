/*
 * Copyright (c) 2021-2026 LabKey Corporation
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
package org.labkey.GeneticsCore;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.TableInfo;
import org.labkey.api.gwt.client.AuditBehaviorType;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class GeneticsCoreTriggerHelper
{
    private Container _container;
    private User _user;
    private static final Logger _log = LogManager.getLogger(GeneticsCoreTriggerHelper.class);

    private final String _schema;
    private final String _query;
    private final Map<String, TableInfo> _tableMap = new HashMap<>();

    public GeneticsCoreTriggerHelper(int userId, String containerId, String schema, String query)
    {
        _user = UserManager.getUser(userId);
        if (_user == null)
            throw new RuntimeException("User does not exist: " + userId);

        _container = ContainerManager.getForId(containerId);
        if (_container == null)
            throw new RuntimeException("Container does not exist: " + containerId);

        _schema = schema;
        _query = query;
    }

    public void addAuditForResult(String subjectId, Map<String, Object> existingRow)
    {
        QueryService.get().getDefaultAuditHandler().addAuditEvent(_user, _container, getTable(_schema, _query), AuditBehaviorType.DETAILED, (subjectId == null ? null : "SubjectId: " + subjectId), QueryService.AuditAction.DELETE, Arrays.asList(existingRow), Arrays.asList(existingRow));
    }

    private TableInfo getTable(String schema, String query)
    {
        if (_tableMap.get(query) == null)
        {
            _tableMap.put(query, QueryService.get().getUserSchema(_user, _container, schema).getTable(query));
        }

        return _tableMap.get(query);
    }
}
