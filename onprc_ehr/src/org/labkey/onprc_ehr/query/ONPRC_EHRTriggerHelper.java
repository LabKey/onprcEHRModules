/*
 * Copyright (c) 2013-2017 LabKey Corporation
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

import org.apache.commons.beanutils.ConversionException;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.collections.CaseInsensitiveHashSet;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.ConvertHelper;
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
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.ehr.EHRQCState;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.demographics.AnimalRecord;
import org.labkey.api.exp.api.StorageProvisioner;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.settings.AppProps;
import org.labkey.api.study.DatasetTable;
import org.labkey.api.study.StudyService;
import org.labkey.api.util.GUID;
import org.labkey.api.util.MailHelper;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.Pair;
//import org.labkey.ehr.demographics.EHRDemographicsServiceImpl;
//import org.labkey.ehr.security.EHRSecurityManager;
import org.labkey.onprc_ehr.ONPRC_EHRManager;
import org.labkey.onprc_ehr.ONPRC_EHRModule;
import org.labkey.onprc_ehr.ONPRC_EHRSchema;
import org.labkey.onprc_ehr.notification.CullListNotification;
import org.labkey.onprc_ehr.notification.MensesTMBNotification;
import org.labkey.onprc_ehr.notification.ProtocolAlertsNotification;

import javax.mail.Address;
import javax.mail.Message;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
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
import java.util.TreeMap;

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
    private Map<Integer, String> _cachedProcedureCategories = new HashMap<>();
    private Map<String, Boolean> _cachedBirthConditions = null;

    private Integer _nextProjectId = null;
    private Integer _nextProtocolId = null;


    //NOTE: we probably do not want to cache this outside this transaction, unless we can keep it accurate
    private Map<String, List<CageRecord>> _cachedCages = new HashMap<>();
    private Map<Integer, Boolean> _cachedFrequencies = new HashMap<>();
    private Map<Integer, List<Integer>> _cachedFrequencyTimes = new HashMap<>();
    private Map<String, Integer> _cachedConditionCodes = new HashMap<>();
    private Map<String, Integer> _cachedConditionCodeMeanings = new HashMap<>();
    private Map<Integer, DividerRecord> _cachedDividerRecords = new HashMap<>();

    private static final String NONRESTRICTED = "Nonrestricted";
    private static final String EXPERIMENTAL_EUTHANASIA = "EUTHANASIA, EXPERIMENTAL";


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
            else if (current instanceof String)
            {
                current = StringUtils.trimToNull((String)current);
            }

            Object old = oldRow.get(field);
            if (old instanceof Number)
            {
                old = ((Number)old).doubleValue();
            }
            else if (old instanceof String)
            {
                old = StringUtils.trimToNull((String)old);
            }

            if ((current == null && old != null ) || (current != null && old != null && !current.equals(old)))
            {
                _log.info("change: " + field);
                hasChanged = true;
            }
            // filling in units after the fact has been causing some unnecessary splitting of records.
            // it is unlikely any record w/ a previous null value for any of the fields being tested would represent a genuine need to split records.
            // if code, frequency, route, etc were originally null and then filled out, we're not contradicting previous information.  most of these can never be null anyway.
            //else if (current != null && old == null)
            //{
            //    _log.info("change: " + field);
            //    hasChanged = true;
            //}
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
        List<Map<String, Object>> createdRows = treatmentOrders.getUpdateService().insertRows(getUser(), getContainer(), Arrays.asList(toCreate), errors, null, getExtraContext());

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
            if (targetTable instanceof DatasetTable)
            {
                Domain domain = targetTable.getDomain();
                if (domain != null)
                {
                    realTable = StorageProvisioner.createTableInfo(domain);
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

        if (!_cachedFrequencies.containsKey(frequency))
        {
            _log.error("unknown treatment frequency: " + frequency);
            return false;
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

    public String validateCage(String room, String cage, boolean hasDivider)
    {
        List<CageRecord> cages = getCagesForRoom(room);
        for (CageRecord row : cages)
        {
            if (cage.equalsIgnoreCase(row.getCage()))
            {
                if (!row.isAvailable() && !hasDivider)
                {
                    return "This cage is not available based the current cage/divider configuration";
                }
                else if ("Unavailable".equals(row.getStatus()))
                {
                    return "This cage has been flagged as Unavailable/Reserved";
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
                    FieldKey.fromString("cage_type/cageslots"),
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

    public static class CageRecord
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
        private String _row;
        private Integer _columnIdx;
        private Integer _cageslots;

        public CageRecord(Results results) throws SQLException
        {
            _room = results.getString(FieldKey.fromString("room"));
            _cage = results.getString(FieldKey.fromString("cage"));
            _cageType = results.getString(FieldKey.fromString("cage_type"));
            _sqFt = results.getDouble(FieldKey.fromString("cage_type/sqft"));
            _height = results.getDouble(FieldKey.fromString("cage_type/height"));
            _cageslots = results.getInt(FieldKey.fromString("cage_type/cageslots"));
            _divider = results.getInt(FieldKey.fromString("divider"));
            _dividerName = results.getString(FieldKey.fromString("divider/divider"));
            _status = results.getString(FieldKey.fromString("status"));
            _lowerCage = results.getString(FieldKey.fromString("availability/lowerCage"));
            _isAvailable = results.getBoolean(FieldKey.fromString("availability/isAvailable"));
            _row = results.getString(FieldKey.fromString("cagePosition/row"));
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

        private String getRow()
        {
            return _row;
        }

        private Integer getColumnIdx()
        {
            return _columnIdx;
        }

        private Boolean getAvailable()
        {
            return _isAvailable;
        }

        private Integer getCageslots()
        {
            return _cageslots;
        }
    }

    public static class DividerRecord
    {
        private Integer _rowId;
        private String _divider;
        private Boolean _countAsSeparate;
        private Boolean _countAsPaired;
        private Boolean _isMoveable;

        public DividerRecord()
        {

        }

        public Integer getRowId()
        {
            return _rowId;
        }

        public void setRowId(Integer rowId)
        {
            _rowId = rowId;
        }

        public String getDivider()
        {
            return _divider;
        }

        public void setDivider(String divider)
        {
            _divider = divider;
        }

        public Boolean getCountAsSeparate()
        {
            return _countAsSeparate;
        }

        public void setCountAsSeparate(Boolean countAsSeparate)
        {
            _countAsSeparate = countAsSeparate;
        }

        public Boolean getCountAsPaired()
        {
            return _countAsPaired;
        }

        public void setCountAsPaired(Boolean countAsPaired)
        {
            _countAsPaired = countAsPaired;
        }

        public Boolean getMoveable()
        {
            return _isMoveable;
        }

        public void setIsMoveable(Boolean moveable)
        {
            _isMoveable = moveable;
        }

        public void setMoveable(Boolean moveable)
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
            if (cage.equalsIgnoreCase(map.getCage()))
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
                    FieldKey.fromString("housingCondition/value"),
                    FieldKey.fromString("housingType"),
                    FieldKey.fromString("housingCondition")
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
                    map.put("housingTypeInt", results.getInt(FieldKey.fromString("housingType")));
                    map.put("housingConditionInt", results.getInt(FieldKey.fromString("housingCondition")));

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
            //TODO: the surgery exclusion is a bit of a hack.  would be nice to handle this in the room definition table
            return "Cage Location".equals(roomMap.get("housingType")) && !"Surgery".equalsIgnoreCase(room);
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

    public Integer getHousingType(String room)
    {
        Map<String, Object> roomRec = getRoomDetails(room);
        if (roomRec == null)
            return null;

        return (Integer)roomRec.get("housingTypeInt");
    }

    public Integer getHousingCondition(String room)
    {
        Map<String, Object> roomRec = getRoomDetails(room);
        if (roomRec == null)
            return null;

        return (Integer)roomRec.get("housingConditionInt");
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

    public void markHousingTransferRequestsComplete(String objectid) throws Exception
    {
        TableInfo ti = getTableInfo(ONPRC_EHRSchema.SCHEMA_NAME, ONPRC_EHRSchema.TABLE_HOUSING_TRANFER_REQUESTS);
        Map<String, Object> toUpdate = new CaseInsensitiveHashMap<>();
        toUpdate.put("objectid", objectid);
        toUpdate.put("QCStateLabel", EHRService.QCSTATES.Completed.getLabel());

        Map<String, Object> oldKeys = new CaseInsensitiveHashMap<>();
        oldKeys.put("objectid", objectid);

        List<Map<String, Object>> updatedRows = ti.getUpdateService().updateRows(getUser(), getContainer(), Arrays.asList(toUpdate), Arrays.asList(oldKeys), null, getExtraContext());
        _log.info("transfer request rows updated: " + updatedRows.size());
    }

    public String getOverlappingGroupAssignments(String id, String objectid)
    {
        TableInfo ti = getTableInfo("study", "animal_group_members");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id"), id, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);

        if (!StringUtils.isEmpty(objectid))
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

    // search by either code or value
    private String getFlag(String category, String value, Integer code, boolean activeOnly)
    {
        TableInfo flagValues = getTableInfo("ehr_lookups", "flag_values");
        SimpleFilter flagFilter = new SimpleFilter(FieldKey.fromString("category"), category);

        if (value != null)
            flagFilter.addCondition(FieldKey.fromString("value"), value);

        if (code != null)
            flagFilter.addCondition(FieldKey.fromString("code"), code);

        if (activeOnly)
            flagFilter.addCondition(FieldKey.fromString("datedisabled"), null, CompareType.ISBLANK);

        TableSelector ts = new TableSelector(flagValues, Collections.singleton("objectid"), flagFilter, null);

        List<String> ret = ts.getArrayList(String.class);
        if (ret == null || ret.isEmpty())
        {
            return null;
        }
        else if (ret.size() > 1)
        {
            _log.error("duplicate flags found for: " + category + " / " + value);
        }

        return ret.get(0);
    }

    // Taken from DateUtils.  should remove if we upgrade core
    private Date maxDate(Date d1, Date d2) {
        if (d1 == null && d2 == null) return null;
        if (d1 == null) return d2;
        if (d2 == null) return d1;
        return (d1.after(d2)) ? d1 : d2;
    }

    public void closeActiveAssignmentRecords(String id, Date deathDate, String causeOfDeath) throws Exception
    {
        try
        {
            TableInfo assignmentTable = getTableInfo("study", "assignment");
            SimpleFilter filter1 = new SimpleFilter(FieldKey.fromString("Id"), id);
            filter1.addCondition(new SimpleFilter.OrClause(new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GT, deathDate), new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)));

            TableSelector ts1 = new TableSelector(assignmentTable, PageFlowUtil.set("lsid", "projectedReleaseCondition"), filter1, null);
            List<Map> rowMaps = ts1.getArrayList(Map.class);
            if (!rowMaps.isEmpty())
            {
                final Integer terminalCode = getConditionCodeForMeaning("Terminal");

                List<Map<String, Object>> toEnd = new ArrayList<>();
                List<Map<String, Object>> toEndKeys = new ArrayList<>();
                for (Map<String, Object> rowMap : rowMaps)
                {
                    CaseInsensitiveHashMap row = new CaseInsensitiveHashMap();
                    row.put("lsid", rowMap.get("lsid"));
                    row.put("enddate", deathDate);



                    //Modified: 6-28-2016 R.Blasa     All experimetal and Euthenized  cause of death are automitaclly assigned 206 at  release
                    if (EXPERIMENTAL_EUTHANASIA.equals(causeOfDeath) )
                    {

                            row.put("releaseCondition", 206);

                    }

                    toEnd.add(row);

                    CaseInsensitiveHashMap keyRow = new CaseInsensitiveHashMap();
                    keyRow.put("lsid", rowMap.get("lsid"));
                    toEndKeys.add(keyRow);
                }

                //terminate rows
                if (!toEnd.isEmpty())
                {
                    _log.info("ending " + toEnd.size() + " assignments due to animal death on: " + deathDate.toString());
                    assignmentTable.getUpdateService().updateRows(getUser(), getContainer(), toEnd, toEndKeys, null, getExtraContext());
                }
            }
        }
        catch (Exception e)
        {
            _log.error(e.getMessage(), e);
            throw e;
        }
    }

    //Added on 10/5/2016, L.Kolli
    public Map<String, Object> onAnimalArrival_AddDemographics(String id, Map<String, Object> row) throws QueryUpdateServiceException, DuplicateKeyException, SQLException, BatchValidationException
    {
        Map<String, Object> demographicsProps = new HashMap<String, Object>();

        for (String key : new String[]{"Id", "gender", "species", "dam", "sire", "origin", "source", "geographic_origin", "birth"})
        {
            if (row.containsKey(key))
            {
                demographicsProps.put(key, row.get(key));
            }
        }

        //allow the potential for entry without birth date
        demographicsProps.put("date", row.get("birth") != null ? row.get("birth") : row.get("date"));
        demographicsProps.put("calculated_status", "Alive");
        //createDemographicsRecord(id, demographicsProps);
        return demographicsProps;
    }

    //Modified: 10-13-2016 R.Blasa  to include passign Arrival date
    public void doBirthTriggers(String id, Date date, String dam, Date flagStartDate, String birthCondition, boolean isBecomingPublic) throws Exception
    {
        //is the infant is dead, terminate the assignments
        Date enddate = isBirthAlive(birthCondition) ? null : date;

        //also check for a pre-existing death record:
        Date deathDate = new TableSelector(getTableInfo("study", "deaths"), Collections.singleton("date"), new SimpleFilter(FieldKey.fromString("Id"), id), null).getObject(Date.class);
        if (deathDate != null)
        {
            enddate = deathDate;
        }

        //note: we only want this to run the first time this record becomes public, not on subsequent updates
        if (isBecomingPublic)
        {
            String nonRestrictedFlag = getFlag("Condition", NONRESTRICTED, null, true);
            if (nonRestrictedFlag != null)
            {
                if (flagStartDate == null)
                {
                    flagStartDate = date;
                }

                //only add initial status if born alive
                EHRService.get().ensureFlagActive(getUser(), getContainer(), nonRestrictedFlag, flagStartDate, enddate, null, Collections.singletonList(id), false);
            }
            else
            {
                _log.warn("Unable to find active flag for condition nonrestricted");
            }
        }

        //NOTE: we allow this to run the first time this record is public with a non-null dam.  this allows the record to be created without dam, then updated
        if (dam != null)
        {
            //match SPF status with mother
            TableInfo flags = getTableInfo("study", "flags");
            SimpleFilter flagFilter = new SimpleFilter(FieldKey.fromString("Id"), dam);
            //Note: match DOB, not current date
            flagFilter.addCondition(FieldKey.fromString("date"), date, CompareType.DATE_LTE);
            flagFilter.addClause(new SimpleFilter.OrClause(
                    new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, date),
                    new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)
            ));
            flagFilter.addCondition(FieldKey.fromString("flag/category"), "SPF");

            TableSelector ts = new TableSelector(flags, Collections.singleton("flag"), flagFilter, null);
            List<String> flagList = ts.getArrayList(String.class);
            if (flagList.size() == 1)
            {
                EHRService.get().ensureFlagActive(getUser(), getContainer(), flagList.get(0), date, enddate, null, Collections.singletonList(id), false);
            }
            else if (flagList.size() > 1)
            {
                _log.error("dam has more than 1 active SPF flag: " + dam);
            }

            //also breeding groups
            TableInfo animalGroups = getTableInfo("study", "animal_group_members");
            SimpleFilter groupFilter = new SimpleFilter(FieldKey.fromString("Id"), dam);
            //Note: match DOB, not current date
            groupFilter.addCondition(FieldKey.fromString("date"), date, CompareType.DATE_LTE);
            groupFilter.addClause(new SimpleFilter.OrClause(
                    new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, date),
                    new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)
            ));

            TableSelector ts2 = new TableSelector(animalGroups, Collections.singleton("groupid"), groupFilter, null);
            List<Integer> groupList = ts2.getArrayList(Integer.class);
            if (groupList.size() == 1)
            {
                SimpleFilter groupFilter2 = new SimpleFilter(FieldKey.fromString("Id"), id);
                //Note: match DOB, not current date
                groupFilter2.addCondition(FieldKey.fromString("date"), date, CompareType.DATE_LTE);
                groupFilter2.addClause(new SimpleFilter.OrClause(
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, date),
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)
                ));
                groupFilter2.addCondition(FieldKey.fromString("groupid"), groupList.get(0));
                TableSelector existingGroupTs = new TableSelector(animalGroups, Collections.singleton("groupid"), groupFilter2, null);
                if (existingGroupTs.exists())
                {
                    _log.info("infant: " + id + " is already assigned to animal group " + groupList.get(0) + ", so birth trigger will not re-add");
                }
                else
                {
                    _log.info("adding animal group " + groupList.get(0) + " to infant: " + id + ", based on dam: " + dam);
                    Map<String, Object> row = new CaseInsensitiveHashMap<>();
                    row.put("Id", id);
                    row.put("date", date);
                    row.put("enddate", enddate);
                    row.put("groupid", groupList.get(0));
                    row.put("objectid", new GUID().toString());

                    BatchValidationException errors = new BatchValidationException();
                    animalGroups.getUpdateService().insertRows(getUser(), getContainer(), Arrays.asList(row), errors, null, getExtraContext());
                    if (errors.hasErrors())
                    {
                        _log.error(errors.getMessage(), errors);
                    }
                }
            }

            //look at assignment and copy center resources from dam
            TableInfo assignment = getTableInfo("study", "assignment");
            SimpleFilter assignmentFilter = new SimpleFilter(FieldKey.fromString("Id"), dam);
            //Note: match DOB, not current date
            assignmentFilter.addCondition(FieldKey.fromString("date"), date, CompareType.DATE_LTE);
            assignmentFilter.addClause(new SimpleFilter.OrClause(
                    new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, date),
                    new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)
            ));
            assignmentFilter.addCondition(FieldKey.fromString("project/displayName"), PageFlowUtil.set(ONPRC_EHRManager.U42_PROJECT, ONPRC_EHRManager.U24_PROJECT), CompareType.IN);

            TableSelector ts3 = new TableSelector(assignment, Collections.singleton("project"), assignmentFilter, null);
            List<Integer> assignmentList = ts3.getArrayList(Integer.class);
            if (!assignmentList.isEmpty())
            {
                //check for existing assignments for this animal
                SimpleFilter existingAssignFilter = new SimpleFilter(FieldKey.fromString("Id"), id);
                //Note: match DOB, not current date
                existingAssignFilter.addCondition(FieldKey.fromString("date"), date, CompareType.DATE_LTE);
                existingAssignFilter.addClause(new SimpleFilter.OrClause(
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, date),
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)
                ));
                existingAssignFilter.addCondition(FieldKey.fromString("project"), assignmentList, CompareType.IN);
                TableSelector existingAssignTs = new TableSelector(assignment, Collections.singleton("project"), existingAssignFilter, null);
                List<Integer> existingAssignmentList = existingAssignTs.getArrayList(Integer.class);

                List<Map<String, Object>> assignmentToAdd = new ArrayList<>();
                for (Integer project : assignmentList)
                {
                    if (existingAssignmentList.contains(project))
                    {
                        _log.info(id + " is already assigned to project " + project + ", so it will not be reassigned in birth trigger");
                        continue;
                    }

                    _log.info("adding assignment for project " + project + " to infant: " + id + ", based on dam: " + dam);
                    Map<String, Object> row = new CaseInsensitiveHashMap<>();
                    row.put("Id", id);
                    row.put("date", date);
                    row.put("enddate", enddate);
                    row.put("project", project);
                    row.put("assignCondition", getConditionCodeForMeaning(NONRESTRICTED));
                    row.put("projectedReleaseCondition", getConditionCodeForMeaning(NONRESTRICTED));
                    if (enddate != null)
                    {
                        row.put("releaseCondition", getConditionCodeForMeaning(NONRESTRICTED));
                    }

                    assignmentToAdd.add(row);
                }

                BatchValidationException errors = new BatchValidationException();
                assignment.getUpdateService().insertRows(getUser(), getContainer(), assignmentToAdd, errors, null, getExtraContext());
                if (errors.hasErrors())
                {
                    _log.error(errors.getMessage(), errors);
                }
            }
        }
    }

    private List<Integer> findHigherActiveConditonCodes(String id, Date date, final Integer targetCondition)
    {
        TableInfo flagTable = getTableInfo("study", "flags");
        SimpleFilter flagFilter = new SimpleFilter(FieldKey.fromString("Id"), id);
        flagFilter.addCondition(new SimpleFilter.OrClause(new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, date), new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)));
        flagFilter.addCondition(FieldKey.fromString("flag/category"), "Condition");

        final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(flagTable, PageFlowUtil.set(FieldKey.fromString("flag/value"), FieldKey.fromString("flag/code")));
        TableSelector flagTs = new TableSelector(flagTable, colMap.values(), flagFilter, null);
        final List<Integer> foundCodes = new ArrayList<>();
        if (flagTs.exists())
        {
            flagTs.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, colMap);
                    if (rs.getObject(FieldKey.fromString("flag/code")) != null)
                    {
                        Integer codeInt = rs.getInt(FieldKey.fromString("flag/code"));
                        if (codeInt > targetCondition)
                        {
                            foundCodes.add(codeInt);
                        }
                    }
                }
            });
        }

        return foundCodes;
    }

    public String checkForConditionDowngrade(String id, Date date, final Integer condition)
    {
        List<Integer> foundCodes = findHigherActiveConditonCodes(id, date, condition);
        if (!foundCodes.isEmpty())
        {
            return "Animal already has a higher condition code (" + (StringUtils.join(foundCodes, ","))+ "), cannot choose a lower code unless the existing code is removed or disabled";
        }

        return null;
    }

    public void updateAnimalCondition(String id, Date enddate, final Integer condition) throws BatchValidationException
    {
        //if the animal already has an active higher code, dont attmept to downgrade
        List<Integer> foundCodes = findHigherActiveConditonCodes(id, enddate, condition);
        if (foundCodes.isEmpty())
        {
            String flag = getFlag("Condition", null, condition, true);
            if (flag != null)
            {
                EHRService.get().ensureFlagActive(getUser(), getContainer(), flag, enddate, null, Collections.singletonList(id), true);
            }
            else
            {
                _log.error("Unable to find condition matching: " + condition);
            }
        }
    }

    public String verifyProtocolCounts(final String id, Integer project, Date assignDate, final List<Map<String, Object>> recordsInTransaction)
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
        //note: support assignment dates in the future
        filter.addClause(new SimpleFilter.OrClause(
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, assignDate),
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null)
        ));
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

    public boolean isBirthAlive(String condition)
    {
        if (condition == null)
        {
            return true;
        }

        if (_cachedBirthConditions == null)
        {
            _cachedBirthConditions = new HashMap<>();

            TableInfo ti = getTableInfo("onprc_ehr", "birth_condition");
            TableSelector ts = new TableSelector(ti);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    if (rs.getString("value") != null && rs.getObject("alive") != null)
                    {
                        _cachedBirthConditions.put(rs.getString("value"), rs.getBoolean("alive"));
                    }
                }
            });
        }

        return _cachedBirthConditions.containsKey(condition) ? _cachedBirthConditions.get(condition) : true;
    }

    public Integer getConditionCodeByFlag(final String flag)
    {
        if (flag == null)
            return null;

        if (!_cachedConditionCodes.containsKey(flag))
        {
            TableInfo ti = getTableInfo("ehr_lookups", "flag_values");
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("objectid"), flag);
            filter.addCondition(FieldKey.fromString("category"), "Condition");
            TableSelector ts = new TableSelector(ti, Collections.singleton("code"), filter, null);
            List<Integer> ret = ts.getArrayList(Integer.class);
            if (ret != null && !ret.isEmpty())
            {
                _cachedConditionCodes.put(flag, ret.get(0));
            }
            else
            {
                _cachedConditionCodes.put(flag, null);
            }
        }

        return _cachedConditionCodes.get(flag);
    }

    public Integer getConditionCodeForMeaning(final String meaning)
    {
        if (meaning == null)
            return null;

        if (!_cachedConditionCodeMeanings.containsKey(meaning))
        {
            TableInfo ti = getTableInfo("ehr_lookups", "flag_values");
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("value"), meaning);
            filter.addCondition(FieldKey.fromString("category"), "Condition");
            TableSelector ts = new TableSelector(ti, Collections.singleton("code"), filter, null);
            List<Integer> ret = ts.getArrayList(Integer.class);
            if (ret != null && !ret.isEmpty())
            {
                _cachedConditionCodeMeanings.put(meaning, ret.get(0));
            }
            else
            {
                _cachedConditionCodeMeanings.put(meaning, null);
            }
        }

        return _cachedConditionCodeMeanings.get(meaning);
    }

    /**
     * This will ensure we do not downgrade the condition code for an animal
     */
    public String validateHousingConditionInsert(String id, String flag, String objectId)
    {
        //NOTE: there is no good way to test whether this flag has category=Condition, so test all
        Integer code = getConditionCodeByFlag(flag);
        if (code == null)
            return null;

        Integer oldCode = null;

        //find existing active flags of the same category
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("flag/category"), "Condition");
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("Id"), id, CompareType.EQUAL);

        TableInfo flagsTable = getTableInfo("study", "Animal Record Flags");
        TableSelector ts = new TableSelector(flagsTable, PageFlowUtil.set("flag"), filter, null);
        List<String> values = ts.getArrayList(String.class);
        if (values != null && !values.isEmpty())
        {
            for (String v : values)
            {
                oldCode = getConditionCodeByFlag(v);
                break;
            }
        }

        if (oldCode != null && code < oldCode)
        {
            return "Cannot change condition to a lower code.  Animal is already: " + oldCode;
        }

        return null;
    }

    public String updateDividers(String id, String room, String cage, Integer divider, boolean isValidateOnly, List<Map<String, Object>> rowsInTransaction) throws Exception
    {
        CageRecord cr = getCagesRecord(room, cage);
        if (cr == null)
        {
            return "Unknown cage: " + cage;
        }

        if (cr.getCageslots() != 2)
        {
            return "Divider changes are only supported for doubles";
        }

        DividerRecord targetDivider = getDividerRecord(divider);
        if (targetDivider == null)
        {
            _log.error("Unknown divider: " + divider);
            return null;
        }

        //first gather all animals currently housed, by cage
        //Map<String, Set<String>> animalMap = getAnimalLocationsAfterMove(room, rowsInTransaction);
        Set<String> errors = new HashSet<>();

        //also build list of existing dividers and changes
        Map<String, Integer> cageDividerMap = new HashMap<>();
        Map<String, Integer> dividerChanges = new HashMap<>();
        for (CageRecord cageRec : getCagesForRoom(room))
        {
            cageDividerMap.put(cageRec.getCage(), cageRec.getDivider());
        }

        //then any changes
        String lowestCage = getLowestCageForUnit(room, cage);
        if (!cageDividerMap.containsKey(lowestCage))
        {
            _log.error("Unknown cage: " + lowestCage);
            return null;
        }

        //we always want to change the divider associated with the lower cage
        if (!targetDivider.getRowId().equals(cageDividerMap.get(lowestCage)))
        {
            dividerChanges.put(lowestCage, targetDivider.getRowId());
        }

        for (String changingCage : dividerChanges.keySet())
        {
            _log.info("Divider change: " + changingCage + " / " + dividerChanges.get(changingCage));
            if (isValidateOnly)
            {
                errors.add("This will change the divider for cage: " + changingCage);
            }
            else
            {
                changeDivider(room, changingCage, dividerChanges.get(changingCage));
            }
        }

        return errors.isEmpty() ? null : StringUtils.join(errors, "<>");
    }

    private void changeDivider(String room, String cage, Integer divider) throws Exception
    {
        TableInfo cageTable = getTableInfo("ehr_lookups", "cage");
        List<Map<String, Object>> rows = new ArrayList<>();
        List<Map<String, Object>> oldKeys = new ArrayList<>();

        String location = room + "-" + cage;
        Map<String, Object> row = new CaseInsensitiveHashMap<>();
        row.put("location", location);
        row.put("divider", divider);
        rows.add(row);

        Map<String, Object> keyRow = new CaseInsensitiveHashMap<>();
        keyRow.put("location", location);
        oldKeys.add(keyRow);

        cageTable.getUpdateService().updateRows(getUser(), getContainer(), rows, oldKeys, null, getExtraContext());
    }

    // returns the lowest cage for this unit, based on cage slots
    private String getLowestCageForUnit(String room, String cage)
    {
        // the purpose is to determine whether we need to adjust the divider toward the right or left
        CageRecord cageRec = getCagesRecord(room, cage);

        Map<Integer, CageRecord> cagesInRow = new TreeMap<>();
        for (CageRecord cr : getCagesForRoom(room))
        {
            if (cr.getRow() != null && cr.getRow().equals(cageRec.getRow()))
            {
                cagesInRow.put(cr.getColumnIdx(), cr);
            }
        }

        // iterate the row to determine the lowest cage of this unit
        // currently we assume the cage in question is a double, but there may be other cages below it
        int positionInCage = 0;
        CageRecord lowestCage = null;
        for (Integer col : cagesInRow.keySet())
        {
            if (lowestCage == null || positionInCage % lowestCage.getCageslots() == 0)
            {
                lowestCage = cagesInRow.get(col);
            }

            if (col == cageRec.getColumnIdx())
            {
                break;
            }

            positionInCage++;
        }

        if (lowestCage == null)
        {
            _log.error("unable to find effective cage for: " + cageRec.getCage());
            return null;
        }

        _log.info("original cage: " + cageRec.getCage() + ", effective: " + lowestCage.getCage());

        return lowestCage.getCage();
    }

    public Integer getNextProjectId()
    {
        if (_nextProjectId == null)
        {
            SqlSelector ss = new SqlSelector(DbSchema.get("ehr"), "SELECT COALESCE(max(project), 0) as expr FROM ehr.project");
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
            if (DbScope.getLabKeyScope().getSqlDialect().isPostgreSQL())
            {
                suffix = "protocol ~ '^([0-9]+)$'";
            }
            else if (DbScope.getLabKeyScope().getSqlDialect().isSqlServer())
            {
                suffix = "protocol NOT LIKE '%[^0-9]%'";
            }
            else
            {
                throw new IllegalArgumentException("ONPRC_EHR Module is only supported on either postgres or sqlserver");
            }

            SqlSelector ss = new SqlSelector(DbSchema.get("ehr"), "SELECT COALESCE(max(CAST(protocol as INTEGER)), 0) as expr FROM ehr.protocol WHERE " + suffix);
            List<Integer> ret = ss.getArrayList(Integer.class);
            _nextProtocolId = ret.isEmpty() ? 0 : ret.get(0);
        }

        _nextProtocolId++;

        return _nextProtocolId;
    }

    public boolean requiresAssistingStaff(Object procedureText)
    {
        if (procedureText == null)
        {
            return false;
        }

        try
        {
            Integer procedureId = ConvertHelper.convert(procedureText, Integer.class);
            if (!_cachedProcedureCategories.containsKey(procedureId))
            {
                TableInfo ti = getTableInfo("ehr_lookups", "procedures");
                TableSelector ts = new TableSelector(ti, PageFlowUtil.set("category"), new SimpleFilter(FieldKey.fromString("rowid"), procedureId), null);
                String category = ts.getObject(String.class);

                _cachedProcedureCategories.put(procedureId, category);
            }

            String category = _cachedProcedureCategories.get(procedureId);

            return "Surgery".equals(category);
        }
        catch (ConversionException e)
        {
            _log.warn("unable to convert procedureId to integer: [" + procedureText + "]", new Exception());
        }

        return false;
    }

    public String getSpeciesForDam(String dam)
    {
        return new TableSelector(getTableInfo("study", "demographics"), PageFlowUtil.set("species"), new SimpleFilter(FieldKey.fromString("Id"), dam), null).getObject(String.class);
    }

    public String getGeographicOriginForDam(String dam)
    {
        return new TableSelector(getTableInfo("study", "demographics"), PageFlowUtil.set("geographic_origin"), new SimpleFilter(FieldKey.fromString("Id"), dam), null).getObject(String.class);
    }

    public void ensureQuarantineFlag(String id, Date date) throws BatchValidationException
    {
        String flag = getFlag("Surveillance", "Quarantine", null, true);
        if (flag != null)
        {
            EHRService.get().ensureFlagActive(getUser(), getContainer(), flag, date, null, Collections.singletonList(id), false);
        }
        else
        {
            _log.warn("Unable to find active flag for Surveillance/Quarantine");
        }
    }

    public String validateObservation(String category, String observation)
    {
        if (category == null || observation == null)
        {
            return null;
        }

        Set<String> allowable = getAllowableObservations(category);

        //NOTE: this this has an empty set, assume anything is allowed
        if (!allowable.isEmpty() && !allowable.contains(observation))
        {
            return "The observation: " + observation + " is not allowed for " + category;
        }

        return null;
    }

    private Map<String, Set<String>> _cachedObservations = new HashMap<>();

    private @NotNull Set<String> getAllowableObservations(String category)
    {
        if (!_cachedObservations.containsKey(category))
        {
            TableInfo ti = getTableInfo("ehr", "observation_types");
            TableSelector ts = new TableSelector(ti, PageFlowUtil.set("schemaName", "queryName", "valuecolumn"), new SimpleFilter(FieldKey.fromString("value"), category), null);
            Map<String, Object> record = ts.getMap();

            Set<String> allowable;
            if (record != null && record.get("schemaname") != null && record.get("queryname") != null && record.get("valuecolumn") != null)
            {
                TableInfo valuesTable = getTableInfo((String)record.get("schemaname"), (String)record.get("queryname"));
                if (valuesTable != null)
                {
                    allowable = new CaseInsensitiveHashSet();
                    TableSelector ts2 = new TableSelector(valuesTable, PageFlowUtil.set((String)record.get("valuecolumn")), null, null);
                    allowable.addAll(ts2.getArrayList(String.class));
                }
                else
                {
                    allowable = Collections.emptySet();
                }
            }
            else
            {
                allowable = Collections.emptySet();
            }

            _cachedObservations.put(category, allowable);
        }

        return _cachedObservations.get(category);
    }

    public void updateParentage(String id, String parent, String relationship, String method)
    {
        Set<String> allowableMethods = new CaseInsensitiveHashSet("Genetic", "Provisional Genetic");
        if (!allowableMethods.contains(method))
        {
            return;
        }

        String targetField;
        switch (relationship)
        {
            case "Dam":
                targetField = "dam";
                break;
            case "Sire":
                targetField = "sire";
                break;
            default:
                return;
        }

        String existingDemographicsVal = new TableSelector(getTableInfo("study", "demographics"), PageFlowUtil.set(targetField), new SimpleFilter(FieldKey.fromString("Id"), id), null).getObject(String.class);
        if (parent.equals(existingDemographicsVal))
        {
            _log.info("updating " + targetField + " on demographics for animal: " + id + " from parentage");
        }

    }

    public String validateCaseNo(String caseNo, String type, String objectid)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("caseno"), caseNo);
        filter.addCondition(FieldKey.fromString("type"), type);
        if (objectid != null)
        {
            filter.addCondition(FieldKey.fromString("objectid"), objectid, CompareType.NEQ_OR_NULL);
        }

        if (new TableSelector(getTableInfo("study", "encounters"), filter, null).exists())
        {
            return "There is already an existing case with the number: " + caseNo;
        }


        return null;
    }

    //Added 1-12-2016 Blasa
    public void sendMenseNotifications(String id)
    {
        boolean _isType207 = false;

        if (!NotificationService.get().isServiceEnabled())
        {
            _log.info("notification service is not enabled, will not send Menses notification.");
            return;
        }

        String subject = "Menses TMB Notification: ";

        Set<UserPrincipal> recipients = NotificationService.get().getRecipients(new MensesTMBNotification(ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class)), getContainer());

        if (recipients.size() == 0)
        {
            _log.warn("No recipients, Menses TMB notification");
            return;
        }

        final StringBuilder html = new StringBuilder();

        html.append("<b>Recently Updated TMB Menses Observations:</b><p>");
        TableInfo ti = getTableInfo("study", "clinical_observations");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("id"), id);
        filter.addCondition(FieldKey.fromString("category"), "Menses", CompareType.EQUAL);   // Menses

        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("category"), filter, null);  // Menses
        List<String> ret = ts.getArrayList(String.class);

        if (ret != null && !ret.isEmpty())
        {
            TableInfo t2 = getTableInfo("study", "assignment");
            SimpleFilter filters = new SimpleFilter(FieldKey.fromString("id"), id);
            filters.addCondition(FieldKey.fromString("project"), 559, CompareType.EQUAL);   // Breeders   Center Project 0300
            filters.addCondition(FieldKey.fromString("enddateCoalesced"), new Date(), CompareType.DATE_GTE);
            TableSelector ts2 = new TableSelector(t2, PageFlowUtil.set("project"), filters, null);  //
            List<Integer> ret2 = ts2.getArrayList(Integer.class);

            if (ret2 != null && !ret2.isEmpty())
            {
                for (Integer jcode : ret2)
                {
                    //Iacuc 0300 Project Id 559
                    if (jcode == 559)
                    {
                        html.append(id + "<p> ");

                        //Provide url link to allow users to view Menses report
                        html.append("<a href='" + AppProps.getInstance().getBaseServerUrl() + "/ehr/ONPRC/EHR/animalHistory.view#subjects:" + id + "&inputType:singleSubject&showReport:1&activeReport:menses" + "'>");
                        html.append("Click here to view Menses Report</a>.  <p>");
                        sendMessage(subject, html.toString(), recipients);
                    }
                    break;
                }
            }

        }
    }



    //Added 9-2-2015 Blasa
    public void sendCullListNotifications(String id, String date, String flag)
    {
        boolean _isType207 = false;

        if (!NotificationService.get().isServiceEnabled())
        {
            _log.info("notification service is not enabled, will not send Cull notification.");
            return;
        }

        String subject = "Cull/UnderUtilized Notification: ";

        Set<UserPrincipal> recipients = NotificationService.get().getRecipients(new CullListNotification(ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class)), getContainer());

        if (recipients.size() == 0)
        {
            _log.warn("No recipients, Cull notification");
            return;
        }

        final StringBuilder html = new StringBuilder();

        TableInfo ti = getTableInfo("ehr_lookups", "flag_values");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("objectid"), flag);
        filter.addCondition(FieldKey.fromString("category"), "Type207", CompareType.EQUAL);   // Type207

        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("code"), filter, null);  // 908 or 909
        List<Integer> ret = ts.getArrayList(Integer.class);
        if (ret != null && !ret.isEmpty())
        {
            for (Integer scode : ret)
            {
                //Underutilized Animals code 908
                if (scode == 908)
                {
                    html.append("<b>Recently Updated Underutilized Animals:</b><p>");
                    html.append(id + "<p> ");
                    html.append("<a href='" + AppProps.getInstance().getBaseServerUrl() + "/ehr/ONPRC/EHR/participantView.view?participantId=" + id + "&activeReport:activeFlags#subjects:" + id + "&inputType:singleSubject&showReport:1&activeReport:activeFlags" + "'>");

                    html.append("Click here to view this animal's Active Flag's history</a>.  <p>");

                }
                //Cull Animals code 909
                if (scode == 909)
                {
                    html.append("<b>Recently Updated Cull Animals:</b><p>");
                    html.append(id + "<p> ");
                    html.append("<a href='" + AppProps.getInstance().getBaseServerUrl() + "/ehr/ONPRC/EHR/participantView.view?participantId=" + id + "&activeReport:activeFlags#subjects:" + id + "&inputType:singleSubject&showReport:1&activeReport:activeFlags" + "'>");

                    html.append("Click here to view this animal's Active Flag's history</a>.  <p>");

                }

                //Provide url link to allow users to edit Cull listings
                html.append("<a href='" + AppProps.getInstance().getBaseServerUrl() + "/project/ONPRC/EHR/begin.view?pageId=Frequency%20Used%20Reports" + "'>");
                html.append("Click here to view and Edit Cull/Underutilzed Report</a>.  <p>");
                sendMessage(subject, html.toString(), recipients);
                break;
            }
        }

    }

    //Added 4-27-2016 Blasa
    public void sendProtocolNotifications(String protocolid)
    {

        if (!NotificationService.get().isServiceEnabled())
        {
            _log.info("notification service is not enabled, will not send Protocol notification.");
            return;
        }

        String subject = "Protocol Notification: ";

        Set<UserPrincipal> recipients = NotificationService.get().getRecipients(new ProtocolAlertsNotification(ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class)), getContainer());

        if (recipients.size() == 0)
        {
            _log.warn("No recipients, Protocol notification");
            return;
        }

        final StringBuilder html = new StringBuilder();

        TableInfo ti = getTableInfo("ehr", "protocol");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("protocol"), protocolid);
        filter.addCondition(FieldKey.fromString("enddate"), true, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("enddateCoalesced"), new Date(), CompareType.DATE_GTE);

        Sort sort = new Sort("external_id");
        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("external_id", "investigatorId", "approve"), filter, sort);

        if (ts.getRowCount() == 0)
        {
            html.append("There are no Iacuc Protocols to display");
            return;
        }
        else
        {
            //Create header information on the report
            html.append("<table border=1 style='border-collapse: collapse;'>");
            html.append("<tr style='font-weight: bold;'><td>Iacuc Protocol</td><td> Investigator</td><td>  Iacuc Approval Date</td></tr>\n");

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
               {

                   @Override
                   public void exec(ResultSet rs) throws SQLException
                   {

                       //Translate Investigator id to its true name
                       TableInfo ti2 = getTableInfo("onprc_ehr", "investigators");
                       SimpleFilter filter2 = new SimpleFilter(FieldKey.fromString("rowid"), rs.getString("investigatorId"));
                       filter2.addCondition(FieldKey.fromString("datedisabled"), true, CompareType.ISBLANK);

                       TableSelector ts2 = new TableSelector(ti2, PageFlowUtil.set("lastname"), filter2, null);
                       List<String> ret2 = ts2.getArrayList(String.class);
                       if (ret2 != null && !ret2.isEmpty())
                       {
                           for (String Investname : ret2)
                           {
                               //html.append("<tr><td>" + (rs.getString("external_id") == null ? "" : rs.getString("external_id")) + "</td><td>" + Investname + "</td><td>" + rs.getString("approve") + "</td></tr>\n");
                               html.append("<tr><td>" + (rs.getString("external_id") == null ? "" : rs.getString("external_id")) + "</td><td>  " + Investname + "   </td><td>" + rs.getString("approve") + "</td></tr>\n");
                               break;
                           }
                       }
                   }

               }

            );

        }


        html.append("</table>\n");

        sendMessage(subject, html.toString(), recipients);

    }

      //Added 9-2-2015  Blasa
    private void sendMessage(String subject, String bodyHtml, Collection<UserPrincipal> recipients)
    {
        try
        {
            MailHelper.MultipartMessage msg = MailHelper.createMultipartMessage();
            msg.setFrom(NotificationService.get().getReturnEmail(getContainer()));
            msg.setSubject(subject);

            List<String> emails = new ArrayList<>();
            for (UserPrincipal u : recipients)
            {
                List<Address> addresses = NotificationService.get().getEmailsForPrincipal(u);
                if (addresses != null)
                {
                    for (Address a : addresses)
                    {
                        if (a.toString() != null)
                            emails.add(a.toString());
                    }
                }
            }

            if (emails.size() == 0)
            {
                _log.warn("No emails, unable to send EHR trigger script email");
                return;
            }

            msg.setRecipients(Message.RecipientType.TO, StringUtils.join(emails, ","));
            msg.setEncodedHtmlContent(bodyHtml);

            MailHelper.send(msg, getUser(), getContainer());
        }
        catch (Exception e)
        {
            _log.error("Unable to send email from EHR trigger script", e);
        }
    }

}
