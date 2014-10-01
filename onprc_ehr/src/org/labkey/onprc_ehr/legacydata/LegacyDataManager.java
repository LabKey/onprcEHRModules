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
package org.labkey.onprc_ehr.legacydata;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.DbScope;
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
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.exp.api.ExperimentJSONConverter;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.files.FileContentService;
import org.labkey.api.laboratory.LaboratoryService;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.module.FolderType;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.security.ValidEmail;
import org.labkey.api.services.ServiceRegistry;
import org.labkey.api.study.assay.AssayProvider;
import org.labkey.api.study.assay.AssayService;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.ViewContext;

import java.io.File;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 2/23/13
 * Time: 11:40 AM
 */
public class LegacyDataManager
{
    private static final LegacyDataManager _instance = new LegacyDataManager();
    private static final Logger _log = Logger.getLogger(LegacyDataManager.class);
    private final static SimpleDateFormat _dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    private LegacyDataManager()
    {

    }

    public static LegacyDataManager getInstance()
    {
        return _instance;
    }

    public String importSachaExperiments(final User u, final Container c, final Boolean validateOnly)
    {
        final StringBuilder sb = new StringBuilder();
        UserSchema us = QueryService.get().getUserSchema(u, c, "sacha_db");
        if (us == null)
            throw new RuntimeException("Unable to find sasha_db mysql schema");

        DbSchema labSchema = DbSchema.get("laboratory");
        final TableInfo workbooksTable = labSchema.getTable("workbooks");
        final FileContentService svc = ServiceRegistry.get().getService(FileContentService.class);

        TableInfo exptTable = us.getTable("experiments");
        if (exptTable == null)
            throw new RuntimeException("Unable to find experiments table");

        final FolderType exptFolderType = ModuleLoader.getInstance().getFolderType("Expt Workbook");

        DbSchema coreSchema = DbSchema.get("core");
        final TableInfo containersTable = coreSchema.getTable("containers");
        final SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        final SimpleDateFormat format2 = new SimpleDateFormat("yyyyMMdd");

        TableSelector ts = new TableSelector(exptTable, PageFlowUtil.set("experiment_date", "experiment_title", "id_experiment", "experiment_description", "experiment_materials", "experiment_methods", "experiment_results", "id_user"), null, null);
        try
        {
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    sb.append("<br>----------------------------------<br>");

                    Map<String, Object> row = new HashMap<>();
                    Date created = null;
                    if (rs.getObject("experiment_date") != null && rs.getObject("experiment_date") instanceof Date)
                    {
                        created = (Date)rs.getObject("experiment_date");
                    }

                    row.put("created", rs.getObject("experiment_date"));

                    Date exptDate = rs.getDate("experiment_date");

                    User exptUser = resolveUser(u, c, rs, sb);
                    if (exptUser != null)
                        row.put("createdby", exptUser.getUserId());

                    Integer exptId = rs.getInt("id_experiment");
                    row.put("workbookId", exptId);

                    String title = StringUtils.trimToNull(rs.getString("experiment_title"));
                    if (title != null)
                        title = title.replaceAll("([\\n\\t\\r]+)", " ");

                    for (String key : row.keySet())
                    {
                        sb.append(key).append(": ").append(row.get(key)).append("<br>");
                    }

                    sb.append("Title: ").append(title).append("<br>");
                    String description = StringUtils.trimToNull(rs.getString("experiment_description"));
                    sb.append("Description: ").append(description).append("<br>");

                    try
                    {
                        Container workbook = null;
                        try
                        {
                            workbook = resolveWorkbookFromId(exptId, u, c);
                            if (workbook != null && created != null && !workbook.getCreated().equals(created))
                            {
                                sb.append("updating created field for workbook").append("<br>");
                                if (!validateOnly)
                                {
                                    SQLFragment updateContainers = new SQLFragment("UPDATE core.containers set created = ? WHERE entityid = ?", created, workbook.getId());
                                    SqlExecutor se = new SqlExecutor(containersTable.getSchema());
                                    se.execute(updateContainers);
                                }
                            }

                            if (workbook == null)
                            {
                                if (!validateOnly)
                                {
                                    sb.append("creating workbook for: " + exptId).append("<br>");
                                    workbook = ContainerManager.createContainer(c, null, title, description, Container.TYPE.workbook, u);
                                    workbook.setFolderType(exptFolderType, Collections.<Module>emptySet());

                                    //NOTE: we create the container using the provided user so we ensure permissions are right
                                    //however, we update these containers after the fact to poke in the user from mysql, if it mapped
                                    if (exptUser != null)
                                    {
                                        SQLFragment updateContainers = new SQLFragment("UPDATE core.containers set createdby = ? WHERE entityid = ?", exptUser.getUserId(), workbook.getId());
                                        SqlExecutor se = new SqlExecutor(containersTable.getSchema());
                                        se.execute(updateContainers);
                                    }

                                    TableSelector wbs = new TableSelector(workbooksTable, Collections.singleton("workbookId"), null, null);

                                    Integer rowids[] = wbs.getArray(Integer.class);
                                    if (rowids.length == 0)
                                    {
                                        throw new RuntimeException("Unable to find laboratory.workbooks row for id: " + workbook.getId());
                                    }

                                    row.put("workbookId", exptId);
                                    row.put("materials", StringUtils.trimToNull(rs.getString("experiment_materials")));
                                    row.put("methods", StringUtils.trimToNull(rs.getString("experiment_methods")));
                                    row.put("results", StringUtils.trimToNull(rs.getString("experiment_results")));
                                    row.put("container", workbook.getId());
                                    Table.update(u, workbooksTable, row, workbook.getId());
                                }
                            }
                            else
                            {
                                sb.append("workbook already exists: " + exptId).append("<br>");
                            }
                        }
                        catch (IllegalArgumentException e)
                        {
                            throw e;
                        }

                        File sourceFolder = svc.getFileRoot(c, FileContentService.ContentType.files);
                        if (sourceFolder != null && sourceFolder.exists())
                        {
                            File root = null;
                            if (workbook != null)
                            {
                                root = svc.getFileRoot(workbook, FileContentService.ContentType.files);
                                if (!root.exists())
                                    root.mkdir();
                            }

                            List<File> toMove = new ArrayList<>();
                            for (File subfolder : sourceFolder.listFiles())
                            {
                                if (subfolder.isDirectory())
                                {
                                    String[] tokens = subfolder.getName().split("-|_");
                                    String exptName = tokens[0];
                                    if (exptId.toString().equals(exptName))
                                    {
                                        toMove.add(subfolder);
                                    }
                                }
                            }

                            if (toMove.size() == 1)
                            {
                                sb.append("Found existing files to move<br>");
                                File expected = toMove.get(0);

                                if (!validateOnly && root != null)
                                {
                                    for (File child : expected.listFiles())
                                    {
                                        FileUtils.moveToDirectory(child, root, false);
                                    }

                                    if (expected.listFiles().length == 0)
                                    {
                                        expected.delete();
                                    }
                                }
                            }
                            else if (toMove.size() > 1)
                            {
                                sb.append("More than one potential file source found: ").append("<br>");
                                for (File f : toMove)
                                {
                                    sb.append(f.getName()).append("<br>");
                                }
                            }
                            else
                            {
                                sb.append("No existing files found<br>");
                            }
                        }
                    }
                    catch (IOException e)
                    {
                        throw new RuntimeException(e);
                    }
                }
            });
        }
        finally
        {

        }

        return sb.toString();
    }

    private Map<Integer, User> _userMap = new HashMap<>();

    private User resolveUser(User u, Container c, ResultSet rs, StringBuilder sb) throws SQLException
    {
        Integer legacyId = rs.getInt("id_user");
        if (legacyId == null)
            return null;

        if (_userMap.containsKey(legacyId))
        {
            return _userMap.get(legacyId);
        }

        UserSchema us = QueryService.get().getUserSchema(u, c, "sacha_db");
        TableInfo ti = us.getTable("users");
        TableSelector ts = new TableSelector(ti, new SimpleFilter(FieldKey.fromString("id_user"), legacyId), null);
        Map<String, Object>[] userRows = ts.getMapArray();
        if (userRows.length != 1)
            return null;

        Map<String, Object> userRow = userRows[0];
        String email = (String)userRow.get("Email");
        if (email != null)
        {
            try
            {
                ValidEmail ve = new ValidEmail(email);
                User user = UserManager.getUser(ve);
                if (user != null)
                {
                    _userMap.put(legacyId, user);
                    return user;
                }
            }
            catch (ValidEmail.InvalidEmailException e)
            {
                //ignore
            }
        }

        //then try logon
        String logon = (String)userRow.get("Login");
        if (logon != null)
        {
            User user = UserManager.getUserByDisplayName(logon);
            if (user != null)
            {
                _userMap.put(legacyId, user);
                return user;
            }
        }

        //finally try first/last names
        String firstName = (String)userRow.get("Name");
        String lastName = (String)userRow.get("LastName");
        if (firstName != null && lastName != null)
        {
            UserSchema coreSchema = QueryService.get().getUserSchema(u, c, "core");
            TableInfo usersTable = coreSchema.getTable("users");
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("firstname"), firstName);
            filter.addCondition(FieldKey.fromString("lastname"), lastName);
            TableSelector ts2 = new TableSelector(usersTable, filter, null);
            Map<String, Object>[] ret = ts2.getMapArray();
            if (ret.length == 1)
            {
                Integer userId = (Integer)ret[0].get("UserId");
                User user = UserManager.getUser(userId);
                if (user != null)
                {
                    _userMap.put(legacyId, user);
                    return user;
                }
            }
        }

        sb.append("Unknown User: " + email).append("<br>");
        return null;
    }

    private Container resolveWorkbookFromId(Integer id, User u, Container parent)
    {
        TableInfo ti = QueryService.get().getUserSchema(u, parent, "laboratory").getTable("workbooks");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("workbookId"), id, CompareType.EQUAL);
        TableSelector ts = new TableSelector(ti, PageFlowUtil.set("container"), filter, null);
        String[] rows = ts.getArray(String.class);
        if (rows.length == 0)
        {
            return null;
        }
        else
        {
            return ContainerManager.getForId(rows[0]);
        }
    }

    public String importElispotResults(final ViewContext ctx, final Boolean validateOnly) throws ValidationException
    {
        final StringBuilder sb = new StringBuilder();

        UserSchema us = QueryService.get().getUserSchema(ctx.getUser(), ctx.getContainer(), "sacha_db");
        if (us == null)
            throw new RuntimeException("Unable to find sasha_db mysql schema");

        TableInfo elispotTable = us.getTable("elispot_results");
        if (elispotTable == null)
            throw new RuntimeException("Unable to find elispot_results table");

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("id_animal"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromString("id_animal"), "", CompareType.NEQ);
        filter.addCondition(FieldKey.fromString("spots"), null, CompareType.NONBLANK);
        TableSelector ts = new TableSelector(elispotTable, filter, new Sort("id_experiment"));

        final FileContentService svc = ServiceRegistry.get().getService(FileContentService.class);
        final Map<Container, List<Map<String, Object>>> runs = new HashMap<>();
        final Map<Container, String> nameMap = new HashMap<>();
        final Map<Container, Date> runDateMap = new HashMap<>();

        AssayProvider ap = AssayService.get().getProvider("ELISPOT_Assay");
        if (ap == null)
            throw new RuntimeException("Unable to find ELIPOST_Assay provider");

        List<ExpProtocol> protocols = AssayService.get().getAssayProtocols(ContainerManager.getSharedContainer(), ap);
        if (protocols == null || protocols.size() == 0)
            throw new RuntimeException("Unable to find ELIPOST_Assay protocol");

        final ExpProtocol protocol = protocols.get(0);

        String importMethod = "Default Excel";
        AssayImportMethod method = LaboratoryService.get().getDataProviderForAssay(ap).getImportMethodByName(importMethod);
        if (method == null)
        {
            throw new RuntimeException("Import method not recognized: " + importMethod);
        }

        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                Map<String, Object> row = new HashMap<>();
                Integer expt = rs.getInt("id_experiment");
                Container workbook = resolveWorkbookFromId(expt, ctx.getUser(), ctx.getContainer());
                String runName = "Expt: " + expt;

                List<? extends ExpRun> existingRuns = ExperimentService.get().getExpRuns(workbook, protocol, null);
                if (!existingRuns.isEmpty())
                {
                    for (ExpRun r : existingRuns)
                    {
                        if (r.getName().equals(runName))
                        {
                            sb.append("Existing run found, skipping: " + runName).append("<br>");
                            return;
                        }
                    }
                }

                row.put("subjectId", rs.getObject("id_animal"));
                row.put("date", rs.getObject("sample_date"));
                row.put("cell_number", rs.getString("cell_number"));
                row.put("peptide", rs.getObject("id_peptide"));
                row.put("well", rs.getObject("id_well"));
                row.put("spots", rs.getInt("spots"));
                row.put("cell_number", rs.getObject("cell_number"));
                row.put("comments", rs.getObject("comments"));
                row.put("concentration", rs.getObject("peptide_concentration"));

                if (rs.getObject("date") instanceof Date)
                {
                    runDateMap.put(workbook, (Date)rs.getObject("date"));
                }

                String peptide = (String)row.get("peptide");
                if (peptide != null && peptide.matches(" (\\d+)\\DM$"))
                {
                    String[] tokens = peptide.split(" ");
                    peptide = StringUtils.trimToNull(tokens[0]);
                    Integer conc = Integer.parseInt(tokens[1].replaceAll("\\D", ""));

                    row.put("peptide", peptide);
                    row.put("concentration", conc);
                }

                if ("No Peptide".equalsIgnoreCase((String)row.get("peptide")))
                {
                    row.put("peptide", "No Stim");
                }

                if ("Con A".equalsIgnoreCase((String)row.get("peptide")) || "ConA".equalsIgnoreCase((String)row.get("peptide")))
                {
                    row.put("peptide", "Con A");
                    row.put("category", "Pos Control");
                }
                else if ("No Stim".equalsIgnoreCase((String)row.get("peptide")) || "No Peptide".equalsIgnoreCase((String)row.get("peptide")))
                {
                    row.put("peptide", "No Stim");
                    row.put("category", "Neg Control");
                }
                else
                {
                    row.put("category", "Unknown");
                }

                List<Map<String, Object>> results = runs.get(workbook);
                if (results == null)
                    results = new ArrayList<>();

                results.add(row);

                runs.put(workbook, results);
                nameMap.put(workbook, runName);
            }
        });

        for (Container workbook : runs.keySet())
        {
            List<Map<String, Object>> rows = runs.get(workbook);
            sb.append("<br>-----------------------<br>");
            JSONObject json = new JSONObject();
            JSONObject runProperties = new JSONObject();
            String name = nameMap.get(workbook);
            runProperties.put(ExperimentJSONConverter.NAME, name);
            if (runDateMap.containsKey(workbook))
                runProperties.put("runDate", runDateMap.get(workbook));

            json.put("Run", runProperties);

            JSONObject batchProperties = new JSONObject();
            batchProperties.put(ExperimentJSONConverter.NAME, name);
            json.put("Batch", batchProperties);

            JSONArray jsonArray = new JSONArray();
            sb.append(name).append("<br>");
            sb.append("Rows:<br>");
            for (Map<String, Object> row : rows)
            {
                jsonArray.put(row);
                sb.append("......").append("<br>");
                for (String key : row.keySet())
                {
                    sb.append(key).append(": ").append(row.get(key)).append("<br>");
                }
            }
            json.put("ResultRows", jsonArray);

            json.put("errorLevel", "ERROR");

            File root = svc.getFileRoot(workbook, FileContentService.ContentType.files);
            if (!root.exists())
                root.mkdir();

            root = new File(root, "assaydata");
            if (!root.exists())
                root.mkdir();

            if (!validateOnly)
            {
                try
                {
                    File f = new File(root, name + ".tsv");
                    if (f.exists())
                        f.delete();

                    f.createNewFile();
                    ViewContext ctx2 = new ViewContext(ctx);
                    ctx2.setContainer(workbook);

                    AssayParser parser = method.getFileParser(workbook, getUserForContainer(workbook), protocol.getRowId());
                    parser.saveBatch(json, f, f.getName(), ctx2);
                    _log.info("created ELISPOT run: " + name + ", " + rows.size() + " rows");
                }
                catch (BatchValidationException e)
                {
                    for (ValidationException ve : e.getRowErrors())
                    {
                        _log.error(ve.getMessage(), ve);
                    }
                    _log.error(e.getMessage(), e);
                }
                catch (IOException e)
                {
                    throw new RuntimeException(e);
                }
            }
        }

        return sb.toString();
    }

    public User getUserForContainer(Container c)
    {
        DbSchema coreSchema = DbSchema.get("core");
        final TableInfo containersTable = coreSchema.getTable("containers");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("EntityId"), c.getId(), CompareType.EQUAL);
        TableSelector ts = new TableSelector(containersTable, PageFlowUtil.set("createdby"), filter, null);
        Integer userids[] = ts.getArray(Integer.class);
        if (userids.length == 0)
            return null;

        return UserManager.getUser(userids[0]);
    }

    public String importSachaPeptides(final User u, final Container c, final Boolean validateOnly)
    {
        try
        {
            final StringBuilder sb = new StringBuilder();
            UserSchema us = QueryService.get().getUserSchema(u, c, "sacha_db");
            if (us == null)
                throw new RuntimeException("Unable to find sasha_db mysql schema");

            TableInfo mysqlPepTable = us.getTable("peptides");
            if (mysqlPepTable == null)
                throw new RuntimeException("Unable to find mysql peptides table");

            UserSchema labSchema = QueryService.get().getUserSchema(u, c, "laboratory");
            final TableInfo peptideTable = labSchema.getTable("peptides");

            UserSchema elispotSchema = QueryService.get().getUserSchema(u, c, "elispot_assay");
            final TableInfo peptidePoolTable = elispotSchema.getTable("peptide_pools");
            final TableInfo peptidePoolMembersTable = elispotSchema.getTable("peptide_pool_members");

            SimpleFilter filter = new SimpleFilter();
            filter.addClause(ContainerFilter.CURRENT.createFilterClause(labSchema.getDbSchema(), FieldKey.fromString("container"), c));
            TableSelector ts1 = new TableSelector(peptideTable, PageFlowUtil.set("rowid"), filter, null);
            Integer[] rowIds = ts1.getArray(Integer.class);
            sb.append("peptide records to delete: " + rowIds.length).append("<br>");

            if (!validateOnly && rowIds.length > 0)
            {
                int deleted = Table.delete(DbSchema.get("laboratory").getTable("peptides"), filter);
                sb.append("peptide records deleted: " + deleted).append("<br>");

            }

            TableSelector ts2 = new TableSelector(mysqlPepTable);
            final List<Map<String, Object>> rows = new ArrayList<>();
            final Map<String, String> poolsToCreate = new CaseInsensitiveHashMap();
            final Map<String, Set<String>> poolMembers = new HashMap<>();

            ts2.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    //attempt to create a pool record for any pool referenced in this field
                    String pool_name = object.getString("pool_name");
                    if (pool_name != null && StringUtils.trimToNull(pool_name) != null && !getPeptidePool(c, pool_name, peptidePoolTable))
                    {
                        poolsToCreate.put(pool_name, pool_name);
                    }

                    Map<String, Object> row = new HashMap<>();
                    row.put("container", c.getId());
                    row.put("name", StringUtils.trimToNull(object.getString("full_name")));
                    row.put("peptideId", object.getInt("id_peptide"));
                    //a flag to force UpdateService to accept this value for peptideId, rather than auto-populating
                    row.put("_legacyDataImport", true);

                    StringBuilder comments = new StringBuilder();
                    String commentsDelim = "";
                    if (object.getString("comments") != null)
                    {
                        comments.append(commentsDelim).append(object.getString("comments"));
                        commentsDelim = "\n";
                    }

                    if ("Yes".equalsIgnoreCase(object.getString("pool_status")))
                    {
                        String poolname = StringUtils.trimToNull(object.getString("amino_acid_sequence"));
                        if (poolname != null)
                        {
                            comments.append(commentsDelim).append("Pool: " + poolname);
                            commentsDelim = "\n";
                        }
                    }
                    else
                    {
                        String aaseq = StringUtils.trimToNull(object.getString("amino_acid_sequence"));
                        aaseq = aaseq.replaceAll("-", "");
                        if (aaseq != null && aaseq.contains("B"))
                        {
                            if (aaseq.toLowerCase().contains("biotin"))
                            {
                                row.put("modification", "Biotin");
                                aaseq = aaseq.replaceAll("Biotin", "");
                            }
                        }
                        row.put("sequence", aaseq);
                        ensurePeptideExists(u, sb, aaseq, object);

                        appendPoolMember(u, c, aaseq, object, poolMembers, peptidePoolMembersTable);
                    }

                    row.put("created", new Date());
                    row.put("modified", new Date());
                    row.put("createdby", u.getUserId());
                    row.put("modifiedby", u.getUserId());

                    if (object.getString("id_watco") != null)
                    {
                        comments.append(commentsDelim).append("Watco ID: ").append(object.getString("id_watco"));
                        commentsDelim = "\n";
                    }

                    row.put("comment", comments.toString());
                    rows.add(row);
                }
            });

            sb.append("Peptides to add: " + rows.size()).append("<br>");
            sb.append("Peptide pools to add: " + poolsToCreate.size()).append("<br>");
            sb.append("Peptide pools with members to add: " + poolMembers.size()).append("<br>");
            if (!validateOnly)
            {
                ExperimentService.get().ensureTransaction();

                if (rows.size() > 0)
                {
                    QueryUpdateService update = peptideTable.getUpdateService();
                    update.setBulkLoad(true);
                    BatchValidationException errors = new BatchValidationException();
                    List<Map<String,Object>> inserted = update.insertRows(u, c, rows, errors, new HashMap<String, Object>());
                    if (errors.hasErrors())
                    {
                        throw errors;
                    }

                    sb.append("peptides created: " + inserted.size()).append("<br>");
                }

                if (poolsToCreate.size() > 0)
                {
                    List<Map<String, Object>> poolRows = new ArrayList<>();
                    for (String name : poolsToCreate.values())
                    {
                        Map<String, Object> row = new HashMap<>();
                        row.put("pool_name", StringUtils.trimToNull(name));
                        row.put("container", c.getId());
                        poolRows.add(row);
                    }

                    QueryUpdateService update = peptidePoolTable.getUpdateService();
                    update.setBulkLoad(true);
                    BatchValidationException errors = new BatchValidationException();
                    List<Map<String,Object>> inserted = update.insertRows(u, c, poolRows, errors, new HashMap<String, Object>());
                    if (errors.hasErrors())
                    {
                        throw errors;
                    }

                    sb.append("peptide pools created: " + inserted.size()).append("<br>");
                }

                ExperimentService.get().commitTransaction();

                if (poolMembers.size() > 0)
                {
                    List<Map<String, Object>> toInsert = new ArrayList<>();
                    for (String poolName : poolMembers.keySet())
                    {
                        Integer poolId = getPoolId(c, poolName, peptidePoolTable);
                        if (poolId == null)
                            throw new RuntimeException("Unable to find RowId for pool: " + poolName);

                        for (String aaseq : poolMembers.get(poolName))
                        {
                            Map<String, Object> row = new HashMap<>();
                            row.put("poolid", poolId);
                            row.put("sequence", aaseq);
                            toInsert.add(row);
                        }
                    }

                    QueryUpdateService update = peptidePoolMembersTable.getUpdateService();
                    update.setBulkLoad(true);
                    BatchValidationException errors = new BatchValidationException();
                    List<Map<String,Object>> inserted = update.insertRows(u, c, toInsert, errors, new HashMap<String, Object>());
                    if (errors.hasErrors())
                    {
                        throw errors;
                    }

                    sb.append("peptide pools members added: " + inserted.size()).append("<br>");
                }
            }

            return sb.toString();
        }
        catch (QueryUpdateServiceException e)
        {
            throw new RuntimeException(e);
        }
        catch (BatchValidationException e)
        {
            throw new RuntimeException(e);
        }
        catch (SQLException e)
        {
            throw new RuntimeException(e);
        }
        catch (DuplicateKeyException e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            ExperimentService.get().closeTransaction();
        }
    }

    private Integer getPoolId(Container c, String poolName, TableInfo poolsTable)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("container"), c.getId());
        filter.addCondition(FieldKey.fromString("pool_name"), poolName);
        TableSelector ts = new TableSelector(poolsTable, Collections.singleton("rowid"), filter, null);
        Integer[] rows = ts.getArray(Integer.class);
        return rows.length == 1 ? rows[0] : null;
    }

    private void appendPoolMember(User u, Container c, String aaseq, ResultSet object, Map<String, Set<String>> poolMembers, TableInfo peptidePoolMembersTable) throws SQLException
    {
        String pool_name = object.getString("pool_name");
        if (pool_name != null && StringUtils.trimToNull(pool_name) != null && !getPeptidePoolMember(c, pool_name, aaseq, peptidePoolMembersTable))
        {
            Set<String> members = poolMembers.get(pool_name);
            if (members == null)
                members = new HashSet<>();

            if (!members.contains(aaseq))
                members.add(aaseq);

            poolMembers.put(pool_name, members);
        }
    }

    private Map<String, Set<String>> _existingPeptides = new HashMap<>();

    private boolean getPeptidePoolMember(Container c, String pool_name, String aaseq, TableInfo peptidePoolMembersTable)
    {
        if (_existingPeptides.containsKey(pool_name))
        {
            return _existingPeptides.get(pool_name).contains(aaseq);
        }
        else
        {
            Set<FieldKey> fieldKeys = new HashSet<>();
            fieldKeys.add(FieldKey.fromString("poolid/pool_name"));
            fieldKeys.add(FieldKey.fromString("sequence"));
            final Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(peptidePoolMembersTable, fieldKeys);
            TableSelector ts = new TableSelector(peptidePoolMembersTable, colMap.values(), SimpleFilter.createContainerFilter(c), null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, colMap);
                    String name = rs.getString(FieldKey.fromString("poolid/pool_name"));
                    String aaseq = rs.getString(FieldKey.fromString("sequence"));
                    Set<String> members = _existingPeptides.get(name);
                    if (members == null)
                        members = new HashSet<>();

                    if (!members.contains(aaseq))
                        members.add(aaseq);

                    _existingPeptides.put(name, members);
                }
            });

            return _existingPeptides.containsKey(pool_name) ? _existingPeptides.get(pool_name).contains(aaseq) : false;
        }
    }

    private boolean getPeptidePool(Container c, String name, TableInfo ti)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("pool_name"), name);
        filter.addCondition(FieldKey.fromString("container"), c.getId());
        TableSelector ts = new TableSelector(ti, Collections.singleton("rowid"), filter, null);
        return ts.getRowCount() > 0;
    }

    private void ensurePeptideExists(User u, StringBuilder sb, String sequence, ResultSet row) throws SQLException
    {
        DbSchema schema = DbSchema.get("laboratory");
        TableInfo ti = schema.getTable("reference_peptides");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("sequence"), sequence);
        TableSelector ts = new TableSelector(ti, filter, null);
        long count = ts.getRowCount();

        if (count == 0)
        {
            Map<String, Object> toInsert = new HashMap<>();
            toInsert.put("sequence", sequence);

            if (row.getString("mhc_restriction") != null)
            {
                toInsert.put("mhc_restriction", row.getString("mhc_restriction"));
            }

            sb.append("Creating peptide: " + sequence).append("<br>");

            Table.insert(u, ti, toInsert);
        }
    }

    public String importGenotypeData(final ViewContext ctx, final Boolean validateOnly)
    {
        if (!ctx.getContainer().isWorkbook())
            return "This current container is not a workbook, aborting";

        final StringBuilder sb = new StringBuilder();

        UserSchema schema = QueryService.get().getUserSchema(ctx.getUser(), ctx.getContainer().getParent(), "grip");
        if (schema == null)
            throw new RuntimeException("Unable to find grip DB");

        TableInfo ti = schema.getTable("genotypes");
        if (ti == null)
            throw new RuntimeException("Unable to find genotypes table");

        AssayProvider ap = AssayService.get().getProvider("Genotype Assay");
        if (ap == null)
            throw new RuntimeException("Unable to find Genotype_Assay provider");

        List<ExpProtocol> protocols = AssayService.get().getAssayProtocols(ContainerManager.getSharedContainer(), ap);
        if (protocols == null || protocols.size() == 0)
            throw new RuntimeException("Unable to find Genotype_Assay protocol");

        final ExpProtocol protocol = protocols.get(0);

        String importMethod = "Default Excel";
        AssayImportMethod method = LaboratoryService.get().getDataProviderForAssay(ap).getImportMethodByName(importMethod);
        if (method == null)
        {
            throw new RuntimeException("Import method not recognized: " + importMethod);
        }

        final Map<String, List<Map<String, Object>>> runs = new HashMap<>();
        final Map<String, Map<String, Object>> runPropMap = new HashMap<>();

        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("animalid"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromParts("animalid"), " ", CompareType.NEQ);
        filter.addCondition(FieldKey.fromParts("abs_allele1"), ":", CompareType.DOES_NOT_CONTAIN);

        TableInfo projectTable = schema.getTable("Projects");
        TableSelector projectSelector = new TableSelector(projectTable);
        final Map<Integer, String> projectMap = new HashMap<>();
        projectSelector.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                Integer proj = rs.getInt("ProjectID");
                String projDesc = rs.getString("ProjDescription");
                projectMap.put(proj, projDesc);
            }
        });

        TableSelector ts = new TableSelector(ti, filter, new Sort("expdate"));
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                Date exptDate = rs.getDate("expdate");
                String expId = rs.getString("RemoteExpId");
                String projDescription = projectMap.get(rs.getInt("ProjectID"));

                String expName = null;
                if (exptDate != null)
                    expName = _dateFormat.format(exptDate);
                else if (expId != null)
                    expName = "Expt " + expId;

                String runName = "GRIP Genotype Data" + (expName == null ? "" : ": " + expName);
                Map<String, Object> runProps = new HashMap<>();
                runProps.put("runDate", exptDate);
                runProps.put("purpose", projDescription);

                List<? extends ExpRun> existingRuns = ExperimentService.get().getExpRuns(ctx.getContainer(), protocol, null);
                if (!existingRuns.isEmpty())
                {
                    for (ExpRun r : existingRuns)
                    {
                        if (r.getName().equals(runName))
                        {
                            sb.append("Existing run found, skipping: " + runName).append("<br>");
                            return;
                        }
                    }
                }

                Map<String, Object> row1 = new HashMap<>();
                Map<String, Object> row2 = new HashMap<>();

                String marker = rs.getString("MarkerId");
                if (marker != null)
                {
                    if (marker.endsWith("DA"))
                    {
                        runProps.put("method", "UC Davis");
                    }
                    else if (marker.endsWith("SW"))
                    {
                        runProps.put("method", "Southwest");
                    }
                }
                row1.put("subjectId", rs.getObject("AnimalId"));
                row1.put("date", rs.getObject("expdate"));
                row1.put("category", "Unknown");
                row1.put("marker", rs.getString("locus"));
                row1.put("locus", rs.getObject("locus"));
                row1.put("comment", rs.getObject("RemoteID"));

                row2.put("subjectId", rs.getObject("AnimalId"));
                row2.put("date", rs.getObject("expdate"));
                row2.put("category", "Unknown");
                row2.put("marker", rs.getString("locus"));
                row2.put("locus", rs.getObject("locus"));
                row2.put("comment", rs.getObject("RemoteID"));

                String statusflag = rs.getInt("DefMarker") == 1 ? "Definitive" :  null;
                row1.put("statusflag", statusflag);
                row2.put("statusflag", statusflag);

                boolean hasNull = false;
                if (rs.getObject("Abs_allele1") != null)
                {
                    String allele = (String)rs.getObject("Abs_allele1");
                    allele = StringUtils.trimToNull(allele);
                    if (allele != null)
                    {
                        String[] pieces = allele.split("_");
                        try
                        {
                            String token = pieces[pieces.length - 1];
                            token = StringUtils.trimToNull(token);
                            if (token == null)
                            {
                                row1.put("result", null);
                                row1.put("statusflags", "No Data");
                                hasNull = true;
                            }
                            else
                            {
                                Integer value = Integer.parseInt(token);
                                if (value == 0)
                                {
                                    row1.put("result", null);
                                    row1.put("statusflags", "No Data");
                                    hasNull = true;
                                }
                                else
                                    row1.put("result", value);
                            }
                        }
                        catch (NumberFormatException e)
                        {
                            row1.put("qual_result", pieces[pieces.length -1 ]);
                            row1.put("qcflags", "Suspect Size");
                        }
                    }
                }

                if (rs.getObject("Abs_allele2") != null)
                {
                    String allele = (String)rs.getObject("Abs_allele2");
                    allele = StringUtils.trimToNull(allele);
                    if (allele != null)
                    {
                        String[] pieces = allele.split("_");
                        try
                        {
                            String token = pieces[pieces.length - 1];
                            token = StringUtils.trimToNull(token);
                            if (token == null)
                            {
                                //no point in adding twice
                                if (!hasNull)
                                {
                                    row2.put("result", null);
                                    row2.put("statusflags", "No Data");
                                }
                            }
                            else
                            {
                                Integer value = Integer.parseInt(token);
                                if (value == 0)
                                {
                                    //no point in adding twice
                                    if (!hasNull)
                                    {
                                        row2.put("result", null);
                                        row2.put("statusflags", "No Data");
                                    }
                                }
                                else
                                    row2.put("result", value);
                            }
                        }
                        catch (NumberFormatException e)
                        {
                            row2.put("qual_result", pieces[pieces.length -1 ]);
                            row2.put("qcflags", "Suspect Size");
                        }
                    }
                }

                runPropMap.put(runName, runProps);
                List<Map<String, Object>> results = runs.get(runName);
                if (results == null)
                    results = new ArrayList<>();

                if (row1.containsKey("result") || row1.containsKey("qual_result"))
                    results.add(row1);

                if (row2.containsKey("result") || row2.containsKey("qual_result"))
                    results.add(row2);

                runs.put(runName, results);
            }
        });

        createRuns(ctx, protocol, validateOnly, runPropMap, sb, runs, method, "STR");

        return sb.toString();
    }

    public String importSNPData(final ViewContext ctx, final Boolean validateOnly)
    {
        if (!ctx.getContainer().isWorkbook())
            return "This current container is not a workbook, aborting";

        final StringBuilder sb = new StringBuilder();

        UserSchema schema = QueryService.get().getUserSchema(ctx.getUser(), ctx.getContainer().getParent(), "grip");
        if (schema == null)
            throw new RuntimeException("Unable to find grip DB");

        TableInfo ti = schema.getTable("genotypes");
        if (ti == null)
            throw new RuntimeException("Unable to find genotypes table");

        AssayProvider ap = AssayService.get().getProvider("SNP Assay");
        if (ap == null)
            throw new RuntimeException("Unable to find SNP_Assay provider");

        List<ExpProtocol> protocols = AssayService.get().getAssayProtocols(ContainerManager.getSharedContainer(), ap);
        if (protocols == null || protocols.size() == 0)
            throw new RuntimeException("Unable to find SNP_Assay protocol");

        final ExpProtocol protocol = protocols.get(0);

        String importMethod = "Default Excel";
        AssayImportMethod method = LaboratoryService.get().getDataProviderForAssay(ap).getImportMethodByName(importMethod);
        if (method == null)
        {
            throw new RuntimeException("Import method not recognized: " + importMethod);
        }

        final Map<String, List<Map<String, Object>>> runs = new HashMap<>();
        final Map<String, Map<String, Object>> runPropMap = new HashMap<>();

        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("animalid"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromParts("animalid"), " ", CompareType.NEQ);
        filter.addCondition(FieldKey.fromParts("abs_allele1"), ":", CompareType.CONTAINS);

        TableSelector ts = new TableSelector(ti, filter, new Sort("expdate"));
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                Date exptDate = rs.getDate("expdate");
                String expId = rs.getString("RemoteExpId");

                String expName = null;
                if (exptDate != null)
                    expName = _dateFormat.format(exptDate);
                else if (expId != null)
                    expName = "Expt " + expId;

                String runName = "GRIP SNP Data" + (expName == null ? "" : ": " + expName);
                Map<String, Object> runProps = new HashMap<>();
                runProps.put("runDate", exptDate);
                runPropMap.put(runName, runProps);

                List<? extends ExpRun> existingRuns = ExperimentService.get().getExpRuns(ctx.getContainer(), protocol, null);
                if (!existingRuns.isEmpty())
                {
                    for (ExpRun r : existingRuns)
                    {
                        if (r.getName().equals(runName))
                        {
                            sb.append("Existing run found, skipping: " + runName).append("<br>");
                            return;
                        }
                    }
                }

                Map<String, Object> row1 = new HashMap<>();
                Map<String, Object> row2 = new HashMap<>();

                row1.put("subjectId", rs.getObject("AnimalId"));
                row1.put("date", rs.getObject("expdate"));
                row1.put("category", "Unknown");
                row1.put("marker", rs.getString("MarkerId"));

                row2.put("subjectId", rs.getObject("AnimalId"));
                row2.put("date", rs.getObject("expdate"));
                row2.put("category", "Unknown");
                row2.put("marker", rs.getString("MarkerId"));

                String statusflag = rs.getInt("DefMarker") == 1 ? "Definitive" :  null;
                row1.put("statusflag", statusflag);
                row2.put("statusflag", statusflag);

                if (rs.getObject("Abs_allele1") != null)
                {
                    String allele = (String)rs.getObject("Abs_allele1");
                    allele = StringUtils.trimToNull(allele);
                    if (allele != null)
                    {
                        String[] pieces = allele.split(":");
                        row1.put("ref_nt_name", pieces[0]);

                        String[] tokens = pieces[1].split("_");
                        try
                        {
                            row1.put("position", Integer.parseInt(tokens[0]));
                        }
                        catch (NumberFormatException e)
                        {
                            _log.error(e.getMessage(), e);
                        }

                        row1.put("nt", tokens[1]);
                    }
                }

                if (rs.getObject("Abs_allele2") != null)
                {
                    String allele = (String)rs.getObject("Abs_allele2");
                    allele = StringUtils.trimToNull(allele);
                    if (allele != null)
                    {
                        String[] pieces = allele.split(":");
                        row2.put("ref_nt_name", pieces[0]);

                        String[] tokens = pieces[1].split("_");
                        try
                        {
                            row2.put("position", Integer.parseInt(tokens[0]));
                        }
                        catch (NumberFormatException e)
                        {
                            _log.error(e.getMessage(), e);
                        }

                        row2.put("nt", tokens[1]);
                    }
                }

                List<Map<String, Object>> results = runs.get(runName);
                if (results == null)
                    results = new ArrayList<>();

                if (row1.containsKey("marker"))
                    results.add(row1);

                if (row2.containsKey("marker"))
                    results.add(row2);

                runs.put(runName, results);
            }
        });

        createRuns(ctx, protocol, validateOnly, runPropMap, sb, runs, method, "STR");

        return sb.toString();
    }

    public String importMHCData(final ViewContext ctx, final Boolean validateOnly)
    {
        if (!ctx.getContainer().isWorkbook())
            return "This current container is not a workbook, aborting";

        final StringBuilder sb = new StringBuilder();
        UserSchema schema = QueryService.get().getUserSchema(ctx.getUser(), ctx.getContainer().getParent(), "grip");
        if (schema == null)
            throw new RuntimeException("Unable to find grip DB");

        TableInfo ti = schema.getTable("mhctype");
        if (ti == null)
            throw new RuntimeException("Unable to find mhctype table");

        AssayProvider ap = AssayService.get().getProvider("SSP Typing");
        if (ap == null)
            throw new RuntimeException("Unable to find SSP Typing provider");

        List<ExpProtocol> protocols = AssayService.get().getAssayProtocols(ContainerManager.getSharedContainer(), ap);
        if (protocols == null || protocols.size() == 0)
            throw new RuntimeException("Unable to find SSP Typing protocol");

        final ExpProtocol protocol = protocols.get(0);

        String importMethod = "Default Excel";
        AssayImportMethod method = LaboratoryService.get().getDataProviderForAssay(ap).getImportMethodByName(importMethod);
        if (method == null)
        {
            throw new RuntimeException("Import method not recognized: " + importMethod);
        }

        final Map<String, List<Map<String, Object>>> runs = new HashMap<>();
        final Map<String, Map<String, Object>> runPropMap = new HashMap<>();

        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("animalid"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromParts("animalid"), " ", CompareType.NEQ);
        TableSelector ts = new TableSelector(ti, filter, new Sort("expid"));
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                Integer exptId = rs.getInt("expid");
                String runName = "GRIP SSP Data" + (exptId == null ? "" : ": Expt " + exptId);

                List<? extends ExpRun> existingRuns = ExperimentService.get().getExpRuns(ctx.getContainer(), protocol, null);
                if (!existingRuns.isEmpty())
                {
                    for (ExpRun r : existingRuns)
                    {
                        if (r.getName().equals(runName))
                        {
                            sb.append("Existing run found, skipping: " + runName).append("<br>");
                            return;
                        }
                    }
                }

                Map<String, Object> row1 = new HashMap<>();

                row1.put("subjectId", rs.getObject("AnimalId"));
                row1.put("category", "Unknown");

                String marker = rs.getString("marker");
                if (marker.equalsIgnoreCase("AO1"))
                    marker = "A01";
                else if (marker.equalsIgnoreCase("401"))
                    marker = "DRB10401/06/11";

                row1.put("primerPair", marker);

                Integer resultInt = rs.getInt("test");
                String result = null;
                switch  (resultInt)
                {
                    case 1:
                        result = "POS";
                        break;
                    case 0:
                        result = "NEG";
                        break;
                    case 2:
                        result = "IND";
                        break;
                };

                row1.put("result", result);

                String statusflag = rs.getInt("DefMarker") == 1 ? "Definitive" :  null;
                row1.put("statusflag", statusflag);

                List<Map<String, Object>> results = runs.get(runName);
                if (results == null)
                    results = new ArrayList<>();

                results.add(row1);

                runs.put(runName, results);
            }
        });

        createRuns(ctx, protocol, validateOnly, runPropMap, sb, runs, method);

        return sb.toString();
    }

    private void createRuns(ViewContext ctx, ExpProtocol protocol, boolean validateOnly, Map<String, Map<String, Object>> runPropMap, StringBuilder sb, Map<String, List<Map<String, Object>>> runs, AssayImportMethod method)
    {
        createRuns(ctx, protocol, validateOnly, runPropMap, sb, runs, method, null);
    }

    private void createRuns(ViewContext ctx, ExpProtocol protocol, boolean validateOnly, Map<String, Map<String, Object>> runPropMap, StringBuilder sb, Map<String, List<Map<String, Object>>> runs, AssayImportMethod method, String assayType)
    {
        for (String name : runs.keySet())
        {
            List<Map<String, Object>> rows = runs.get(name);
            sb.append("<br>-----------------------<br>");
            JSONObject json = new JSONObject();
            JSONObject runProperties = new JSONObject();

            runProperties.put(ExperimentJSONConverter.NAME, name);
            if (runPropMap.containsKey(name))
            {
                runProperties.putAll(runPropMap.get(name));
            }
            if (assayType != null)
                runProperties.put("assayType", assayType);


            json.put("Run", runProperties);

            JSONObject batchProperties = new JSONObject();
            batchProperties.put(ExperimentJSONConverter.NAME, name);
            json.put("Batch", batchProperties);

            JSONArray jsonArray = new JSONArray();
            sb.append(name).append("<br>");
            sb.append("Rows: " + rows.size() + "<br>");
            for (Map<String, Object> row : rows)
            {
                jsonArray.put(row);
//                sb.append("......").append("<br>");
//                for (String key : row.keySet())
//                {
//                    sb.append(key).append(": ").append(row.get(key)).append("<br>");
//                }
            }
            json.put("ResultRows", jsonArray);

            json.put("errorLevel", "ERROR");

            FileContentService svc = ServiceRegistry.get().getService(FileContentService.class);
            File root = svc.getFileRoot(ctx.getContainer(), FileContentService.ContentType.files);
            if (!root.exists())
                root.mkdir();

            root = new File(root, "assaydata");
            if (!root.exists())
                root.mkdir();

            if (!validateOnly)
            {
                try
                {
                    File f = new File(root, name + ".tsv");
                    if (f.exists())
                        f.delete();

                    f.createNewFile();
                    ViewContext ctx2 = new ViewContext(ctx);
                    ctx2.setContainer(ctx.getContainer());

                    AssayParser parser = method.getFileParser(ctx.getContainer(), ctx.getUser(), protocol.getRowId());
                    parser.saveBatch(json, f, f.getName(), ctx2);
                    _log.info("created run: " + name + ", " + rows.size() + " rows");
                }
                catch (BatchValidationException e)
                {
                    for (ValidationException ve : e.getRowErrors())
                    {
                        _log.error(ve.getMessage(), ve);
                    }
                    _log.error(e.getMessage(), e);
                }
                catch (IOException e)
                {
                    throw new RuntimeException(e);
                }
            }
        }
    }

    public void populateHxColumn(Container c, User u) throws Exception
    {
        UserSchema us = QueryService.get().getUserSchema(u, c, "study");
        if (us == null)
        {
            throw new IllegalArgumentException("Unable to find study schema");
        }

        TableInfo ti = us.getTable("cases");
        if (ti == null)
        {
            throw new IllegalArgumentException("Unable to find cases table");
        }

        TableInfo realTable = DbSchema.get("studydataset", DbSchemaType.Provisioned).getTable(ti.getDomain().getStorageTableName());

        //clinical cases
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("assessmentOnOpenDate"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromString("category"), "Clinical");
        filter.addCondition(FieldKey.fromString("remark"), null, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("isOpen"), true, CompareType.EQUAL);
        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, PageFlowUtil.set(FieldKey.fromString("lsid"), FieldKey.fromString("remark"), FieldKey.fromString("enddate"), FieldKey.fromString("remark"), FieldKey.fromString("assessmentOnOpenDate")));
        TableSelector ts = new TableSelector(ti, cols.values(), filter, null);

        final List<Map<String, Object>> toUpdate = new ArrayList<>();
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                Results rs = new ResultsImpl(object, cols);

                Map<String, Object> row = new CaseInsensitiveHashMap<>();
                row.put("lsid", rs.getString("lsid"));

                //only update if case is open
                if (rs.getObject("remark") == null && rs.getObject("assessmentOnOpenDate") != null)
                {
                     row.put("remark", rs.getObject("assessmentOnOpenDate"));
                     toUpdate.add(row);
                }
            }
        });

        _log.info("Updating " + toUpdate.size() + " clinical cases");
        for (Map<String, Object> row : toUpdate)
        {
            Table.update(u, realTable, row, row.get("lsid"));
        }
    }

    public void importAnimalGroupMembers(ViewContext vc) throws Exception
    {
        Container c = vc.getContainer();
        User u = vc.getUser();

        final List<Map<String, Object>> toImport = new ArrayList<>();

        TableInfo ti = QueryService.get().getUserSchema(u, c, "ehr").getTable("animal_group_members");
        new TableSelector(ti).forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet rs) throws SQLException
            {
                Map<String, Object> row = new CaseInsensitiveHashMap<>();
                row.put("Id", rs.getString("Id"));
                row.put("date", rs.getDate("date"));
                row.put("enddate", rs.getDate("enddate"));
                row.put("groupId", rs.getInt("groupId"));
                row.put("remark", rs.getString("remark"));
                row.put("taskid", rs.getString("taskid"));
                row.put("objectid", rs.getString("objectid"));
                row.put("releaseType", rs.getString("releaseType"));

                toImport.add(row);
            }
        });

        _log.info("total rows to insert: " + toImport.size());

        int start = 0;
        int batchSize = 1000;
        Map<String, Object> ctx = new HashMap<>();
        ctx.put("quickValidation", true);
        ctx.put("dataSource", "etl");

        TableInfo ds = QueryService.get().getUserSchema(u, c, "study").getTable("animal_group_members");
        QueryUpdateService qus = ds.getUpdateService();
        qus.setBulkLoad(true);
        ExperimentService.get().ensureTransaction();
        try
        {
            while (start < toImport.size())
            {
                List<Map<String, Object>> sublist = toImport.subList(start, Math.min(toImport.size(), start + batchSize));
                start = start + batchSize;

                //get demographics records as a batch ot save import time
                Set<String> ids = new HashSet<>();
                for (Map<String, Object> row : sublist)
                {
                    ids.add((String)row.get("Id"));
                }
                EHRDemographicsService.get().getAnimals(c, ids);

                BatchValidationException errors = new BatchValidationException();
                _log.info("processing " + batchSize + " rows");
                qus.insertRows(u, c, sublist, errors, ctx);
                ExperimentService.get().commitTransaction();

                if (errors.hasErrors())
                    throw errors;

                ExperimentService.get().ensureTransaction();
            }
        }
        finally
        {
            ExperimentService.get().closeTransaction();
        }
    }
}
