/*
 * Copyright (c) 2013 LabKey Corporation
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

import com.sun.deploy.services.ServiceManager;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.AbstractFileUploadAction;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
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
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.exp.api.ExperimentJSONConverter;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.files.FileContentService;
import org.labkey.api.gwt.client.util.StringUtils;
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

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 2/23/13
 * Time: 11:40 AM
 */
public class LegacyDataManager
{
    private static final LegacyDataManager _instance = new LegacyDataManager();
    private static final Logger _log = Logger.getLogger(LegacyDataManager.class);

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

                    Map<String, Object> row = new HashMap<String, Object>();
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

                            List<File> toMove = new ArrayList<File>();
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

    private Map<Integer, User> _userMap = new HashMap<Integer, User>();

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
        Map<String, Object>[] userRows = ts.getArray(Map.class);
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
            Map<String, Object>[] ret = ts2.getArray(Map.class);
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
        TableSelector ts = new TableSelector(elispotTable, Table.ALL_COLUMNS, filter, new Sort("id_experiment"));

        final FileContentService svc = ServiceRegistry.get().getService(FileContentService.class);
        final Map<Container, List<Map<String, Object>>> runs = new HashMap<Container, List<Map<String, Object>>>();
        final Map<Container, String> nameMap = new HashMap<Container, String>();
        final Map<Container, Date> runDateMap = new HashMap<Container, Date>();

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
                Map<String, Object> row = new HashMap<String, Object>();
                Integer expt = rs.getInt("id_experiment");
                Container workbook = resolveWorkbookFromId(expt, ctx.getUser(), ctx.getContainer());
                String runName = "Expt: " + expt;

                ExpRun[] existingRuns = ExperimentService.get().getExpRuns(workbook, protocol, null);
                if (existingRuns.length > 0)
                {
                    for (ExpRun r : existingRuns)
                    {
                        if (r.getName().equals(runName))
                        {
                            sb.append("Existing run found, skipping: " + runName);
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
                //row.put("concentration", rs.getObject("peptide_concentration"));

                if (rs.getObject("date") instanceof Date)
                {
                    runDateMap.put(workbook, (Date)rs.getObject("date"));
                }

                String peptide = (String)row.get("peptide");
                if (peptide != null && peptide.matches(" (\\d+)\\DM$"))
                {
                    String[] tokens = peptide.split(" ");
                    peptide = tokens[0];
                    Integer conc = Integer.parseInt(tokens[1].replaceAll("\\D", ""));

                    row.put("peptide", peptide);
                    row.put("concentration", conc);
                }

                if ("No Peptide".equalsIgnoreCase((String)row.get("peptide")))
                {
                    row.put("peptide", "No Stim");
                }

                if ("Con A".equalsIgnoreCase((String)row.get("peptide")))
                {
                    row.put("category", "Pos Control");

                }
                else if ("No Stim".equalsIgnoreCase((String)row.get("peptide")))
                {
                    row.put("category", "Neg Control");
                }
                else
                {
                    row.put("category", "Unknown");
                }

                List<Map<String, Object>> results = runs.get(workbook);
                if (results == null)
                    results = new ArrayList<Map<String, Object>>();

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
                        _log.error(e.getMessage(), e);
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
            final List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
            final List<Map<String, Object>> poolRows = new ArrayList<Map<String, Object>>();
            ExperimentService.get().ensureTransaction();

            ts2.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    if ("Yes".equalsIgnoreCase(object.getString("pool_status")))
                    {
                        Map<String, Object> row = new HashMap<String, Object>();
                        String name = object.getString("id_peptide");
                        if (!getPeptidePool(name, peptidePoolTable))
                        {
                            row.put("pool_name", name);
                            poolRows.add(row);
                        }
                        return;
                    }

                    Map<String, Object> row = new HashMap<String, Object>();
                    row.put("container", c.getId());
                    row.put("name", object.getString("id_peptide"));
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
                    row.put("created", new Date());
                    row.put("modified", new Date());
                    row.put("createdby", u.getUserId());
                    row.put("modifiedby", u.getUserId());

                    StringBuilder comments = new StringBuilder();
                    if (object.getString("comments") != null)
                    {
                        comments.append(object.getString("comments"));
                    }

                    if (object.getString("id_watco") != null)
                    {
                        if (comments.length() > 0)
                            comments.append("\n");

                        comments.append("Watco ID: ").append(object.getString("id_watco"));
                    }

                    row.put("comment", comments.toString());

                    ensurePeptideExists(u, sb, aaseq, object);

                    rows.add(row);
                }
            });

            sb.append("Peptides to add: " + rows.size()).append("<br>");
            sb.append("Peptide pools to add: " + poolRows.size()).append("<br>");
            if (!validateOnly)
            {
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

                if (poolRows.size() > 0)
                {
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
            }

            ExperimentService.get().commitTransaction();

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

    private boolean getPeptidePool(String name, TableInfo ti)
    {
        TableSelector ts = new TableSelector(ti, Table.ALL_COLUMNS, new SimpleFilter("pool_name", name), null);
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
            Map<String, Object> toInsert = new HashMap<String, Object>();
            toInsert.put("sequence", sequence);

            if (row.getString("mhc_restriction") != null)
            {
                toInsert.put("mhc_restriction", row.getString("mhc_restriction"));
            }

            sb.append("Creating peptide: " + sequence).append("<br>");

            Table.insert(u, ti, toInsert);
        }
    }
}
