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
    private Container _container = null;
    private User _user = null;
    private static final Logger _log = LogManager.getLogger(GeneticsCoreTriggerHelper.class);

    private String _schema;
    private String _query;
    private Map<String, TableInfo> _tableMap = new HashMap<>();

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
