package org.labkey.onprc_ehr.query;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.util.GUID;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ehr.ONPRC_EHRSchema;
import org.labkey.onprc_ehr.dataentry.LabworkRequestFormType;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * User: bimber
 * Date: 11/26/13
 * Time: 4:07 PM
 */
public class ONPRC_EHRTriggerHelper
{
    private Container _container = null;
    private User _user = null;
    private static final Logger _log = Logger.getLogger(ONPRC_EHRTriggerHelper.class);

    public ONPRC_EHRTriggerHelper(int userId, String containerId)
    {
        _user = UserManager.getUser(userId);
        if (_user == null)
            throw new RuntimeException("User does not exist: " + userId);

        _container = ContainerManager.getForId(containerId);
        if (_container == null)
            throw new RuntimeException("Container does not exist: " + containerId);

    }

    private User getUser()
    {
        return _user;
    }

    private Container getContainer()
    {
        return _container;
    }

    private TableInfo getTableInfo(String schema, String query)
    {
        UserSchema us = QueryService.get().getUserSchema(getUser(), getContainer(), schema);
        if (us == null)
            throw new IllegalArgumentException("Unable to find schema: " + schema);

        TableInfo ti = us.getTable(query);
        if (ti == null)
            throw new IllegalArgumentException("Unable to find table: " + schema + "." + query);

        return ti;
    }

    public Map<String, Object> getExtraContext()
    {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("quickValidation", true);
        map.put("generatedByServer", true);

        return map;
    }

    public void processProjectAccountChange(int project, String newAccount, String oldAccount) throws Exception
    {
        final Date curDate = DateUtils.round(new Date(), Calendar.DATE);
        //final Date prevDate = DateUtils.addDays(curDate, -1);

        //first find any records matching this project/oldAccount
        final TableInfo projAccount = DbSchema.get(ONPRC_EHRSchema.BILLING_SCHEMA_NAME).getTable(ONPRC_EHRSchema.TABLE_PROJECT_ACCOUNT_HISTORY);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("project"), project);
        filter.addCondition(FieldKey.fromString("account"), oldAccount);
        filter.addCondition(new SimpleFilter.OrClause(new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, curDate), new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)));
        TableSelector ts1 = new TableSelector(projAccount, filter, null);
        long found = ts1.getRowCount();
        if (found > 0)
        {
            ts1.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Map<String, Object> toUpdate = new CaseInsensitiveHashMap<>();
                    toUpdate.put("enddate", curDate);
                    Table.update(getUser(), projAccount, toUpdate, rs.getString("rowid"));
                }
            });
        }

        //now add the new record
        Map<String, Object> toInsert = new CaseInsensitiveHashMap<>();
        toInsert.put("project", project);
        toInsert.put("account", newAccount);
        toInsert.put("startdate", curDate);
        Table.insert(getUser(), projAccount, toInsert);
    }
}
