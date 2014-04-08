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
import org.jetbrains.annotations.NotNull;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRService;
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
import java.util.HashSet;
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
            // this is a little ugly, but something upstream seems inconsistent about numbers as Integer vs. Double.
            // this is a problem for equals(), so always convert Integers into Doubles
            Object current = row.get(field);
            if (current instanceof Number)
            {
                current = ((Number)current).doubleValue();
            }

            Object old = oldRow.get(field);
            if (old instanceof Number)
            {
                old = ((Number)old).doubleValue();
            }

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
    
    private Map<Integer, List<Integer>> _cachedFrequencyTimes = new HashMap<>();

    private List<Integer> getEarliestFrequencyHours(int frequency)
    {
        if (!_cachedFrequencyTimes.containsKey(frequency))
        {
            TableInfo ti = getTableInfo("ehr_lookups", "treatment_frequency_times");
            TableSelector ts = new TableSelector(ti, PageFlowUtil.set("hourofday"), new SimpleFilter(FieldKey.fromString("frequency/rowid"), frequency), new Sort("hourofday"));
            List<Integer> hours = ts.getArrayList(Integer.class);
            if (!hours.isEmpty())
                Collections.sort(hours);

            _cachedFrequencyTimes.put(frequency, (hours.isEmpty() ? null : hours));
        }

        return _cachedFrequencyTimes.get(frequency);
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

    private Map<Integer, Boolean> _cachedFrequencies = new HashMap<>();

    public boolean isTreatmentFrequencyActive(Integer frequency)
    {
        if (frequency == null)
            return true;
        
        if (!_cachedFrequencies.containsKey(frequency))
        {
            TableInfo ti = getTableInfo("ehr_lookups", "treatment_frequency");
            TableSelector ts = new TableSelector(ti, PageFlowUtil.set("rowid", "active"), new SimpleFilter(FieldKey.fromString("rowid"), frequency), null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    _cachedFrequencies.put(rs.getInt("rowid"), rs.getBoolean("active"));
                }
            });
        }

        return _cachedFrequencies.get(frequency);
    }

    public void cleanTreatmentFrequencyTimes(Integer frequency, String objectid)
    {
        if (frequency == null)
            return;

        if (isTreatmentFrequencyActive(frequency))
        {
            //we no longer support custom treatment times.  therefore if this frequency is active, delete any associated records from that table
            SqlExecutor se = new SqlExecutor(DbSchema.get("ehr"));
            se.execute(new SQLFragment("DELETE FROM ehr.treatment_times WHERE treatmentid = ?", objectid));
        }
    }

    //NOTE: we probably do not want to cache this outside this transaction, unless we can keep it accurate
    private Map<String, List<Map<String, Object>>> _cachedCages = new HashMap<>();

    public String validateCage(String room, String cage)
    {
        List<Map<String, Object>> cages = getCagesForRoom(room);
        for (Map<String, Object> row : cages)
        {
            if (cage.equalsIgnoreCase((String) row.get("cage")))
            {
                if (!(Boolean)row.get("isAvailable"))
                {
                    return "This cage is not available based the current cage/divider configuration";
                }
                else if ("Unavailable".equals(row.get("status")))
                {
                    return "This cage is not available";
                }

                return null;
            }
        }

        return "Unknown cage: " + cage;
    }

    public List<Map<String, Object>> getCagesForRoom(String room)
    {
        List<Map<String, Object>> cages = _cachedCages.get(room);
        if (cages == null)
        {
            final List<Map<String, Object>> ret = new ArrayList<>();
            TableInfo cagesTable = QueryService.get().getUserSchema(getUser(), getContainer(), "ehr_lookups").getTable("cage");
            final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(cagesTable, PageFlowUtil.set(
                    FieldKey.fromString("room"),
                    FieldKey.fromString("cage"),
                    FieldKey.fromString("cage_type"),
                    FieldKey.fromString("cage_type/sqft"),
                    FieldKey.fromString("cage_type/height"),
                    FieldKey.fromString("divider"),
                    FieldKey.fromString("divider/divider"),
                    FieldKey.fromString("status"),
                    FieldKey.fromString("availability/lowerCage"),
                    FieldKey.fromString("availability/isAvailable")
            ));
            TableSelector ts = new TableSelector(cagesTable, cols.values(), new SimpleFilter(FieldKey.fromString("room"), room), null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Results results = new ResultsImpl(rs, cols);
                    Map<String, Object> map = new HashMap<>();
                    map.put("room", results.getString(FieldKey.fromString("room")));
                    map.put("cage", results.getString(FieldKey.fromString("cage")));
                    map.put("cage_type", results.getString(FieldKey.fromString("cage_type")));
                    map.put("sqft", results.getDouble(FieldKey.fromString("cage_type/sqft")));
                    map.put("height", results.getDouble(FieldKey.fromString("cage_type/height")));
                    map.put("divider", results.getInt(FieldKey.fromString("divider")));
                    map.put("dividerType", results.getString(FieldKey.fromString("divider/divider")));
                    map.put("status", results.getString(FieldKey.fromString("status")));
                    map.put("lowerCage", results.getString(FieldKey.fromString("availability/lowerCage")));
                    map.put("isAvailable", results.getBoolean(FieldKey.fromString("availability/isAvailable")));

                    ret.add(map);
                }
            });

            _cachedCages.put(room, ret);
        }

        return _cachedCages.get(room);
    }

    public Map<String, Object> getCagesRecord(String room, String cage)
    {
        List<Map<String, Object>> cages = getCagesForRoom(room);
        if (cages == null)
            return null;

        for (Map<String, Object> map : cages)
        {
            if (cage.equalsIgnoreCase((String) map.get("cage")))
            {
                return map;
            }
        }

        return null;
    }

    public String getAnimalsAfterMove(String room, @NotNull String cage, List<Map<String, Object>> housingRecords)
    {
        TableInfo ti = getTableInfo("study", "housing");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("room"), room, CompareType.EQUAL);
        if (cage != null)
            filter.addCondition(FieldKey.fromString("cage"), cage, CompareType.EQUAL);
        else
            filter.addCondition(FieldKey.fromString("cage"), null, CompareType.ISBLANK);

        TableSelector ts = new TableSelector(ti, Collections.singleton("Id"), filter, null);
        Set<String> ret = new HashSet<>();
        ret.addAll(ts.getCollection(String.class));

        for (Map<String, Object> row : housingRecords)
        {
            if (row.get("enddate") != null)
                continue;

            if (room.equalsIgnoreCase((String)row.get("room")) && cage.equalsIgnoreCase((String)row.get("cage")))
            {
                ret.add((String)row.get("Id"));
            }
            else if (ret.contains(row.get("Id")))
            {
                ret.remove(row.get("Id"));
            }
        }

        return ret.isEmpty() ? null : StringUtils.join(ret, ";");
    }

    private Map<String, Map<String, Object>> _cachedRooms = new HashMap<>();

    private Map<String, Object> getRoomDetails(final String room)
    {
        Map<String, Object> roomObj = _cachedRooms.get(room);
        if (roomObj == null)
        {
            TableInfo roomsTable = QueryService.get().getUserSchema(getUser(), getContainer(), "ehr_lookups").getTable("rooms");
            final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(roomsTable, PageFlowUtil.set(
                    FieldKey.fromString("room"),
                    FieldKey.fromString("area"),
                    FieldKey.fromString("housingType/value"),
                    FieldKey.fromString("housingCondition/value")
            ));
            TableSelector ts = new TableSelector(roomsTable, cols.values(), new SimpleFilter(FieldKey.fromString("room"), room), null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Results results = new ResultsImpl(rs, cols);
                    Map<String, Object> map = new HashMap<>();
                    map.put("room", results.getString(FieldKey.fromString("room")));
                    map.put("area", results.getString(FieldKey.fromString("area")));
                    map.put("housingType", results.getString(FieldKey.fromString("housingType/value")));
                    map.put("housingCondition", results.getString(FieldKey.fromString("housingCondition/value")));

                    _cachedRooms.put(room, map);
                }
            });
        }

        return _cachedRooms.get(room);
    }

    public boolean isCageRequired(String room)
    {
        Map<String, Object> roomMap = getRoomDetails(room);
        if (roomMap != null)
        {
            return "Cage Location".equals(roomMap.get("housingType"));
        }

        return false;
    }

    public List<String> verifyCageSize(String room, String cage, List<Double> weights)
    {
        String setName = "The Guide";
        Map<String, Object> cageRow = getCagesRecord(room, cage);
        if (cageRow == null)
            return null;

        List<String> ret = new ArrayList<>();
        Double availableSqFt = (Double)cageRow.get("sqft");
        Double availableHeight = (Double)cageRow.get("height");

        Double requiredSqFt = 0.0;
        for (Double w : weights)
        {
            Double s = getRequiredCageSize(w, setName);
            if (s != null)
            {
                requiredSqFt += s;
            }
        }

        if (requiredSqFt > availableSqFt)
        {
            ret.add("These animals are too small for the cage.  Has " + Math.round(availableSqFt) + " sq ft. Requires " + Math.round(requiredSqFt) + ".");
        }

        Double maxWeight = weights.isEmpty() ? 0.0 : Collections.max(weights);
        Double requiredHeight = getRequiredCageHeight(maxWeight, setName);
        if (requiredHeight > availableHeight)
        {
            ret.add("The cage does not fit the height requirement.  Has " + Math.round(availableHeight) + " inches. Requires " + requiredHeight + ".");
        }

        return ret;
    }

    private Double getRequiredCageSize(Double weight, String requirementset)
    {
        for (Map<String, Object> row : getCageSizeRecords())
        {
            if (requirementset == null || requirementset.equals(row.get("requirementset")))
            {
                if (weight >= (Double)row.get("low") && weight < (Double)row.get("high"))
                {
                    return (Double)row.get("sqft");
                }
            }
        }

        return null;
    }

    private Double getRequiredCageHeight(Double weight, String requirementset)
    {
        for (Map<String, Object> row : getCageSizeRecords())
        {
            if (requirementset == null || requirementset.equals(row.get("requirementset")))
            {
                if (weight >= (Double)row.get("low") && weight < (Double)row.get("high"))
                {
                    return (Double)row.get("height");
                }
            }
        }

        return null;
    }

    private List<Map<String, Object>> _cachedCageSizeRecords = null;

    private List<Map<String, Object>> getCageSizeRecords()
    {
        if (_cachedCageSizeRecords == null)
        {
            final List<Map<String, Object>> ret = new ArrayList<>();
            TableInfo ti = DbSchema.get("ehr_lookups").getTable("cageclass");
            TableSelector ts = new TableSelector(ti);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Map<String, Object> row = new HashMap<>();
                    row.put("requirementset", rs.getString("requirementset"));
                    row.put("low", rs.getDouble("low"));
                    row.put("high", rs.getDouble("high"));
                    row.put("sqft", rs.getDouble("sqft"));
                    row.put("height", rs.getDouble("height"));

                    ret.add(row);
                }
            });

            _cachedCageSizeRecords = ret;
        }

        return _cachedCageSizeRecords;
    }

    public void markHousingTransfersComplete(String objectid) throws Exception
    {
        TableInfo ti = getTableInfo(ONPRC_EHRSchema.SCHEMA_NAME, ONPRC_EHRSchema.TABLE_HOUSING_TRANFER_REQUESTS);
        Map<String, Object> toUpdate = new CaseInsensitiveHashMap<>();
        toUpdate.put("objectid", objectid);
        toUpdate.put("QCStateLabel", EHRService.QCSTATES.Completed.getLabel());

        Map<String, Object> oldKeys = new CaseInsensitiveHashMap<>();
        oldKeys.put("objectid", objectid);

        List<Map<String, Object>> createdRows = ti.getUpdateService().updateRows(getUser(), getContainer(), Arrays.asList(toUpdate), Arrays.asList(oldKeys), getExtraContext());
        _log.info("Rows updated: " + createdRows.size());
    }

    public String getOverlappingGroupAssignments(String id, String objectid)
    {
        TableInfo ti = getTableInfo("ehr", "animal_group_members");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id"), id, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);

        if (objectid != null)
            filter.addCondition(FieldKey.fromString("objectid"), objectid, CompareType.NEQ_OR_NULL);

        Set<FieldKey> fks = new HashSet<>();
        fks.add(FieldKey.fromString("groupid/name"));
        Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, fks);

        TableSelector ts = new TableSelector(ti, cols.values(), filter, null);
        List<String> ret = ts.getArrayList(String.class);
        if (ret != null && !ret.isEmpty())
        {
            return "Actively assigned to other groups: " + StringUtils.join(ret, ", ");
        }

        return null;
    }

    public void doBirthTriggers(String id, Date date, String dam) throws Exception
    {
        EHRService.get().ensureFlagActive(getUser(), getContainer(), "Condition", "Nonrestricted", date, null, Collections.singletonList(id), false);

        if (dam != null)
        {
            //match SPF status with mother
            TableInfo flags = getTableInfo("study", "flags");
            SimpleFilter flagFilter = new SimpleFilter(FieldKey.fromString("Id"), dam);
            flagFilter.addCondition(FieldKey.fromString("isActive"), true);
            flagFilter.addCondition(FieldKey.fromString("category"), "SPF");

            TableSelector ts = new TableSelector(flags, Collections.singleton("value"), flagFilter, null);
            List<String> flagList = ts.getArrayList(String.class);
            if (flagList != null && flagList.size() == 1)
            {
                EHRService.get().ensureFlagActive(getUser(), getContainer(), "SPF", flagList.get(0), date, null, Collections.singletonList(id), false);
            }

            //also breeding groups
            TableInfo animalGroups = getTableInfo("ehr", "animal_group_members");
            SimpleFilter groupFilter = new SimpleFilter(FieldKey.fromString("Id"), dam);
            groupFilter.addCondition(FieldKey.fromString("isActive"), true);

            TableSelector ts2 = new TableSelector(animalGroups, Collections.singleton("groupId"), groupFilter, null);
            List<Integer> groupList = ts2.getArrayList(Integer.class);
            if (groupList != null && groupList.size() == 1)
            {
                Map<String, Object> row = new CaseInsensitiveHashMap<>();
                row.put("Id", id);
                row.put("date", date);
                row.put("groupId", groupList.get(0));
                row.put("container", getContainer().getId());
                row.put("created", new Date());
                row.put("createdby", getUser().getUserId());
                row.put("modified", new Date());
                row.put("modifiedby", getUser().getUserId());

                animalGroups.getUpdateService().insertRows(getUser(), getContainer(), Arrays.asList(row), new BatchValidationException(), getExtraContext());
            }
        }
    }

    public void updateAnimalCondition(String id, Date date, Integer condition)
    {
        TableInfo ti = getTableInfo("ehr_lookups", "animal_condition");
        TableSelector ts = new TableSelector(ti, Collections.singleton("meaning"), new SimpleFilter(FieldKey.fromString("code"), condition), null);
        List<String> ret = ts.getArrayList(String.class);
        if (ret != null && ret.size() == 1)
        {
            EHRService.get().ensureFlagActive(getUser(), getContainer(), "Condition", ret.get(0), date, null, Collections.singletonList(id), true);
        }
        else
        {
            _log.error("Unable to find condition matching: " + condition);
        }
    }
}
