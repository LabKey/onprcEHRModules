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
import org.jetbrains.annotations.Nullable;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.collections.CaseInsensitiveHashSet;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.demographics.AnimalRecord;
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
import org.labkey.api.util.Pair;
import org.labkey.onprc_ehr.ONPRC_EHRManager;
import org.labkey.onprc_ehr.ONPRC_EHRSchema;
import org.labkey.onprc_ehr.dataentry.LabworkRequestFormType;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
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

    private List<Map<String, Object>> _cachedCageSizeRecords = null;
    private Map<String, Map<String, Object>> _cachedRooms = new HashMap<>();
    private Map<Integer, Pair<String, String>> _cachedProtocols = new HashMap<>();
    private Map<String, Map<String, Set<String>>> _cachedHousing = new HashMap<>();
    private Integer _nextProjectId = null;
    private Integer _nextProtocolId = null;

    //NOTE: we probably do not want to cache this outside this transaction, unless we can keep it accurate
    private Map<String, List<CageRecord>> _cachedCages = new HashMap<>();
    private Map<Integer, Boolean> _cachedFrequencies = new HashMap<>();
    private Map<Integer, List<Integer>> _cachedFrequencyTimes = new HashMap<>();
    private Map<String, Integer> _cachedConditionCodes = new HashMap<>();
    private Map<Integer, DividerRecord> _cachedDividerRecords = new HashMap<>();

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

    public String validateCage(String room, String cage)
    {
        List<CageRecord> cages = getCagesForRoom(room);
        for (CageRecord row : cages)
        {
            if (cage.equalsIgnoreCase((String) row.getCage()))
            {
                if (!row.isAvailable())
                {
                    return "This cage is not available based the current cage/divider configuration";
                }
                else if ("Unavailable".equals(row.getStatus()))
                {
                    return "This cage is not available";
                }

                return null;
            }
        }

        return "Unknown cage: " + cage;
    }

    public List<CageRecord> getCagesForRoom(String room)
    {
        List<CageRecord> cages = _cachedCages.get(room);
        if (cages == null)
        {
            final List<CageRecord> ret = new ArrayList<>();
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
                    FieldKey.fromString("availability/isAvailable"),
                    FieldKey.fromString("cagePosition/row"),
                    FieldKey.fromString("cagePosition/columnIdx")
            ));

            TableSelector ts = new TableSelector(cagesTable, cols.values(), new SimpleFilter(FieldKey.fromString("room"), room), new Sort("cagePosition/cage_sortValue"));
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Results results = new ResultsImpl(rs, cols);
                    ret.add(new CageRecord(results));
                }
            });

            _cachedCages.put(room, ret);
        }

        return _cachedCages.get(room);
    }

    private class CageRecord
    {
        private String _room;
        private String _cage;
        private String _cageType;
        private Double _sqFt;
        private Double _height;
        private Integer _divider;
        private String _dividerName;
        private String _status;
        private String _lowerCage;
        private Boolean _isAvailable;
        private Integer _row;
        private Integer _columnIdx;

        public CageRecord(Results results) throws SQLException
        {
            _room = results.getString(FieldKey.fromString("room"));
            _cage = results.getString(FieldKey.fromString("cage"));
            _cageType = results.getString(FieldKey.fromString("cage_type"));
            _sqFt = results.getDouble(FieldKey.fromString("cage_type/sqft"));
            _height = results.getDouble(FieldKey.fromString("cage_type/height"));
            _divider = results.getInt(FieldKey.fromString("divider"));
            _dividerName = results.getString(FieldKey.fromString("divider/divider"));
            _status = results.getString(FieldKey.fromString("status"));
            _lowerCage = results.getString(FieldKey.fromString("availability/lowerCage"));
            _isAvailable = results.getBoolean(FieldKey.fromString("availability/isAvailable"));
            _row = results.getInt(FieldKey.fromString("cagePosition/row"));
            _columnIdx = results.getInt(FieldKey.fromString("cagePosition/columnIdx"));
        }

        private String getRoom()
        {
            return _room;
        }

        private String getCage()
        {
            return _cage;
        }

        private String getCageType()
        {
            return _cageType;
        }

        private Double getSqFt()
        {
            return _sqFt;
        }

        private Double getHeight()
        {
            return _height;
        }

        private Integer getDivider()
        {
            return _divider;
        }

        private String getDividerName()
        {
            return _dividerName;
        }

        private String getStatus()
        {
            return _status;
        }

        private String getLowerCage()
        {
            return _lowerCage;
        }

        private Boolean isAvailable()
        {
            return _isAvailable;
        }

        private Integer getRow()
        {
            return _row;
        }

        private Integer getColumnIdx()
        {
            return _columnIdx;
        }
    }

    private class DividerRecord
    {
        private Integer _rowId;
        private String _divider;
        private Boolean _countAsSeparate;
        private Boolean _countAsPaired;
        private Boolean _isMoveable;

        protected DividerRecord()
        {

        }

        private Integer getRowId()
        {
            return _rowId;
        }

        private void setRowId(Integer rowId)
        {
            _rowId = rowId;
        }

        private String getDivider()
        {
            return _divider;
        }

        private void setDivider(String divider)
        {
            _divider = divider;
        }

        private Boolean getCountAsSeparate()
        {
            return _countAsSeparate;
        }

        private void setCountAsSeparate(Boolean countAsSeparate)
        {
            _countAsSeparate = countAsSeparate;
        }

        private Boolean getCountAsPaired()
        {
            return _countAsPaired;
        }

        private void setCountAsPaired(Boolean countAsPaired)
        {
            _countAsPaired = countAsPaired;
        }

        private Boolean getMoveable()
        {
            return _isMoveable;
        }

        private void setIsMoveable(Boolean moveable)
        {
            _isMoveable = moveable;
        }
    }

    private DividerRecord getDividerRecord(Integer rowid)
    {
        if (_cachedDividerRecords.containsKey(rowid))
        {
            return _cachedDividerRecords.get(rowid);
        }

        TableInfo ti = DbSchema.get("ehr_lookups").getTable("divider_types");
        TableSelector ts = new TableSelector(ti, new SimpleFilter(FieldKey.fromString("rowid"), rowid), null);
        DividerRecord ret = ts.getObject(DividerRecord.class);
        _cachedDividerRecords.put(rowid, ret);

        return ret;
    }

    public CageRecord getCagesRecord(String room, String cage)
    {
        List<CageRecord> cages = getCagesForRoom(room);
        if (cages == null)
            return null;

        for (CageRecord map : cages)
        {
            if (cage.equalsIgnoreCase((String) map.getCage()))
            {
                return map;
            }
        }

        return null;
    }

    public Map<String, Set<String>> getAnimalsInRoom(String room)
    {
        if (_cachedHousing.containsKey(room))
        {
            return _cachedHousing.get(room);
        }

        TableInfo ti = getTableInfo("study", "housing");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("room"), room, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("cage"), room, CompareType.NONBLANK);

        final Map<String, Set<String>> map = new HashMap<>();
        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("Id", "cage"), filter, null);
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                String cage = rs.getString("cage");
                Set<String> set = map.get(cage);
                if (set == null)
                    set = new HashSet<>();

                set.add(rs.getString("Id"));

                map.put(cage, set);
            }
        });

        _cachedHousing.put(room, map);

        return map;
    }

    public String getAnimalsAfterMove(String room, String cage, List<Map<String, Object>> housingRecords)
    {
        if (cage == null)
            return null;

        Map<String, Set<String>> animalMap = getAnimalLocationsAfterMove(room, housingRecords);

        return animalMap.isEmpty() || !animalMap.containsKey(cage) ? null : StringUtils.join(animalMap.get(cage), ";");
    }

    @NotNull
    private Map<String, Set<String>> getAnimalLocationsAfterMove(String room, List<Map<String, Object>> housingRecords)
    {
        Map<String, Set<String>> housingForRoom = getAnimalsInRoom(room);
        if (housingForRoom == null)
            housingForRoom = new HashMap<>();

        Map<String, String> roomMap = new HashMap<>();
        for (String cage : housingForRoom.keySet())
        {
            for (String id : housingForRoom.get(cage))
            {
                roomMap.put(id, cage);
            }
        }

        for (Map<String, Object> row : housingRecords)
        {
            String rowRoom = (String)row.get("room");
            String rowCage = (String)row.get("cage");
            String id = (String)row.get("Id");

            if (row.get("enddate") == null)
            {
                if (room.equalsIgnoreCase(rowRoom))
                {
                    roomMap.put(id, rowCage);
                }
                else
                {
                    roomMap.remove(id);
                }
            }
            else
            {
                //this would include moves out of the selected room
                if (roomMap.containsKey(id))
                {
                    if (!room.equalsIgnoreCase(rowRoom))
                    {
                        roomMap.remove(id);
                    }
                    else
                    {
                        //indicates we terminated a housing record for this location
                        if (roomMap.get(id).equals(rowCage))
                        {
                            roomMap.remove(id);
                        }
                    }
                }
            }
        }

        Map<String, Set<String>> map = new HashMap<>();
        for (String id : roomMap.keySet())
        {
            Set<String> set = map.get(roomMap.get(id));
            if (set == null)
            {
                set = new HashSet<>();
            }

            set.add(id);
            map.put(roomMap.get(id), set);
        }

        return map;
    }

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
        CageRecord cageRow = getCagesRecord(room, cage);
        if (cageRow == null)
            return null;

        List<String> ret = new ArrayList<>();
        Double availableSqFt = cageRow.getSqFt();
        Double availableHeight = cageRow.getHeight();

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

        List<Map<String, Object>> updatedRows = ti.getUpdateService().updateRows(getUser(), getContainer(), Arrays.asList(toUpdate), Arrays.asList(oldKeys), getExtraContext());
        _log.info("transfer request rows updated: " + updatedRows.size());
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

            //look at assignment and copy center resources from dam
            //also breeding groups
            TableInfo assignment = getTableInfo("study", "assignment");
            SimpleFilter assignmentFilter = new SimpleFilter(FieldKey.fromString("Id"), dam);
            assignmentFilter.addCondition(FieldKey.fromString("isActive"), true);
            assignmentFilter.addCondition(FieldKey.fromString("project/displayName"), PageFlowUtil.set(ONPRC_EHRManager.U42_PROJECT, ONPRC_EHRManager.U24_PROJECT), CompareType.IN);

            TableSelector ts3 = new TableSelector(assignment, Collections.singleton("project"), assignmentFilter, null);
            List<Integer> assignmentList = ts3.getArrayList(Integer.class);
            List<Map<String, Object>> assignmentToAdd = new ArrayList<>();
            for (Integer project : assignmentList)
            {
                Map<String, Object> row = new CaseInsensitiveHashMap<>();
                row.put("Id", id);
                row.put("date", date);
                row.put("project", project);
                row.put("assignCondition", getConditionCodeForMeaning("Nonrestricted"));
                row.put("projectedReleaseCondition", getConditionCodeForMeaning("Nonrestricted"));

                assignmentToAdd.add(row);
            }

            assignment.getUpdateService().insertRows(getUser(), getContainer(), assignmentToAdd, new BatchValidationException(), getExtraContext());
        }
    }

    public void updateAnimalCondition(String id, Date enddate, Integer condition) throws BatchValidationException
    {
        TableInfo ti = getTableInfo("ehr_lookups", "animal_condition");
        TableSelector ts = new TableSelector(ti, Collections.singleton("meaning"), new SimpleFilter(FieldKey.fromString("code"), condition), null);
        List<String> ret = ts.getArrayList(String.class);
        if (ret != null && ret.size() == 1)
        {
            EHRService.get().ensureFlagActive(getUser(), getContainer(), "Condition", ret.get(0), enddate, null, Collections.singletonList(id), true);
        }
        else
        {
            _log.error("Unable to find condition matching: " + condition);
        }
    }

    public String verifyProtocolCounts(final String id, Integer project, final List<Map<String, Object>> recordsInTransaction)
    {
        if (id == null)
        {
            return null;
        }

        AnimalRecord ar = EHRDemographicsService.get().getAnimal(getContainer(), id);
        if (ar.getSpecies() == null)
        {
            return "Unknown species: " + id;
        }
        final String species = ar.getSpecies();

        final Pair<String, String> protocolPair = getProtocolForProject(project);
        if (protocolPair == null)
        {
            return "Unable to find protocol associated with project: " + project;
        }

        //find the total animals previously used by this protocols/species
        TableInfo ti = QueryService.get().getUserSchema(getUser(), getContainer(), "ehr").getTable("animalUsage");
        SimpleFilter filter = new SimpleFilter();
        filter.addCondition(FieldKey.fromString("protocol"), protocolPair.first);
        filter.addCondition(FieldKey.fromString("enddateCoalesced"), "+0d", CompareType.DATE_GTE);
        final String MALE_FEMALE = "Male/Female";
        filter.addCondition(FieldKey.fromString("gender"), PageFlowUtil.set(ar.getGenderMeaning(), MALE_FEMALE), CompareType.IN);

        SimpleFilter.OrClause speciesClause = new SimpleFilter.OrClause(new CompareType.EqualsCompareClause(FieldKey.fromString("species"), CompareType.EQUAL, ar.getSpecies()), new CompareType.CompareClause(FieldKey.fromString("species"), CompareType.ISBLANK, null));
        if (species.toUpperCase().contains("MACAQUE"))
        {
            speciesClause.addClause(new CompareType.EqualsCompareClause(FieldKey.fromString("species"), CompareType.EQUAL, "UNIDENTIFIED MACAQUE"));
        }
        filter.addClause(speciesClause);

        TableSelector ts = new TableSelector(ti, filter, null);
        final List<String> errors = new ArrayList<>();
        final List<String> encounteredRows = new ArrayList<>();
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                encounteredRows.add("row");

                Integer allowed = rs.getInt("allowed");
                String gender = rs.getString("gender");
                Set<String> animals = new CaseInsensitiveHashSet();
                String animalString = rs.getString("animals");
                if (animalString != null)
                {
                    animals.addAll(Arrays.asList(StringUtils.split(animalString, ",")));
                }

                animals.add(id);

                if (recordsInTransaction != null && recordsInTransaction.size() > 0)
                {
                    for (Map<String, Object> r : recordsInTransaction)
                    {
                        String id = (String)r.get("Id");
                        Number project = (Number)r.get("project");
                        if (id == null || project == null)
                        {
                            continue;
                        }

                        Pair<String, String> rowProtocol = getProtocolForProject(project.intValue());
                        if (rowProtocol == null || rowProtocol.first == null || !rowProtocol.first.equals(protocolPair.first))
                        {
                            continue;
                        }

                        //find species
                        AnimalRecord ar = EHRDemographicsService.get().getAnimal(getContainer(), id);
                        if (ar == null || ar.getSpecies() == null || !species.equals(ar.getSpecies()))
                        {
                            continue;
                        }

                        //and gender
                        if (ar.getGenderMeaning() == null || (!MALE_FEMALE.equals(gender) && !gender.equals(ar.getGenderMeaning())))
                        {
                            continue;
                        }

                        animals.add(id);
                    }
                }

                Integer remaining = allowed - animals.size();
                if (remaining < 0)
                {
                    errors.add("There are not enough spaces on protocol: " + protocolPair.second + ". Allowed: " + allowed + ", used: " + animals.size());
                }
            }
        });

        if (encounteredRows.isEmpty())
        {
            errors.add("There are no allowable animals matching this species/gender");
        }

        return StringUtils.join(errors, "<>");
    }

    public Pair<String, String> getProtocolForProject(final Integer project)
    {
        if (project == null)
            return null;

        if (!_cachedProtocols.containsKey(project))
        {
            TableInfo ti = getTableInfo("ehr", "project");
            final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, PageFlowUtil.set(FieldKey.fromString("protocol"), FieldKey.fromString("protocol/displayName")));
            TableSelector ts = new TableSelector(ti, cols.values(), new SimpleFilter(FieldKey.fromString("project"), project), null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, cols);
                    if (rs.getString(FieldKey.fromString("protocol")) != null)
                        _cachedProtocols.put(project, Pair.of(rs.getString(FieldKey.fromString("protocol")), rs.getString(FieldKey.fromString("protocol/displayName"))));
                }
            });

            if (!_cachedProtocols.containsKey(project))
                _cachedProtocols.put(project, null);
        }

        return _cachedProtocols.get(project);
    }

    public Integer getConditionCodeForMeaning(final String meaning)
    {
        if (meaning == null)
            return null;

        if (!_cachedConditionCodes.containsKey(meaning))
        {
            TableInfo ti = getTableInfo("ehr_lookups", "animal_condition");
            TableSelector ts = new TableSelector(ti, Collections.singleton("code"), new SimpleFilter(FieldKey.fromString("meaning"), meaning), null);
            List<Integer> ret = ts.getArrayList(Integer.class);
            if (ret != null && !ret.isEmpty())
            {
                _cachedConditionCodes.put(meaning, ret.get(0));
            }
            else
            {
                _cachedConditionCodes.put(meaning, null);
            }
        }

        return _cachedConditionCodes.get(meaning);
    }

    public String validateHousingConditionInsert(String id, String value, String objectId)
    {
        Integer code = getConditionCodeForMeaning(value);
        if (code == null)
            return null;

        Integer oldCode = null;

        //find existing active flags of the same category
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("category"), "Condition");
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id"), id, CompareType.EQUAL);
        //filter.addCondition(FieldKey.fromString("objectid"), objectId, CompareType.NEQ_OR_NULL);

        TableInfo flagsTable = getTableInfo("study", "Animal Record Flags");
        TableSelector ts = new TableSelector(flagsTable, PageFlowUtil.set("value"), filter, null);
        List<String> values = ts.getArrayList(String.class);
        if (values != null && !values.isEmpty())
        {
            for (String v : values)
            {
                oldCode = getConditionCodeForMeaning(v);
                break;
            }
        }

        if (oldCode != null && code < oldCode)
        {
            return "Cannot change condition to a lower code.  Animal is already: " + oldCode;
        }

        return null;
    }

    public String updateDividers(String id, String room, String cage, Integer divider, boolean isValidateOnly, List<Map<String, Object>> rowsInTransaction)
    {
        //first gather all animals currently housed, by cage
        Map<String, Set<String>> animalMap = getAnimalLocationsAfterMove(room, rowsInTransaction);
        Set<String> errors = new HashSet<>();

        //also build list of dividers and changes
        Map<String, Integer> cageDividerMap = new HashMap<>();
        for (CageRecord cageRec : getCagesForRoom(room))
        {
            cageDividerMap.put(cageRec.getCage(), cageRec.getDivider());
        }

        Map<String, Set<Integer>> dividerChanges = new HashMap<>();
        for (Map<String, Object> row : rowsInTransaction)
        {
            if (row.get("cage") == null || row.get("room") == null || !room.equalsIgnoreCase((String) row.get("room")))
                continue;

            String effectiveCage = getEffectiveCageForDivider((String) row.get("room"), (String) row.get("cage"), (Integer) row.get("divider"));
            if (!cageDividerMap.containsKey(effectiveCage))
            {
                _log.error("Unknown cage: " + effectiveCage);
            }
            else if (cageDividerMap.get(effectiveCage).equals(row.get("divider")))
            {
                Set<Integer> changedCages = dividerChanges.get(cage);
                if (changedCages == null)
                    changedCages = new HashSet<>();
                changedCages.add((Integer)row.get("divider"));
                if (changedCages.size() > 1)
                    errors.add("Conflicting divider changes");

                dividerChanges.put(cage, changedCages);
                cageDividerMap.put(cage, (Integer)row.get("divider"));
            }
        }

        return errors.isEmpty() ? null : StringUtils.join(errors, "<>");
    }

    private String getEffectiveCageForDivider(String room, String cage, Integer targetDivider)
    {
        // the purpose is to determine whether we need to adjust the divider toward the right or left
        //
        CageRecord cageRec = getCagesRecord(room, cage);
        return null;
    }

    public Integer getNextProjectId()
    {
        if (_nextProjectId == null)
        {
            SqlSelector ss = new SqlSelector(DbSchema.get("ehr"), "SELECT max(project) as expr FROM ehr.project");
            List<Integer> ret = ss.getArrayList(Integer.class);
            _nextProjectId = ret.isEmpty() ? 0 : ret.get(0);
        }

        _nextProjectId++;

        return _nextProjectId;
    }

    public Integer getNextProtocolId()
    {
        if (_nextProtocolId == null)
        {
            String suffix = "";
            if (DbScope.getLabkeyScope().getSqlDialect().isPostgreSQL())
            {
                suffix = "protocol ~ '^([0-9]+)$";
            }
            else if (DbScope.getLabkeyScope().getSqlDialect().isSqlServer())
            {
                suffix = "protocol NOT LIKE '%[^0-9]%'";
            }
            else
            {
                throw new IllegalArgumentException("ONPRC_EHR Module is only supported on either postgres or sqlserver");
            }

            SqlSelector ss = new SqlSelector(DbSchema.get("ehr"), "SELECT max(CAST(protocol as INTEGER)) as expr FROM ehr.protocol WHERE " + suffix);
            List<Integer> ret = ss.getArrayList(Integer.class);
            _nextProtocolId = ret.isEmpty() ? 0 : ret.get(0);
        }

        _nextProtocolId++;

        return _nextProtocolId;
    }
}
