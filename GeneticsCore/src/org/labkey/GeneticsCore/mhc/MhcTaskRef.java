package org.labkey.GeneticsCore.mhc;

import org.apache.commons.lang3.StringUtils;
import org.apache.xmlbeans.XmlException;
import org.jetbrains.annotations.NotNull;
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
import org.labkey.api.di.TaskRefTask;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.pipeline.CancelledException;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.util.GUID;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.writer.ContainerUser;

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

public class MhcTaskRef implements TaskRefTask
{
    private static final String lastRunTime = "lastRunTime";
    private static final String PROP_CATEGORY = "geneticscore.MhcAggregationPipelineJob";

    @Override
    public RecordedActionSet run(@NotNull PipelineJob job) throws PipelineJobException
    {
        Date lastRun = getLastRun(job.getContainer());

        SimpleDateFormat _dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd kk:mm");
        job.getLogger().info("Last run: " + (lastRun == null ? "never" : _dateTimeFormat.format(lastRun)));
        Date jobStart = new Date();

        Set<String> subjects = getIdsWithChangesForAssay(job, lastRun);
        job.getLogger().info("Total subjects to process: " + subjects.size());

        for (String subject : subjects)
        {
            processSubject(job, subject);

            if (job.isCancelled())
            {
                throw new CancelledException();
            }
        }

        job.getLogger().info("Done!");
        saveLastRun(job.getContainer(), jobStart);

        return new RecordedActionSet();
    }

    @Override
    public List<String> getRequiredSettings()
    {
        return null;
    }

    @Override
    public void setSettings(Map<String, String> settings) throws XmlException
    {

    }

    @Override
    public void setContainerUser(ContainerUser containerUser)
    {

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

    private Date getLastRun(Container c)
    {
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(c, PROP_CATEGORY, true);
        return map.containsKey(lastRunTime) ? new Date(Long.parseLong(map.get(lastRunTime))) : null;
    }

    private void processSubject(PipelineJob job, String subject) throws PipelineJobException
    {
        job.getLogger().info("Processing: " + subject);
        UserSchema us = QueryService.get().getUserSchema(job.getUser(), getTargetContainer(job), "geneticscore");
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
                job.getLogger().info("deleting existing rows: " + toDelete.size());
                mhcData.getUpdateService().deleteRows(job.getUser(), getTargetContainer(job), toDelete, null, null);
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
                job.getLogger().info("inserting rows: " + toInsert.size());
                BatchValidationException bve = new BatchValidationException();
                mhcData.getUpdateService().insertRows(job.getUser(), getTargetContainer(job), toInsert, bve, null, null);
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

    private List<AssayProtocolSchema> getAssays(PipelineJob job)
    {
        List<AssayProtocolSchema> sources = new ArrayList<>();
        sources.add(getAssaySchema(job, "GenotypeAssay", "Genotype"));
        sources.add(getAssaySchema(job, "SSP_assay", "SSP"));

        return Collections.unmodifiableList(sources);
    }

    private Set<String> getIdsWithChangesForAssay(PipelineJob job, Date dateSince)
    {
        Set<String> uniqueIds = new HashSet<>();
        final List<AssayProtocolSchema> assays = getAssays(job);
        for (AssayProtocolSchema assay : assays)
        {
            //Assay itself:
            TableInfo tableInfo = assay.createDataTable(null);
            TableSelector ts = new TableSelector(tableInfo, PageFlowUtil.set("subjectId"), (dateSince == null ? null : new SimpleFilter(FieldKey.fromString("run/modified"), dateSince, CompareType.DATE_GTE)), null);
            uniqueIds.addAll(ts.getArrayList(String.class));

            //Now audit table:
            if (dateSince != null)
            {
                TableInfo auditTableInfo = QueryService.get().getUserSchema(job.getUser(), getTargetContainer(job), "auditLog").getTable("ExperimentAuditEvent");
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
                        job.getLogger().warn("Unable to find RunLsid for audit row: " + rs.getObject(FieldKey.fromString("RunLsid")));
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
                    TableInfo ti = QueryService.get().getUserSchema(job.getUser(), getTargetContainer(job), "sequenceanalysis").getTable("sequence_analyses");
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
                        TableInfo queryAuditTableInfo = QueryService.get().getUserSchema(job.getUser(), getTargetContainer(job), "auditLog").getTable("QueryUpdateAuditEvent");
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

    private Container getTargetContainer(PipelineJob job)
    {
        return job.getContainer().isWorkbook() ? job.getContainer().getParent() : job.getContainer();
    }

    private AssayProtocolSchema getAssaySchema(PipelineJob job, String providerName, String protocolName)
    {
        AssayProvider ap = AssayService.get().getProvider(providerName);
        List<ExpProtocol> protocols = AssayService.get().getAssayProtocols(getTargetContainer(job), ap);
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


        return ap.createProtocolSchema(job.getUser(), getTargetContainer(job), protocol, null);
    }
}
