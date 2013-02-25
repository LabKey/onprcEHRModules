package org.labkey.onprc_ehr.legacydata;

import com.sun.deploy.services.ServiceManager;
import org.apache.commons.io.FileUtils;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.Selector;
import org.labkey.api.data.Sort;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.files.FileContentService;
import org.labkey.api.gwt.client.util.StringUtils;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.services.ServiceRegistry;

import java.io.File;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
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

    private LegacyDataManager()
    {

    }

    public static LegacyDataManager getInstance()
    {
        return _instance;
    }

    public String importSachaExperiments(final User u, final Container c, final File sourceFolder, final Boolean validateOnly)
    {
        final StringBuilder sb = new StringBuilder();
        UserSchema us = QueryService.get().getUserSchema(u, c, "sacha_db");
        if (us == null)
            throw new RuntimeException("Unable to find sasha_db mysql schema");

        TableInfo exptTable = us.getTable("experiments");
        if (exptTable == null)
            throw new RuntimeException("Unable to find experiments table");

        DbSchema labSchema = DbSchema.get("laboratory");
        final TableInfo workbooksTable = labSchema.getTable("workbooks");

        final FileContentService svc = ServiceRegistry.get().getService(FileContentService.class);
        TableSelector ts = new TableSelector(exptTable);
        ExperimentService.get().ensureTransaction();
        try
        {
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    sb.append("<br>----------------------------------<br>");

                    Map<String, Object> row = new HashMap<String, Object>();
                    row.put("created", rs.getObject("experiment_date"));

                    //TODO: resolve user
                    //row.put("createdby", rs.getObject("id_user"));

                    Integer exptId = rs.getInt("id_experiment");
                    row.put("workbookId", exptId);

                    String title = rs.getString("experiment_title");
                    StringBuilder description = new StringBuilder();
                    String delim = "";

                    if (!StringUtils.isEmpty(rs.getString("experiment_description")))
                    {
                        description.append(delim).append(rs.getString("experiment_description"));
                        delim = "\n\n";
                    }

                    if (!StringUtils.isEmpty(rs.getString("experiment_materials")))
                    {
                        description.append(delim).append("Materials: \n").append(rs.getString("experiment_materials"));
                        delim = "\n\n";
                    }

                    if (!StringUtils.isEmpty(rs.getString("experiment_methods")))
                    {
                        description.append(delim).append("Methods: \n").append(rs.getString("experiment_methods"));
                        delim = "\n\n";
                    }

                    if (!StringUtils.isEmpty(rs.getString("experiment_results")))
                    {
                        description.append(delim).append("Results: \n").append(rs.getString("experiment_results"));
                        delim = "\n\n";
                    }

                    for (String key : row.keySet())
                    {
                        sb.append(key).append(": ").append(row.get(key)).append("<br>");
                    }

                    sb.append("Title: ").append(title).append("<br>");
                    sb.append("Description: ").append(description).append("<br>");
                    if (description.length() > 3999)
                    {
                        sb.append("Description longer than 4000 chars: " + description.length()).append("<br><br>");
                    }

                    try
                    {
                        ExperimentService.get().ensureTransaction();

                        Container workbook = null;
                        if (!validateOnly)
                        {
                            workbook = ContainerManager.createContainer(c, null, title, description.toString(), Container.TYPE.workbook, u);

                            TableSelector wbs = new TableSelector(workbooksTable, Collections.singleton("rowid"), null, null);

                            Integer rowids[] = wbs.getArray(Integer.class);
                            if (rowids.length == 0)
                            {
                                throw new RuntimeException("Unable to find laboratory.workbooks row for id: " + workbook.getId());
                            }

                            row.put("workbookId", exptId);

                            row.put("container", workbook.getId());
                            Table.update(u, workbooksTable, row, rowids[0]);
                        }

                        if (sourceFolder != null)
                        {
                            File root = null;
                            if (workbook != null)
                            {
                                root = svc.getFileRoot(workbook);
                                if (!root.exists())
                                    root.mkdir();
                            }

                            File expected = new File(sourceFolder, exptId.toString());
                            if (expected.exists())
                            {
                                sb.append("Found existing files to move<br>");

                                if (!validateOnly && root != null)
                                {
                                    for (File child : expected.listFiles())
                                    {
                                        FileUtils.moveFileToDirectory(child, root, false);
                                    }
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

            ExperimentService.get().commitTransaction();
        }
        finally
        {
            ExperimentService.get().closeTransaction();
        }

        return sb.toString();
    }

    public String importElispotResults(final User u, final Container c, final File sourceFolder, final Boolean validateOnly)
    {
        final StringBuilder sb = new StringBuilder();

        UserSchema us = QueryService.get().getUserSchema(u, c, "sacha_db");
        if (us == null)
            throw new RuntimeException("Unable to find sasha_db mysql schema");

        TableInfo exptTable = us.getTable("elispot_results");
        if (exptTable == null)
            throw new RuntimeException("Unable to find elispot_results table");

        TableSelector ts = new TableSelector(exptTable, Table.ALL_COLUMNS, null, new Sort("id_experiment"));

        ExperimentService.get().ensureTransaction();
        try
        {
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    sb.append("<br>----------------------------------<br>");

                    Map<String, Object> row = new HashMap<String, Object>();
                    row.put("workbook", rs.getObject("id_experiment"));
                    row.put("subjectId", rs.getObject("id_animal"));
                    row.put("sampleDate", rs.getObject("sample_date"));
                    row.put("cell_number", rs.getObject("cell_number"));
                    row.put("peptide", rs.getObject("id_peptide"));
                    row.put("well", rs.getObject("id_well"));
                    row.put("spots", rs.getObject("spots"));
                    row.put("cell_number", rs.getObject("cell_number"));
                    row.put("run_date", rs.getObject("run_date")); //TODO
                    row.put("comments", rs.getObject("comments"));
                    row.put("concentration", rs.getObject("concentration"));
                    row.put("result", rs.getObject("peptide_result")); //TODO


                    //TODO: category
                }
            });

            ExperimentService.get().commitTransaction();
        }
        finally
        {
            ExperimentService.get().closeTransaction();
        }



                    return sb.toString();
    }
}
