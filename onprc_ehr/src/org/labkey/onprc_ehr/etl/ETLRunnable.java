/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
package org.labkey.onprc_ehr.etl;

import com.google.common.base.Charsets;
import com.google.common.io.Files;
import org.apache.commons.codec.binary.Base64;
import org.apache.log4j.Logger;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.resource.FileResource;
import org.labkey.api.resource.MergedDirectoryResource;
import org.labkey.api.resource.Resource;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.security.ValidEmail;
import org.labkey.api.settings.AppProps;
import org.labkey.api.study.DataSetTable;
import org.labkey.api.util.ResultSetUtil;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.ViewContext;
import org.labkey.onprc_ehr.ONPRC_EHRSchema;

import java.io.Closeable;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class ETLRunnable implements Runnable
{

    public final static String TIMESTAMP_PROPERTY_DOMAIN = "onprc.ehr.org.labkey.onprc_ehr.etl.timestamp";
    public final static String ROWVERSION_PROPERTY_DOMAIN = "onprc.ehr.org.labkey.onprc_ehr.etl.rowversion";
    public final static String CONFIG_PROPERTY_DOMAIN = "onprc.ehr.org.labkey.onprc_ehr.etl.config";
    public final static byte[] DEFAULT_VERSION = new byte[0];

    private final DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);
    private Map<String, String> ehrQueries;
    private Map<String, String> ehrLookupsQueries;
    private Map<String, String> staticQueries;
    private Map<String, String> studyQueries;
    private Map<String, String> billingQueries;

    private final static Logger log = Logger.getLogger(ETLRunnable.class);
    private static final int UPSERT_BATCH_SIZE = 1000;
    private boolean isRunning = false;
    private boolean shutdown;

    public ETLRunnable() throws IOException
    {
        refreshQueries();
    }

    private void refreshQueries() throws IOException
    {
        this.staticQueries = loadQueries(getResource("static").list());
        this.ehrQueries = loadQueries(getResource("ehr").list());
        this.ehrLookupsQueries = loadQueries(getResource("ehr_lookups").list());
        this.studyQueries = loadQueries(getResource("study").list());
        this.billingQueries = loadQueries(getResource("onprc_billing").list());
    }

    @Override
    public void run()
    {
        User user;
        Container container;
        shutdown = false;

        if (isRunning)
        {
            log.error("EHR ETL is already running, aborting");
            return;
        }
        isRunning = true;

        try
        {
            try
            {
                //always reload the queries if we're in devmode
                if (AppProps.getInstance().isDevMode())
                    refreshQueries();

                user = UserManager.getUser(new ValidEmail(getConfigProperty("labkeyUser")));
                container = ContainerManager.getForPath(getConfigProperty("labkeyContainer"));
                if (null == user)
                {
                    throw new BadConfigException("bad configuration: invalid labkey user");
                }
                if (null == container)
                {
                    throw new BadConfigException("bad configuration: invalid labkey container");
                }
            }
            catch (ValidEmail.InvalidEmailException e)
            {
                log.error(e.getMessage(), e);
                return;
            }
            catch (BadConfigException e)
            {
               log.error(e.getMessage(), e);
               return;
            }
            catch (IOException e)
            {
                log.error(e.getMessage(), e);
                return;
            }

            int stackSize = -1;
            try
            {
                log.info("Begin incremental sync from external datasource.");

                // Push a fake ViewContext onto the HttpView stack
                stackSize = HttpView.getStackSize();
                ViewContext.getMockViewContext(user, container, new ActionURL("onprc_ehr", "fake.view", container), true);

                ETLAuditViewFactory.addAuditEntry(container, user, "START", "Starting EHR synchronization", 0, 0, 0, 0);

                for (String datasetName : studyQueries.keySet())
                {
                    long lastTs = getLastTimestamp(datasetName);
                    byte[] lastRow = getLastVersion(datasetName);
                    String version = lastRow.equals(DEFAULT_VERSION) ? "never" : new String(Base64.encodeBase64(lastRow), "US-ASCII");

                    log.info(String.format("table study.%s last synced %s", datasetName, lastTs == 0 ? "never" : new Date(lastTs).toString()));
                    log.info(String.format("table study.%s rowversion was %s", datasetName, version));
                }

                for (String tableName : ehrQueries.keySet())
                {
                    long lastTs = getLastTimestamp(tableName);
                    byte[] lastRow = getLastVersion(tableName);
                    String version = lastRow.equals(DEFAULT_VERSION) ? "never" : new String(Base64.encodeBase64(lastRow), "US-ASCII");
                    log.info(String.format("table ehr.%s last synced %s", tableName, lastTs == 0 ? "never" : new Date(lastTs).toString()));
                    log.info(String.format("table ehr.%s rowversion was %s", tableName, version));
                }

                for (String tableName : ehrLookupsQueries.keySet())
                {
                    long lastTs = getLastTimestamp(tableName);
                    byte[] lastRow = getLastVersion(tableName);
                    String version = lastRow.equals(DEFAULT_VERSION) ? "never" : new String(Base64.encodeBase64(lastRow), "US-ASCII");
                    log.info(String.format("table ehr_lookups.%s last synced %s", tableName, lastTs == 0 ? "never" : new Date(lastTs).toString()));
                    log.info(String.format("table ehr_lookups.%s rowversion was %s", tableName, version));
                }

                for (String tableName : billingQueries.keySet())
                {
                    long lastTs = getLastTimestamp(tableName);
                    byte[] lastRow = getLastVersion(tableName);
                    String version = lastRow.equals(DEFAULT_VERSION) ? "never" : new String(Base64.encodeBase64(lastRow), "US-ASCII");
                    log.info(String.format("table onprc_billing.%s last synced %s", tableName, lastTs == 0 ? "never" : new Date(lastTs).toString()));
                    log.info(String.format("table onprc_billing.%s rowversion was %s", tableName, version));
                }

                UserSchema ehrSchema = QueryService.get().getUserSchema(user, container, "ehr");
                UserSchema ehrLookupsSchema = QueryService.get().getUserSchema(user, container, "ehr_lookups");
                UserSchema billingSchema = QueryService.get().getUserSchema(user, container, "onprc_billing");
                UserSchema studySchema = QueryService.get().getUserSchema(user, container, "study");

                try
                {
                    runQueries(user, container, staticQueries);
                    int ehrErrors = merge(user, container, ehrQueries, ehrSchema);
                    int ehrLookupsErrors = merge(user, container, ehrLookupsQueries, ehrLookupsSchema);
                    int datasetErrors = merge(user, container, studyQueries, studySchema);
                    int billingErrors = merge(user, container, billingQueries, billingSchema);

                    log.info("End incremental sync run.");

                    ETLAuditViewFactory.addAuditEntry(container, user, "FINISH", "Finishing EHR synchronization", ehrErrors, ehrLookupsErrors, datasetErrors, billingErrors);
                }
                catch (BatchValidationException e)
                {
                    log.error(e.getMessage());
                    throw e;
                }
            }
            catch (Throwable x)
            {
                // Depending on the configuration of the executor,
                // if run() throws anything future executions may all canceled.
                // But we'd rather catch unexpected exceptions and continue trying,
                // to smooth over any transient issues like the remote datasource
                // being temporarily unavailable.
                log.error("Fatal incremental sync error", x);
                ETLAuditViewFactory.addAuditEntry(container, user, "FATAL ERROR", "Fatal error during EHR synchronization", 0, 0, 0, 0);

            }
            finally
            {
                if (stackSize > -1)
                    HttpView.resetStackSize(stackSize);
            }
        }
        finally
        {
            isRunning = false;
        }

    }

    private void runQueries(User user, Container container, Map<String, String> queries) throws BadConfigException, BatchValidationException
    {
        for (Map.Entry<String, String> kv : queries.entrySet())
        {
            if (isShutdown())
            {
                return;
            }

            String fileName = null;
            String sql;
            PreparedStatement s = null;

            ExperimentService.get().ensureTransaction();
            try
            {
                fileName = kv.getKey();
                sql = kv.getValue();


                log.info("Running script " + fileName);
                String[] sqls = sql.split("GO");

                for (String script : sqls)
                {
                    s = DbScope.getLabkeyScope().getConnection().prepareStatement(script);
                    s.execute();
                }
                ExperimentService.get().commitTransaction();
            }
            catch (SQLException e)
            {
                log.error("Unable to run script " + fileName);
                log.error(e.getMessage());
                continue;
            }
            finally
            {
                close(s);
                ExperimentService.get().closeTransaction();
            }
        }
    }


    /** @return count of collections that encountered errors */
    private int merge(User user, Container container, Map<String, String> queries, UserSchema schema) throws BadConfigException, BatchValidationException
    {
        DbScope scope = schema.getDbSchema().getScope();
        int errorCount = 0;

        for (Map.Entry<String, String> kv : queries.entrySet())
        {
            if (isShutdown())
            {
                return errorCount;
            }

            Connection originConnection = null;
            String targetTableName = null;
            String sql;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try
            {
                targetTableName = kv.getKey();
                sql = kv.getValue();

                //TODO: debug purposes only
//                sql = "SELECT TOP 200 * FROM (\n" + sql + "\n) t";

                TableInfo targetTable = schema.getTable(targetTableName);
                if (targetTable == null)
                {
                    log.error(targetTableName + " is not a known labkey study name, skipping the so-named sql query");
                    errorCount++;
                    continue;
                }

                //find the physical table for deletes
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

                if (realTable == null)
                {
                    log.error("Unable to find real table for: " + targetTable.getSelectName());
                }

                // Are we starting with an empty collection?
                // Optimizations below if true.
                boolean isTargetEmpty = isEmpty(targetTable);

                originConnection = getOriginConnection();

                log.info("Preparing query " + targetTableName);
                ps = originConnection.prepareStatement(sql);

                // Each statement will have zero or more bind variables in it. Set them all to
                // the baseline timestamp date.
                int paramCount = ps.getParameterMetaData().getParameterCount();
                if (paramCount == 0)
                    log.warn("Table lacks any parameters: " + targetTableName);

                Timestamp fromDate = new Timestamp(getLastTimestamp(targetTableName));
                byte[] fromVersion = getLastVersion(targetTableName);
                for (int i = 1; i <= paramCount; i++)
                {
                    ps.setBytes(i, fromVersion);
                }

                if (fromVersion == DEFAULT_VERSION)
                {
                    if (realTable != null)
                    {
                        log.info("Truncating target table, since last rowversion is null: " + targetTableName);
                        SQLFragment truncateSql = new SQLFragment("TRUNCATE TABLE " + realTable.getSelectName());
                        Table.execute(realTable.getSchema(), truncateSql);
                    }
                    else
                    {
                        log.error("unable to truncate targetTable, since realTable is null: " + targetTableName);
                    }
                }

                // get deletes from the origin.
                Set<String> deletedIds = getDeletes(originConnection, targetTableName, getLastVersion(targetTableName));

                log.info("querying for " + targetTableName + " since " + new Date(fromDate.getTime()));

                int updates = 0;
                int currentBatch = 0;
                byte[] newBaselineVersion = getOriginDataSourceCurrentVersion();
                Long newBaselineTimestamp = getOriginDataSourceCurrentTime();
                boolean rollback = false;

                rs = ps.executeQuery();
                log.info("query " + targetTableName + " returned");

                QueryUpdateService updater = targetTable.getUpdateService();
                updater.setBulkLoad(true);
                Map<String, Object> extraContext = new HashMap<String, Object>();
                extraContext.put("dataSource", "etl");

                //NOTE: the purpose of this switch is to allow alternate keyfields, such as
                ColumnInfo filterColumn = targetTable.getColumn("objectid");
                ColumnInfo pkColumn = targetTable.getPkColumns().get(0);
                if(filterColumn == null)
                {
                    log.info("objectid column not found for table: " + targetTable.getName() + ", using " + pkColumn.getName() + " instead");
                    filterColumn = pkColumn;
                }

                try
                {
                    log.info("ensure transaction for: " + schema.getSchemaName());
                    scope.ensureTransaction();
                    // perform any deletes
                    if (!deletedIds.isEmpty())
                    {
                        List<ColumnInfo> keys = targetTable.getPkColumns();

                        Map<String, SQLFragment> joins = new HashMap<String, SQLFragment>();
                        filterColumn.declareJoins("t", joins);

                        // Some ehr records are transformed into multiple records en route to labkey. the multiple records have objectids that
                        // are constructed from the original objectid plus a suffix. If one of those original records gets deleted we only know the
                        // original objectid. So we need to find the child ones with a LIKE objectid% query. Which is really complicated.
                        SQLFragment like = new SQLFragment("SELECT ");
//                        String comma = "";
//                        for (ColumnInfo key : keys)
//                        {
//                            like.append(comma + " ");
//                            like.append(key.getValueSql("t"));
//                            like.append(" AS \"" + key.getName() + "\"");
//                            comma = ",";
//                        }
                        like.append(filterColumn.getSelectName());
                        like.append(" FROM ");
                        like.append(targetTable.getFromSQL("t"));
                        if (!joins.isEmpty())
                            like.append(joins.values().iterator().next());
                        like.append(" WHERE ");

                        List<Map<String, Object>> deleteSelectors = new ArrayList<Map<String, Object>>();
                        SQLFragment likeWithIds = new SQLFragment(like.getSQL(), new ArrayList<Object>(like.getParams()));
                        int count = 0;
                        for (final String deletedId : deletedIds)
                        {
                            // Do this query in batches no larger than 100 to prevent from building up too many JDBC
                            // parameters
                            likeWithIds.add(deletedId);
                            if (count > 0)
                            {
                                likeWithIds.append(" OR ");
                            }

                            if (targetTable.getSqlDialect().isPostgreSQL())
                            {
                                String delim = "||";
                                likeWithIds.append(filterColumn.getValueSql("t") + " LIKE ? " + delim + " '%' ");
                            }
                            else
                            {
                                String delim = "+";
                                likeWithIds.append(filterColumn.getValueSql("t") + " LIKE CAST((? " + delim + " '%') as nvarchar(4000)) ");
                            }

                            if (count++ > 100)
                            {
                                deleteSelectors.addAll(Arrays.asList((Map<String, Object>[])Table.executeQuery(schema.getDbSchema(), likeWithIds, Map.class)));
                                // Reset the count and SQL
                                likeWithIds = new SQLFragment(like.getSQL(), new ArrayList<Object>(like.getParams()));
                                count = 0;
                            }
                        }
                        if (count > 0)
                        {
                            // Do the SELECT for any remaining ids
                            deleteSelectors.addAll(Arrays.asList((Map<String, Object>[])Table.executeQuery(schema.getDbSchema(), likeWithIds, Map.class)));
                        }

                        if (realTable != null)
                        {
                            log.debug("deleting using real table for: " + realTable.getSelectName() + ", filtering on " + filterColumn.getColumnName());
                            SimpleFilter filter = new SimpleFilter();
                            filter.addWhereClause(filterColumn.getFieldKey() + " IN (" + likeWithIds.getSQL() + ")", likeWithIds.getParamsArray(), filterColumn.getFieldKey());
                            Table.delete(realTable, filter);
                        }
                        else
                        {
                            log.info("deleting using update service for: " + targetTable.getName());
                            updater.deleteRows(user, container, deleteSelectors, extraContext);
                        }
                        log.info("deleted objectids " + deletedIds.size());
                    }

                    List<Map<String, Object>> sourceRows = new ArrayList<Map<String, Object>>();
                    // accumulating batches of rows. would employ ResultSet.isDone to manage the last remainder
                    // batch but the MySQL jdbc driver doesn't support that method if it is a streaming result set.
                    boolean isDone = false;
                    List<Object> searchParams = new ArrayList<Object>();
                    if (targetTable instanceof DataSetTable)
                    {
                        if(((DataSetTable)targetTable).getDataSet().isDemographicData())
                        {
                            log.info("table is demographics, filtering on Id");
                            filterColumn = targetTable.getColumn("Id");
                        }
                    }

                    while (!isDone)
                    {

                        if (isShutdown())
                        {
                            rollback = true;
                            return errorCount;
                        }

                        isDone = !rs.next();
                        if (!isDone)
                        {
                            sourceRows.add(mapResultSetRow(rs));
                            try
                            {

                                searchParams.add(rs.getObject(filterColumn.getColumnName()));
                            }
                            catch (SQLException e)
                            {
                                log.error("Unable to find column " + filterColumn.getColumnName() + " in ETL script for " + targetTableName);
                                throw e;
                            }
                        }
                        else
                        {
                            // avoid leaving the statement open while we process the results.
                            close(rs);
                            rs = null;
                            close(ps);
                            close(originConnection);
                        }

                        //this is performed in batches.  first we select any existing rows, then delete these.
                        //once complete, then we do an insert
                        if (sourceRows.size() == UPSERT_BATCH_SIZE || isDone)
                        {
                            if (!isTargetEmpty && searchParams.size() > 0) {
                                long start = new Date().getTime();

                                //use objectId to obtain LSIDs
                                SimpleFilter filter = new SimpleFilter(FieldKey.fromString(filterColumn.getColumnName()), searchParams, CompareType.IN);
                                Set<String> cols = new HashSet(targetTable.getPkColumnNames());
                                TableSelector ts = new TableSelector(targetTable, cols, filter, null);
                                Map<String, Object>[] rows = ts.getArray(Map.class);

                                long duration = ((new Date()).getTime() - start) / 1000;
                                log.info("Pre-selecting " + searchParams.size() + " rows for table: " + targetTable.getName() + " took: " + duration + "s");

                                if (rows.length > 0)
                                {
                                    log.info("Preparing for insert by deleting " + rows.length + " rows for table: " + targetTable.getName());
                                    start = new Date().getTime();
                                    int totalDeleted;
                                    if (realTable != null)
                                    {
                                        List<Object> pks = new ArrayList<Object>();
                                        for (Map<String, Object> r : rows)
                                        {
                                            pks.add(r.get(pkColumn.getName()));
                                        }
                                        totalDeleted = Table.delete(realTable, new SimpleFilter(pkColumn.getFieldKey(), pks, CompareType.IN));
                                    }
                                    else
                                    {
                                        List<Map<String, Object>> deleted = updater.deleteRows(user, container, Arrays.asList(rows), extraContext);
                                        totalDeleted = deleted.size();
                                    }

                                    if (totalDeleted != rows.length)
                                    {
                                        log.warn("Table: " + targetTable.getName() + " delete abnormality.  searchParams: " + searchParams.size() + ", rows: " + rows.length + ", deleted: " + totalDeleted);
                                        TableSelector ts1 = new TableSelector(targetTable, cols, filter, null);
                                        Map<String, Object>[] rows2 = ts1.getArray(Map.class);
                                        log.info("rows: " + rows2.length);
                                    }
                                    duration = ((new Date()).getTime() - start) / 1000;
                                    log.info("Finished deleting " + totalDeleted + " rows for table: " + targetTable.getName() + ", which took: " + duration + "s");
                                }
                                else
                                    log.info("No existing rows found for table: " + targetTable.getName() + ", delete not necessary");
                            }
                            long start = new Date().getTime();
                            BatchValidationException errors = new BatchValidationException();
                            updater.insertRows(user, container, sourceRows, errors, extraContext);
                            if (errors.hasErrors())
                            {
                                log.error("There were errors during the sync for: " + targetTableName);
                                for (ValidationException e : errors.getRowErrors())
                                {
                                    log.error(e.getMessage());
                                }
                                throw errors;
                            }
                            updates += sourceRows.size();
                            currentBatch += sourceRows.size();
                            long duration = ((new Date()).getTime() - start) / 1000;
                            log.info("Insert took: " + duration + "s");
                            log.info("Updated " + updates + " records for " + targetTableName);
                            sourceRows.clear();
                            searchParams.clear();

                            if (currentBatch >= 40000)
                            {
                                if (realTable != null)
                                {
                                    //NOTE: this may be less important on SQLServer
                                    log.info("Performing Analyze");
                                    String analyze = realTable.getSchema().getSqlDialect().getAnalyzeCommandForTable(realTable.getSchema().getName() + "." + realTable.getName());
                                    Table.execute(realTable.getSchema(), analyze);
                                }
                                else
                                {
                                    log.warn("realTable is null, wont analyze");
                                }
                                currentBatch = 0;
                            }
                        }

                    } // each record

                } // all records in a target
                catch (Throwable e) // comm errors and timeouts with remote, labkey exceptions
                {
                    log.error(e, e);
                    rollback = true;
                    errorCount++;
                }
                finally
                {
                    if (rollback)
                    {
                        scope.closeConnection();
                        log.warn("Rolled back update of " + targetTableName);
                    }
                    else
                    {
                        scope.commitTransaction();
                        setLastVersion(targetTableName, newBaselineVersion);
                        setLastTimestamp(targetTableName, newBaselineTimestamp);

                        if (updates > 100000)
                        {
                            shrinkDB(scope);
                        }

                        log.info(MessageFormat.format("Committed updates for {0} records in {1}", updates, targetTableName));

                        try
                        {
                            TableInfo ti = ONPRC_EHRSchema.getInstance().getSchema().getTable(ONPRC_EHRSchema.TABLE_ETL_RUNS);
                            Map<String, Object> row = new HashMap<String, Object>();
                            row.put("date", new Date(newBaselineTimestamp));
                            row.put("queryname", targetTableName);
                            row.put("rowversion", new String(newBaselineVersion, "US-ASCII"));
                            row.put("container", container.getEntityId());
                            Table.insert(user, ti, row);
                        }
                        catch (UnsupportedEncodingException e)
                        {
                            log.error(e.getMessage());
                        }
                    }
                }
            }
            catch (SQLException e)
            {
                // exception connecting, preparing or executing the query to the origin db
                log.error(String.format("Error syncing '%s' - caught SQLException: %s", targetTableName, e.getMessage()), e);
                errorCount++;
            }
            finally
            {
                close(rs);
                close(ps);
                close(originConnection);
                scope.closeConnection();
            }

        } // each target collection
        return errorCount;
    }

    /**
     *
     * @param tableName for which to get deletes
     * @param fromVersion return deletes performed after this version
     * @return
     * @throws SQLException
     * @throws BadConfigException
     */
    Set<String> getDeletes(Connection originConnection, String tableName, byte[] fromVersion) throws SQLException, BadConfigException
    {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Set<String> deletes = new HashSet<String>();

        try
        {
            originConnection = getOriginConnection();
            ps = originConnection.prepareStatement("SELECT objectid FROM dbo.deleted_records WHERE ts > ?");
            ps.setBytes(1, fromVersion);
            //ps.setString(1, tableName);
            rs = ps.executeQuery();
            while (rs.next())
            {
                deletes.add(rs.getString(1));
            }

            if (!deletes.isEmpty())
                log.info(deletes.size() + " deletes pending for " + tableName);
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            ResultSetUtil.close(rs);
            close(ps);
        }

        return deletes;
    }

    private void shrinkDB(DbScope scope) throws SQLException
    {
        if (scope.getSqlDialect().isSqlServer())
        {
            log.info("Shrinking TempDB");

            DbSchema tempDb = DbSchema.get("tempdb");

            SQLFragment sql1 = new SQLFragment("use tempdb; dbcc shrinkfile (tempdev, 100); use labkey; ");
            SqlExecutor se = new SqlExecutor(tempDb.getScope());
            se.execute(sql1);

            SQLFragment sql2 = new SQLFragment("use tempdb; dbcc shrinkfile (templog, 100); use labkey; ");
            SqlExecutor se2 = new SqlExecutor(tempDb.getScope());
            se2.execute(sql2);

            log.info("Checkpoint and shrinking Logfile");
            SQLFragment sql3 = new SQLFragment("CHECKPOINT;DBCC SHRINKFILE ( labkey_log, 1);");
            SqlExecutor se3 = new SqlExecutor(scope);
            se3.execute(sql3);
        }
    }

    /**
     * @return the timestamp last stored by the ETL, or 0 time if not present.  this
     * is for display only.  rowVersion is used by the DB
     */
    private long getLastTimestamp(String tableName)
    {
        Map<String, String> m = PropertyManager.getProperties(TIMESTAMP_PROPERTY_DOMAIN);
        String value = m.get(tableName);
        if (value != null)
        {
            return Long.parseLong(value);
        }

        return 0;
    }

    /**
     * @return the rowverion last stored by @setLastVersion
     */
    private byte[] getLastVersion(String tableName)
    {
        Map<String, String> m = PropertyManager.getProperties(ROWVERSION_PROPERTY_DOMAIN);
        String value = m.get(tableName);
        if (value != null)
        {
            return Base64.decodeBase64(value);
        }
        else
        {
            return DEFAULT_VERSION;
        }
    }

    boolean isEmpty(TableInfo tinfo) throws SQLException
    {
        SQLFragment sql = new SQLFragment("SELECT COUNT(*) FROM ").append(tinfo.getFromSQL("x"));
        return Table.executeSingleton(tinfo.getSchema(), sql.getSQL(), sql.getParamsArray(), Long.class) == 0;
    }

    /**
     * Persist the baseline timestamp to use next time we sync this table. It should be the origin db's idea of what time it is.
     *
     * @param ts the timestamp we want returned by the next call to @getLastTimestamp
     */
    private void setLastTimestamp(String tableName, Long ts)
    {
        log.info(String.format("setting new baseline timestamp of %s on collection %s", new Date(ts.longValue()).toString(), tableName));
        PropertyManager.PropertyMap pm = PropertyManager.getWritableProperties(TIMESTAMP_PROPERTY_DOMAIN, true);
        pm.put(tableName, ts.toString());
        PropertyManager.saveProperties(pm);
    }

    /**
     * @return the current time according to the origin db.
     */
    private Long getOriginDataSourceCurrentTime() throws SQLException, BadConfigException
    {
        Connection con = null;
        Long ts = null;
        try
        {
            con = getOriginConnection();
            PreparedStatement ps = con.prepareStatement("select GETDATE()");
            ResultSet rs = ps.executeQuery();
            if (rs.next())
            {
                ts = new Long(rs.getTimestamp(1).getTime());
            }
        }
        finally
        {
            close(con);
        }
        return ts;
    }

    /**
     * Persist the baseline timestamp to use next time we sync this table. It should be the origin db's idea of what time it is.
     *
     * @param version the timestamp we want returned by the next call to @getLastTimestamp
     */
    private void setLastVersion(String tableName, byte[] version)
    {
        PropertyManager.PropertyMap pm = PropertyManager.getWritableProperties(ROWVERSION_PROPERTY_DOMAIN, true);
        byte[] encoded = Base64.encodeBase64(version);
        try
        {
            String toStore = new String(encoded, "US-ASCII");
            pm.put(tableName, toStore);
            PropertyManager.saveProperties(pm);
        }
        catch (UnsupportedEncodingException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * @return the current version according to the origin db.
     */
    private byte[] getOriginDataSourceCurrentVersion() throws SQLException, BadConfigException
    {
        Connection con = null;
        byte[] version = null;
        ResultSet rs = null;
        try
        {
            con = getOriginConnection();
            PreparedStatement ps = con.prepareStatement("SELECT @@DBTS;");
            rs = ps.executeQuery();
            if (rs.next())
            {
                version = rs.getBytes(1);
            }
        }
        finally
        {
            close(con);
            ResultSetUtil.close(rs);
        }
        return version;
    }

    private Connection getOriginConnection() throws SQLException, BadConfigException
    {
        try
        {
            Class.forName(getConfigProperty("jdbcDriver")).newInstance();
        }
        catch (Throwable t)
        {
            throw new RuntimeException(t);
        }

        return DriverManager.getConnection(getConfigProperty("jdbcUrl"));
    }

    private Map<String, String> loadQueries(Collection<Resource> sqlFiles) throws IOException
    {
        Map<String, String> qMap = new HashMap<String, String>();

        for (Resource sqlFile : sqlFiles)
        {
            FileResource f = (FileResource)sqlFile;

            if (!f.getName().endsWith("sql")) continue;
            String sql = Files.toString(f.getFile(), Charsets.UTF_8);
            String key = f.getName().substring(0, f.getName().indexOf('.'));
            qMap.put(key, sql);
        }

        return qMap;
    }

    private Map<String, Object> mapResultSetRow(ResultSet rs) throws SQLException
    {
        Map<String, Object> map = new CaseInsensitiveHashMap<Object>();
        ResultSetMetaData md = rs.getMetaData();
        int columnCount = md.getColumnCount();
        for (int i = 1; i <= columnCount; i++)
        {
            // Pull out of ResultSet based on label instead of name, as the column
            // may have been aliased to match with its target in the dataset or list
            map.put(md.getColumnLabel(i), rs.getObject(i));
        }
        return map;
    }

    /**
     * @param path relative to onprc_ehr/resources/org.labkey.onprc_ehr.etl dir
     * @return MergedDirectoryResource object for the specified file or directory
     */
    private MergedDirectoryResource getResource(String path)
    {
        return ((MergedDirectoryResource)ModuleLoader.getInstance().getModule("ONPRC_EHR").getModuleResource("/etl/" + path));
    }

    private static void close(Closeable o)
    {
        if (o != null) try
        {
            o.close();
        }
        catch (Exception ignored)
        {
        }
    }

    private static void close(Connection o)
    {
        if (o != null) try
        {
            o.close();
        }
        catch (Exception ignored)
        {
        }
    }

    private static void close(ResultSet o)
    {
        if (o != null) try
        {
            o.close();
        }
        catch (Exception ignored)
        {
            log.error("There was an error closing a result set in the ETL: " + ignored.getMessage());
        }
    }

    private static void close(PreparedStatement o)
    {
        if (o != null) try
        {
            o.close();
        }
        catch (Exception ignored)
        {
            log.error("There was an error closing a result set in the ETL: " + ignored.getMessage());
        }
    }

    public int getRunIntervalInMinutes()
    {
        String prop = PropertyManager.getProperties(CONFIG_PROPERTY_DOMAIN).get("runIntervalInMinutes");
        return null == prop ? 0 : Integer.parseInt(prop);
    }

    private String getConfigProperty(String key) throws BadConfigException
    {
        String prop = PropertyManager.getProperties(CONFIG_PROPERTY_DOMAIN).get(key);
        if (null == prop)
            throw new BadConfigException("No " + key + " is configured");
        else
            return prop;

    }

    public boolean isShutdown()
    {
        return shutdown;
    }

    public void shutdown()
    {
        this.shutdown = true;
    }

    public boolean isRunning()
    {
        return isRunning;
    }

    class BadConfigException extends Throwable
    {
        public BadConfigException(String s)
        {
            super(s);
        }
    }
}
