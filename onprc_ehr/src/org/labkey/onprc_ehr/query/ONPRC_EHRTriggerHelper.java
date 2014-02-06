/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
package org.labkey.onprc_ehr.query;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.study.DataSetTable;
import org.labkey.api.util.GUID;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ehr.ONPRC_EHRManager;
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
import java.util.Set;

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
    private Map<String, TableInfo> _cachedTables = new HashMap<>();

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

    private TableInfo getTableInfo(String schemaName, String queryName)
    {
        String key = schemaName + "||" + queryName;

        if (_cachedTables.containsKey(key))
            return _cachedTables.get(key);

        UserSchema us = QueryService.get().getUserSchema(getUser(), getContainer(), schemaName);
        if (us == null)
        {
            _cachedTables.put(key, null);
            if (us == null)
                throw new IllegalArgumentException("Unable to find schema: " + schemaName);
        }

        TableInfo ti = us.getTable(queryName);
        if (ti == null)
            throw new IllegalArgumentException("Unable to find table: " + schemaName + "." + queryName);

        _cachedTables.put(key, ti);

        return _cachedTables.get(key);
    }

    public Map<String, Object> getExtraContext()
    {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("quickValidation", true);
        map.put("generatedByServer", true);

        return map;
    }

    public Date onTreatmentOrderChange(Map<String, Object> row, Map<String, Object> oldRow) throws Exception
    {
        if (row != null)
        {
            row = new CaseInsensitiveHashMap<>(row);
        }

        if (oldRow != null)
        {
            oldRow = new CaseInsensitiveHashMap<>(oldRow);
        }

        boolean hasChanged = false;
        Set<String> triggersChange = PageFlowUtil.set("code", "frequency", "route", "volume", "vol_units", "amount", "amount_units");
        for (String field : triggersChange)
        {
            Object current = row.get(field);
            Object old = oldRow.get(field);
            if ((current == null && old != null ) || (current != null && old == null ) || (current != null && old != null && !current.equals(old)))
            {
                _log.info("change: " + field);
                hasChanged = true;
            }
        }

        if (hasChanged && hasTreatmentBeenGiven((Date)oldRow.get("date"), (Integer)oldRow.get("frequency")) && !hasTerminated((Date)oldRow.get("enddate")))
        {
            return createUpdatedTreatmentRow(row, oldRow);
        }
        else
        {
            _log.info("no need to update treatment records");
            return null;
        }
    }

    private boolean hasTerminated(Date enddate)
    {
        return !(enddate == null || enddate.after(new Date()));
    }
    private Map<Integer, List<Integer>> _cachedFrequencies = new HashMap<>();

    private List<Integer> getEarliestFrequencyHours(int frequency)
    {
        if (!_cachedFrequencies.containsKey(frequency))
        {
            TableInfo ti = getTableInfo("ehr_lookups", "treatment_frequency_times");
            TableSelector ts = new TableSelector(ti, PageFlowUtil.set("hourofday"), new SimpleFilter(FieldKey.fromString("frequency/rowid"), frequency), new Sort("hourofday"));
            List<Integer> hours = ts.getArrayList(Integer.class);
            if (!hours.isEmpty())
                Collections.sort(hours);

            _cachedFrequencies.put(frequency, (hours.isEmpty() ? null : hours));
        }

        return _cachedFrequencies.get(frequency);
    }

    private boolean hasTreatmentBeenGiven(Date startDate, Integer frequency)
    {
        if (frequency == null)
        {
            return false;
        }

        Date earliestDose = null;

        List<Integer> hours = getEarliestFrequencyHours(frequency);
        if (hours != null)
        {
            for (Integer hour : hours)
            {
                Calendar timeToTest = Calendar.getInstance();
                timeToTest.setTime(startDate);
                timeToTest.set(Calendar.HOUR_OF_DAY, (int) Math.floor(hour / 100));
                timeToTest.set(Calendar.MINUTE, hour % 100);

                if (timeToTest.getTime().getTime() >= startDate.getTime())
                {
                    earliestDose = timeToTest.getTime();
                    break;
                }
            }
        }

        // return true if the earliest expected dose is before now
        return earliestDose == null ? false : earliestDose.before(new Date());
    }

    public Date createUpdatedTreatmentRow(Map<String, Object> row, Map<String, Object> oldRow) throws Exception
    {
        _log.info("creating updated treatment: " + row.get("objectid"));
        Map<String, Object> toCreate = new CaseInsensitiveHashMap<>();
        toCreate.putAll(oldRow);
        toCreate.remove("lsid");

        String originalObjectId = (String)toCreate.get("objectid");
        assert originalObjectId != null;

        String newObjectId = new GUID().toString();
        toCreate.put("objectid", newObjectId);

        //set dates to match
        Date now = new Date();
        toCreate.put("enddate", now);
        row.put("date", now);

        TableInfo treatmentOrders = getTableInfo("study", "Treatment Orders");
        BatchValidationException errors = new BatchValidationException();
        List<Map<String, Object>> createdRows = treatmentOrders.getUpdateService().insertRows(getUser(), getContainer(), Arrays.asList(toCreate), errors, getExtraContext());

        //also update records in drugs table
        if (!createdRows.isEmpty())
        {
            TableInfo drugAdministration = getRealTable(getTableInfo("study", "Drug Administration"));
            SQLFragment sql = new SQLFragment("UPDATE " + drugAdministration.getSelectName() + " SET treatmentid = ? WHERE treatmentid = ?", newObjectId, originalObjectId);
            SqlExecutor se = new SqlExecutor(drugAdministration.getSchema().getScope());
            se.execute(sql);
        }

        return now;
    }

    private TableInfo getRealTable(TableInfo targetTable)
    {
        TableInfo realTable = null;
        if (targetTable instanceof FilteredTable)
        {
            DbSchema dbSchema;
            if (targetTable instanceof DataSetTable)
            {
                Domain domain = ((FilteredTable)targetTable).getDomain();
                if (domain != null)
                {
                    String tableName = domain.getStorageTableName();
                    dbSchema = DbSchema.get("studydataset");
                    realTable = dbSchema.getTable(tableName);
                }
            }
            else if (targetTable.getSchema() != null)
            {
                realTable = targetTable.getSchema().getTable(targetTable.getName());
            }
        }
        return realTable;
    }

    public void replaceSoap(String objectId)
    {
        TableInfo remarks = getRealTable(getTableInfo("study", "Clinical Remarks"));
        SQLFragment sql = new SQLFragment("UPDATE " + remarks.getSelectName() + " SET category = ? WHERE objectid = ?", ONPRC_EHRManager.REPLACED_SOAP, objectId);
        SqlExecutor se = new SqlExecutor(remarks.getSchema().getScope());
        se.execute(sql);
    }
}
