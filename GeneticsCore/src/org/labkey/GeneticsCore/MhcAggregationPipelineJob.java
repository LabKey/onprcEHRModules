package org.labkey.GeneticsCore;

import org.apache.commons.lang3.StringUtils;
import org.labkey.api.assay.AssayProtocolSchema;
import org.labkey.api.assay.AssayProvider;
import org.labkey.api.assay.AssayService;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.files.FileUrls;
import org.labkey.api.module.Module;
import org.labkey.api.pipeline.CancelledException;
import org.labkey.api.pipeline.PipeRoot;
import org.labkey.api.pipeline.PipelineDirectory;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.PipelineProvider;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.util.FileUtil;
import org.labkey.api.util.GUID;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.ViewBackgroundInfo;
import org.labkey.api.view.ViewContext;

import java.io.File;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class MhcAggregationPipelineJob extends PipelineJob
{
    private static final String lastRunTime = "lastRunTime";
    private static final String PROP_CATEGORY = "geneticscore.MhcAggregationPipelineJob";

    public static class Provider extends PipelineProvider
    {
        public static final String NAME = "mhcAggregationPipeline";

        public Provider(Module owningModule)
        {
            super(NAME, owningModule);
        }

        @Override
        public void updateFileProperties(ViewContext context, PipeRoot pr, PipelineDirectory directory, boolean includeAll)
        {

        }
    }

    // Default constructor for serialization
    protected MhcAggregationPipelineJob()
    {
    }

    public MhcAggregationPipelineJob(Container c, User u, ActionURL url, PipeRoot pipeRoot)
    {
        super(MhcAggregationPipelineJob.Provider.NAME, new ViewBackgroundInfo(c, u, url), pipeRoot);

        File subdir = new File(pipeRoot.getRootPath(), MhcAggregationPipelineJob.Provider.NAME);
        if (!subdir.exists())
        {
            subdir.mkdirs();
        }

        setLogFile(new File(subdir, FileUtil.makeFileNameWithTimestamp("mhcAggregation", "log")));

    }

    @Override
    public URLHelper getStatusHref()
    {
        return PageFlowUtil.urlProvider(FileUrls.class).urlBegin(getContainer());
    }

    @Override
    public String getDescription()
    {
        return null;
    }


    @Override
    public void run()
    {
        try
        {
            setStatus(TaskStatus.running);
            Date lastRun = getLastRun();

            SimpleDateFormat _dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd kk:mm");
            getLogger().info("Last run: " + (lastRun == null ? "never" : _dateTimeFormat.format(lastRun)));
            Date jobStart = new Date();

            Set<String> subjects = getIdsWithChangesForAssay(lastRun);
            getLogger().info("Total subjects to process: " + subjects.size());

            for (String subject : subjects)
            {
                processSubject(subject);

                if (isCancelled())
                {
                    throw new CancelledException();
                }
            }

            saveLastRun(getTargetContainer(), jobStart);
            getLogger().info("Done!");
            setStatus(TaskStatus.complete);
        }
        catch (PipelineJobException e)
        {
            getLogger().error("Error running job" + (e.getMessage() == null ? "" : ": " + e.getMessage()), e);
        }
    }

    public static void saveLastRun(Container container, Date jobStart)
    {
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(container, PROP_CATEGORY, true);
        if (jobStart != null)
        {
            map.put(lastRunTime, String.valueOf(jobStart.getTime()));
        }
        else
        {
            map.remove(lastRunTime);
        }

        map.save();
    }

    private Date getLastRun()
    {
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(getTargetContainer(), PROP_CATEGORY, true);
        return map.containsKey(lastRunTime) ? new Date(Long.parseLong(map.get(lastRunTime))) : null;
    }

    private void processSubject(String subject) throws PipelineJobException
    {
        getLogger().info("Processing: " + subject);
        UserSchema us = QueryService.get().getUserSchema(getUser(), getTargetContainer(), "geneticscore");
        TableInfo mhcData = us.getTable("mhc_data");

        //First delete existing rows:
        TableSelector ts = new TableSelector(mhcData, PageFlowUtil.set("rowid", "objectid", "container"), new SimpleFilter(FieldKey.fromString("subjectId"), subject, CompareType.EQUAL), null);
        if (ts.exists())
        {
            List<Map<String, Object>> toDelete = new ArrayList<>();
            ts.forEachResults(rs -> {
                toDelete.add(Map.of("rowid", rs.getString(FieldKey.fromString("rowid")), "objectid", rs.getString(FieldKey.fromString("objectid")), "container", rs.getString(FieldKey.fromString("container"))));
            });

            try
            {
                getLogger().info("deleting existing rows: " + toDelete.size());
                mhcData.getUpdateService().deleteRows(getUser(), getTargetContainer(), toDelete, null, null);
            }
            catch (InvalidKeyException | BatchValidationException | QueryUpdateServiceException | SQLException e)
            {
                throw new PipelineJobException(e);
            }
        }

        List<Map<String, Object>> toInsert = new ArrayList<>();
        Set<String> fields = PageFlowUtil.set("subjectid", "marker", "result", "assaytype", "totalTests");
        new TableSelector(us.getTable("mhc_data_source"), fields, new SimpleFilter(FieldKey.fromString("subjectId"), subject), null).forEachResults(rs -> {
            CaseInsensitiveHashMap<Object> map = new CaseInsensitiveHashMap<>();
            for (String f : fields)
            {
                map.put(f, rs.getObject(FieldKey.fromString(f)));
            }

            map.put("objectid", new GUID().toString());
            toInsert.add(map);
        });

        if (!toInsert.isEmpty())
        {
            try
            {
                getLogger().info("inserting rows: " + toInsert.size());
                BatchValidationException bve = new BatchValidationException();
                mhcData.getUpdateService().insertRows(getUser(), getTargetContainer(), toInsert, bve, null, null);
                if (bve.hasErrors())
                {
                    throw bve;
                }
            }
            catch (DuplicateKeyException | BatchValidationException | QueryUpdateServiceException | SQLException e)
            {
                throw new PipelineJobException(e);
            }
        }
    }

    private List<AssayProtocolSchema> getAssays()
    {
        List<AssayProtocolSchema> sources = new ArrayList<>();
        sources.add(getAssaySchema("GenotypeAssay", "Genotype"));
        sources.add(getAssaySchema("SSP_assay", "SSP"));

        return Collections.unmodifiableList(sources);
    }

    private Set<String> getIdsWithChangesForAssay(Date dateSince)
    {
        Set<String> uniqueIds = new HashSet<>();
        final List<AssayProtocolSchema> assays = getAssays();
        for (AssayProtocolSchema assay : assays)
        {
            //Assay itself:
            TableInfo tableInfo = assay.createDataTable(null);
            TableSelector ts = new TableSelector(tableInfo, PageFlowUtil.set("subjectId"), (dateSince == null ? null : new SimpleFilter(FieldKey.fromString("run/modified"), dateSince, CompareType.DATE_GTE)), null);
            uniqueIds.addAll(ts.getArrayList(String.class));

            //Now audit table:
            if (dateSince != null)
            {
                TableInfo auditTableInfo = QueryService.get().getUserSchema(getUser(), getTargetContainer(), "auditLog").getTable("ExperimentAuditEvent");
                SimpleFilter filter = new SimpleFilter(FieldKey.fromString("created"), dateSince, CompareType.DATE_GTE);
                filter.addCondition(FieldKey.fromString("ProtocolLsid"), assay.getProtocol().getLSID());
                TableSelector ts2 = new TableSelector(auditTableInfo, PageFlowUtil.set("ProtocolLsid", "RunLsid", "comment", "RowId"), filter, null);

                final Set<Integer> analysisIdsUpdated = new HashSet<>();
                ts2.forEachResults(rs -> {
                    String comment = rs.getString(FieldKey.fromString("comment"));
                    if (comment == null)
                    {
                        return;
                    }

                    if (rs.getString(FieldKey.fromString("RunLsid")) == null)
                    {
                        return;
                    }

                    ExpRun run = ExperimentService.get().getExpRun(rs.getString(FieldKey.fromString("RunLsid")));
                    if (run == null)
                    {
                        getLogger().warn("Unable to find RunLsid for audit row: " + rs.getObject(FieldKey.fromString("RunLsid")));
                        return;
                    }

                    if ("Deleted data row.".equals(comment) || comment.contains(" edited ") || comment.contains("Run deleted"))
                    {
                        if (run.getName().startsWith("Analysis Id: "))
                        {
                            Integer id = Integer.parseInt(run.getName().replaceAll("Analysis Id: ", ""));
                            analysisIdsUpdated.add(id);
                        }
                    }
                });

                if (!analysisIdsUpdated.isEmpty())
                {
                    Set<Integer> analysesFound = new HashSet<>();
                    TableInfo ti = QueryService.get().getUserSchema(getUser(), getTargetContainer(), "sequenceanalysis").getTable("sequence_analyses");
                    Map<FieldKey, ColumnInfo> colMap = QueryService.get().getColumns(ti, PageFlowUtil.set(FieldKey.fromString("rowid"), FieldKey.fromString("readset/subjectid")));
                    new TableSelector(ti, colMap.values(), new SimpleFilter(FieldKey.fromString("rowid"), analysisIdsUpdated, CompareType.IN), null).forEachResults(rs -> {
                        analysesFound.add(rs.getInt(FieldKey.fromString("rowid")));

                        if (rs.getString(FieldKey.fromString("readset/subjectid")) != null)
                        {
                            uniqueIds.add(rs.getString(FieldKey.fromString("readset/subjectid")));
                        }
                    });

                    analysisIdsUpdated.removeAll(analysesFound);

                    if (!analysisIdsUpdated.isEmpty())
                    {
                        TableInfo queryAuditTableInfo = QueryService.get().getUserSchema(getUser(), getTargetContainer(), "auditLog").getTable("QueryUpdateAuditEvent");
                        SimpleFilter auditFilter = new SimpleFilter(FieldKey.fromString("comment"), "A row was deleted.");
                        auditFilter.addCondition(FieldKey.fromString("SchemaName"), assay.getSchemaName());
                        auditFilter.addCondition(FieldKey.fromString("QueryName"), "Data");
                        auditFilter.addCondition(FieldKey.fromString("RowPk"), analysisIdsUpdated.stream().map(String::valueOf).collect(Collectors.toSet()), CompareType.IN);

                        TableSelector ts3 = new TableSelector(queryAuditTableInfo, PageFlowUtil.set("oldRecordMap"), auditFilter, null);
                        ts3.forEachResults(rs -> {
                            if (rs.getObject(FieldKey.fromString("oldRecordMap")) != null)
                            {
                                Map<String, String> map = new CaseInsensitiveHashMap<>(PageFlowUtil.mapFromQueryString(FieldKey.fromString("oldRecordMap").toString()));
                                if (StringUtils.trimToNull(map.get("subjectid")) != null)
                                {
                                    uniqueIds.add(map.get("subjectid"));
                                }
                            }
                        });
                    }
                }
            }
        }

        return uniqueIds;
    }

    private Container getTargetContainer()
    {
        return getContainer().isWorkbook() ? getContainer().getParent() : getContainer();
    }

    private AssayProtocolSchema getAssaySchema(String providerName, String protocolName)
    {
        AssayProvider ap = AssayService.get().getProvider(providerName);
        List<ExpProtocol> protocols = AssayService.get().getAssayProtocols(getTargetContainer(), ap);
        ExpProtocol protocol = null;
        for (ExpProtocol p : protocols)
        {
            if (protocolName.equals(p.getName()))
            {
                protocol = p;
                break;
            }
        }

        if (protocol == null)
        {
            throw new IllegalStateException("Unknown protocol: " + protocolName + "." + protocolName);
        }


        return ap.createProtocolSchema(getUser(), getTargetContainer(), protocol, null);
    }
}
