/*
 * Copyright (c) 2012 LabKey Corporation
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

package org.labkey.genotypeassays;

import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
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
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExpData;
import org.labkey.api.exp.api.ExpExperiment;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.laboratory.LaboratoryService;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.study.assay.AssayProtocolSchema;
import org.labkey.api.study.assay.AssayProvider;
import org.labkey.api.study.assay.AssayService;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.Pair;
import org.labkey.api.view.ViewContext;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class GenotypeAssaysManager
{
    private static final GenotypeAssaysManager _instance = new GenotypeAssaysManager();
    private static final Logger _log = Logger.getLogger(GenotypeAssaysManager.class);
    public static final String GENOTYPE_ASSAY_PROVIDER = "Genotype Assay";
    public static final String SNP_ASSAY_PROVIDER = "SNP Assay";
    public static final String SSP_ASSAY_PROVIDER = "SSP Typing";

    private GenotypeAssaysManager()
    {
        // prevent external construction with a private default constructor
    }

    public static GenotypeAssaysManager get()
    {
        return _instance;
    }

    public static final String SEQUENCEANALYSIS_SCHEMA = "sequenceanalysis";
    public static final String TABLE_SEQUENCE_ANALYSES = "sequence_analyses";

    public Pair<List<Integer>, List<Integer>> cacheAnalyses(final ViewContext ctx, final ExpProtocol protocol, Integer[] analysisIds) throws IllegalArgumentException
    {
        final User u = ctx.getUser();
        final List<Integer> runsCreated = new ArrayList<>();
        final List<Integer> runsDeleted = new ArrayList<>();

        ExperimentService.get().ensureTransaction();
        try
        {
            final AssayProvider ap = AssayService.get().getProvider(GENOTYPE_ASSAY_PROVIDER);
            final TableInfo tableAnalyses = DbSchema.get(SEQUENCEANALYSIS_SCHEMA).getTable(TABLE_SEQUENCE_ANALYSES);
            TableSelector tsAnalyses = new TableSelector(tableAnalyses, PageFlowUtil.set("rowid", "container"), new SimpleFilter(FieldKey.fromString("rowid"), Arrays.asList(analysisIds), CompareType.IN), null);
            tsAnalyses.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Container rowContainer = ContainerManager.getForId(rs.getString("container"));
                    int analysisId = rs.getInt("rowid");

                    //identify existing rows in this assay
                    AssayProtocolSchema schema = ap.createProtocolSchema(u, rowContainer, protocol, null);
                    TableInfo dataTable = schema.getTable(AssayProtocolSchema.DATA_TABLE_NAME);
                    StringBuilder sql = new StringBuilder("SELECT DISTINCT t1.DataId AS value FROM (SELECT * FROM ");
                    sql.append(dataTable.getFromSQL("t", PageFlowUtil.set(FieldKey.fromString("Container"), FieldKey.fromString("DataId"), FieldKey.fromString("AnalysisId"))));
                    sql.append(" WHERE t.AnalysisId IS NOT NULL AND t.AnalysisId = ?) t1");

                    SQLFragment sqlFrag = new SQLFragment(sql, analysisId);
                    SqlSelector dataSelector = new SqlSelector(DbScope.getLabkeyScope(), sqlFrag);

                    Integer[] existingRuns = dataSelector.getArray(Integer.class);
                    for (Integer dataId : existingRuns)
                    {
                        _log.info("deleting assay run " + dataId + " as part of caching sequence results");
                        ExpData data = ExperimentService.get().getExpData(dataId);
                        ExpRun run = data.getRun();
                        run.delete(u);
                        runsDeleted.add(run.getRowId());
                    }

                    //next identify a build up the results
                    TableInfo tableAlignments = QueryService.get().getUserSchema(u, rowContainer, SEQUENCEANALYSIS_SCHEMA).getTable("alignment_summary_by_lineage");
                    if (tableAlignments == null)
                    {
                        throw new IllegalArgumentException("Unable to find alignment_summary_by_lineage query");
                    }

                    SimpleFilter filter = new SimpleFilter(FieldKey.fromString("analysis_id"), analysisId);
                    filter.addCondition(FieldKey.fromString("percent"), 1, CompareType.GT);
                    filter.addCondition(FieldKey.fromString("totalLineages"), 2, CompareType.LTE);
                    Set<FieldKey> fieldKeys = new HashSet<>();
                    fieldKeys.add(FieldKey.fromString("analysis_id"));
                    fieldKeys.add(FieldKey.fromString("analysis_id/readset/subjectid"));
                    fieldKeys.add(FieldKey.fromString("analysis_id/readset/sampledate"));
                    fieldKeys.add(FieldKey.fromString("lineages"));
                    fieldKeys.add(FieldKey.fromString("total_reads"));
                    fieldKeys.add(FieldKey.fromString("percent"));
                    final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(tableAlignments, fieldKeys);

                    TableSelector tsAlignments = new TableSelector(tableAlignments, cols.values(), filter, null);
                    final List<Map<String, Object>> rows = new ArrayList<>();
                    tsAlignments.forEach(new Selector.ForEachBlock<ResultSet>()
                    {
                        @Override
                        public void exec(ResultSet object) throws SQLException
                        {
                            Results rs = new ResultsImpl(object, cols);

                            Map<String, Object> rowMap = new CaseInsensitiveHashMap<>();
                            rowMap.put("subjectid", rs.getString(FieldKey.fromString("analysis_id/readset/subjectid")));
                            rowMap.put("date", rs.getDate(FieldKey.fromString("analysis_id/readset/sampledate")));
                            rowMap.put("marker", rs.getString(FieldKey.fromString("lineages")));
                            rowMap.put("result", rs.getDouble(FieldKey.fromString("percent")));
                            rowMap.put("qual_result", "POS");
                            rowMap.put("analysisid", rs.getInt(FieldKey.fromString("analysis_id")));

                            if (rowMap.get("subjectid") == null)
                            {
                                throw new IllegalArgumentException("One or more rows is missing a subjectId");
                            }

                            rows.add(rowMap);
                        }
                    });

                    if (!rows.isEmpty())
                    {
                        JSONObject json = new JSONObject();
                        Map<String, Object> batchProps = new HashMap<>();
                        batchProps.put("Name", "Analysis Id: " + analysisId);
                        json.put("Batch", batchProps);

                        Map<String, Object> runProps = new HashMap<>();
                        runProps.put("Name", "Analysis Id: " + analysisId);
                        runProps.put("assayType", "SBT");
                        runProps.put("runDate", new Date());
                        runProps.put("performedby", u.getDisplayName(u));
                        json.put("Run", runProps);

                        try
                        {
                            ViewContext ctxCopy = new ViewContext(ctx);
                            ctxCopy.setContainer(rowContainer);

                            _log.info("created assay run for analysis " + analysisId + " as part of caching sequence results");
                            Pair<ExpExperiment, ExpRun> ret = LaboratoryService.get().saveAssayBatch(rows, json, "sbt_cache_" + analysisId, ctxCopy, ap, protocol);
                            runsCreated.add(ret.second.getRowId());
                        }
                        catch (ValidationException e)
                        {
                            throw new IllegalArgumentException(e.getMessage());
                        }
                    }

                    //mark record as cached
                    Map<String, Object> toUpdate = new CaseInsensitiveHashMap<>();
                    toUpdate.put("rowid", analysisId);
                    toUpdate.put("makePublic", true);

                    Table.update(u, tableAnalyses, toUpdate, analysisId);
                }
            });

            ExperimentService.get().commitTransaction();

            return Pair.of(runsCreated, runsDeleted);
        }
        finally
        {
            ExperimentService.get().closeTransaction();
        }
    }
}