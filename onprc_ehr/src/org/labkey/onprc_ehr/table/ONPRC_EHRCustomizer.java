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
package org.labkey.onprc_ehr.table;

import org.apache.log4j.Logger;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableCustomizer;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.gwt.client.FacetingBehaviorType;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.query.QueryDefinition;
import org.labkey.api.query.QueryException;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.study.DataSetTable;
import org.labkey.api.view.HttpView;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/7/12
 * Time: 2:22 PM
 */
public class ONPRC_EHRCustomizer implements TableCustomizer
{
    private Map<String, UserSchema> _userSchemas;
    private static final Logger _log = Logger.getLogger(ONPRC_EHRCustomizer.class);

    public ONPRC_EHRCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        _userSchemas = new HashMap<String, UserSchema>();

        if (table instanceof AbstractTableInfo)
        {
            customizeColumns((AbstractTableInfo) table);

            if (table instanceof DataSetTable)
            {
                customizeDataset((AbstractTableInfo) table);
            }

            if (matches(table, "study", "Animal"))
            {
                customizeAnimalTable((AbstractTableInfo)table);
            }
            else if (matches(table, "study", "Birth"))
            {
                customizeBirthTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Housing"))
            {
                customizeHousingTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Urinalysis Results") || matches(table, "study", "urinalysisResults"))
            {
                customizeUrinalysisTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Cases") || matches(table, "study", "Case"))
            {
                customizeCasesTable((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "project"))
            {
                customizeProjects((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "protocol"))
            {
                customizeProtocol((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr_lookups", "room") || matches(table, "ehr_lookups", "rooms"))
            {
                customizeRooms((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr_lookups", "cage"))
            {
                customizeCageTable((AbstractTableInfo) table);
            }
        }
    }

    private void customizeDataset(AbstractTableInfo ds)
    {
        UserSchema us = getStudyUserSchema(ds);
        if (us != null)
        {
            appendAssignmentAtTimeCol(us, ds);
            appendGroupsAtTimeCol(us, ds);
            appendProblemsAtTimeCol(us, ds);
        }
    }

    private void customizeColumns(AbstractTableInfo ti)
    {
        ColumnInfo project = ti.getColumn("project");
        if (project != null && !ti.getName().equalsIgnoreCase("project"))
        {
            UserSchema us = getUserSchema(ti, "ehr");
            if (us != null)
                project.setFk(new QueryForeignKey(us, "project", "project", "name"));
        }

        ColumnInfo account = ti.getColumn("account");
        if (account != null && !ti.getName().equalsIgnoreCase("accounts"))
        {
            account.setLabel("Alias");
            if (account.getFk() == null)
            {
                UserSchema us = getUserSchema(ti, "onprc_billing");
                if (us != null)
                    account.setFk(new QueryForeignKey(us, "accounts", "account", "account"));
            }

            if (ti instanceof DataSetTable)
            {
                account.setHidden(true);
            }
        }

        ColumnInfo protocolCol = ti.getColumn("protocol");
        if (protocolCol != null)
        {
            UserSchema us = getUserSchema(ti, "ehr");
            if (us != null){
                protocolCol.setFk(new QueryForeignKey(us, "protocol", "protocol", "displayName"));
            }
            protocolCol.setLabel("Protocol");
            protocolCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
        }

        boolean found = false;
        for (String field : new String[]{"grant", "grantNumber"})
        {
            if (found)
                continue; //a table should never contain both of these anyway

            ColumnInfo grant = ti.getColumn(field);
            if (grant!= null)
            {
                found = true;
                if (!ti.getName().equalsIgnoreCase("grants") && grant.getFk() == null)
                {
                    UserSchema us = getUserSchema(ti, "onprc_billing");
                    if (us != null)
                        grant.setFk(new QueryForeignKey(us, "grants", "grantNumber", "grantNumber"));
                }
            }
        }

        ColumnInfo room = ti.getColumn("room");
        if (room != null)
        {
            room.setDisplayWidth("120");
        }

        ColumnInfo location = ti.getColumn("location");
        if (location != null)
        {
            location.setDisplayWidth("120");
        }

        ColumnInfo chargeId = ti.getColumn("chargeId");
        if (chargeId != null)
        {
            UserSchema us = getUserSchema(ti, "onprc_billing");
            if (us != null){
                chargeId.setFk(new QueryForeignKey(us, "chargeableItems", "rowid", "name"));
            }
            chargeId.setLabel("Charge Name");
        }

        ColumnInfo snomed = ti.getColumn("snomed");
        if (snomed != null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null){
                snomed.setFk(new QueryForeignKey(us, "snomed", "code", "meaning"));
            }
            snomed.setLabel("SNOMED");
        }

        ColumnInfo procedureId = ti.getColumn("procedureId");
        if (procedureId != null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null){
                procedureId.setFk(new QueryForeignKey(us, "procedures", "rowid", "name"));
            }
            procedureId.setLabel("Procedure");
        }

        found = false;
        for (String field : new String[]{"investigator", "investigatorId"})
        {
            if (found)
                continue; //a table should never contain both of these anyway

            ColumnInfo investigator = ti.getColumn(field);
            if (investigator != null)
            {
                found = true;
                investigator.setLabel("Investigator");

                if (!ti.getName().equalsIgnoreCase("investigators") && investigator.getJavaClass().equals(Integer.class))
                {
                    UserSchema us = getUserSchema(ti, "onprc_ehr");
                    if (us != null){
                        investigator.setFk(new QueryForeignKey(us, "investigators", "rowid", "lastname"));
                    }
                }
                investigator.setLabel("Investigator");
            }
        }

        ColumnInfo fiscalAuthority = ti.getColumn("fiscalAuthority");
        if (fiscalAuthority != null)
        {
            UserSchema us = getUserSchema(ti, "onprc_billing");
            if (us != null){
                fiscalAuthority.setFk(new QueryForeignKey(us, "fiscalAuthorities", "rowid", "lastName"));
            }
            fiscalAuthority.setLabel("Fiscal Authority");
        }

        for (String field : new String[]{"awardEndDate", "budgetEndDate"})
        {
            ColumnInfo endDate = ti.getColumn(field);
            if (endDate != null)
            {
                String label = endDate.getLabel();
                appendEnddate(ti, endDate, label);
            }
        }

        ColumnInfo caseId = ti.getColumn("caseid");
        if (caseId != null && !ti.getName().equalsIgnoreCase("cases"))
        {
            caseId.setLabel("Case");
            if (caseId.getFk() == null)
            {
                UserSchema us = getUserSchema(ti, "study");
                if (us != null)
                    caseId.setFk(new QueryForeignKey(us, "cases", "objectid", "caseid"));
            }
        }

    }

    private void customizeAnimalTable(AbstractTableInfo ds)
    {
        UserSchema us = getStudyUserSchema(ds);
        if (us == null){
            return;
        }

        if (ds.getColumn("activeFlags") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activeFlags", "flagsPivoted");
            col.setLabel("Active Flags");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("openProblems") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "openProblems", "demographicsActiveProblems");
            col.setLabel("Open Problems");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("activeNotes") == null)
        {
            ColumnInfo col2 = getWrappedIdCol(us, ds, "activeNotes", "notesPivoted");
            col2.setLabel("Active Notes");
            //col.setDescription("");
            ds.addColumn(col2);
        }

        if (ds.getColumn("demographicsActiveAssignment") == null)
        {
            ColumnInfo col21 = getWrappedIdCol(us, ds, "activeAssignments", "demographicsActiveAssignment");
            col21.setLabel("Assignments - Active");
            col21.setDescription("Shows all projects to which the animal is actively assigned on the current date");
            ds.addColumn(col21);
        }

        if (ds.getColumn("demographicsAssignmentHistory") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "assignmentHistory", "demographicsAssignmentHistory");
            col.setLabel("Assignments - Total");
            col.setDescription("Shows all projects to which the animal has ever been assigned, including active projects");
            ds.addColumn(col);
        }

        if (ds.getColumn("availBlood") == null)
        {
            ColumnInfo bloodCol = getWrappedIdCol(us, ds, "availBlood", "demographicsBloodSummary");
            bloodCol.setLabel("Blood Remaining");
            bloodCol.setDescription("Calculates the total blood draw and remaining, which is determined by weight and blood drawn.");
            ds.addColumn(bloodCol);
        }

        if (ds.getColumn("numPaired") == null)
        {
            ColumnInfo col21 = getWrappedIdCol(us, ds, "numPaired", "demographicsPaired");
            col21.setLabel("Pairing");
            col21.setDescription("Shows all animals paired with the current animal");
            ds.addColumn(col21);
        }

        if (ds.getColumn("physicalExamHistory") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "physicalExamHistory", "demographicsPE");
            col.setLabel("Physical Exam History");
            col.setDescription("Shows the date of last physical exam for each animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("labworkHistory") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "labworkHistory", "demographicsLabwork");
            col.setLabel("Labwork History");
            col.setDescription("Shows the date of last labwork for a subsets of tests");
            ds.addColumn(col);
        }

        if (ds.getColumn("MostRecentTB") == null)
        {
            ColumnInfo col17 = getWrappedIdCol(us, ds, "MostRecentTB", "demographicsMostRecentTBDate");
            col17.setLabel("TB Tests");
            col17.setDescription("Calculates the most recent TB date for this animal, time since TB and the last eye TB tested");
            ds.addColumn(col17);
        }
    }

    private void customizeCasesTable(AbstractTableInfo ti)
    {
        appendLatestHxCol(ti);
        appendCaseHistoryCol(ti);
    }

    private void customizeHousingTable(AbstractTableInfo ti)
    {
        if (ti.getColumn("effectiveCage") == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            if (us != null)
            {
                ColumnInfo lsidCol = ti.getColumn("lsid");
                ColumnInfo col = ti.addColumn(new WrappedColumn(lsidCol, "effectiveCage"));
                col.setLabel("Lowest Joined Cage");
                col.setUserEditable(false);
                col.setIsUnselectable(true);
                col.setFk(new QueryForeignKey(us, "housingEffectiveCage", "lsid", "effectiveCage"));
            }
        }
    }

    private void customizeBirthTable(AbstractTableInfo ti)
    {
        ColumnInfo cond = ti.getColumn("cond");
        if (cond != null)
        {
            cond.setLabel("Birth Condition");
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null)
            {
                cond.setFk(new QueryForeignKey(us, "birth_condition", "value", "value"));
            }
        }

    }

    private void appendLatestHxCol(AbstractTableInfo ti)
    {
        String hxName = "latestHx";
        if (ti.getColumn(hxName) != null)
            return;

        TableInfo clinRemarks = getStudyUserSchema(ti).getTable("Clinical Remarks");
        if (clinRemarks == null)
            return;

        TableInfo realTable = getRealTable(clinRemarks);
        if (realTable == null)
        {
            _log.error("Unable to find read table for clin remarks");
            return;
        }

        ColumnInfo objectId = ti.getColumn("objectid");
        String chr = ti.getSqlDialect().isPostgreSQL() ? "chr" : "char";
        SQLFragment sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'Hx: '", "r.hx")), false, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE r.date = (SELECT max(date) as expr FROM " + realTable.getSelectName() + " r2 WHERE r2.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND r2.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r2.hx is not null)" +
                " AND r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid)"
        );
        ExprColumn latestHx = new ExprColumn(ti, hxName, sql, JdbcType.VARCHAR, objectId);
        latestHx.setLabel("Latest Hx");
        latestHx.setDisplayWidth("300");
        ti.addColumn(latestHx);

        SQLFragment p2Sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'P2: '", "r.p2")), false, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.p2 IS NOT NULL AND CAST(r.date AS date) = CAST(? as date))", new Date());
        ExprColumn todaysP2 = new ExprColumn(ti, "todaysP2", p2Sql, JdbcType.VARCHAR, objectId);
        todaysP2.setLabel("P2s Entered Today");
        todaysP2.setDisplayWidth("300");
        ti.addColumn(todaysP2);
    }

    private void customizeProtocol(AbstractTableInfo ti)
    {
        ti.getColumn("inves").setHidden(true);
        ti.getColumn("investigatorId").setHidden(false);
        ColumnInfo externalId = ti.getColumn("external_id");
        externalId.setHidden(false);
        externalId.setLabel("eIACUC #");

        if (ti.getColumn("totalProjects") == null)
        {
            UserSchema us = getUserSchema(ti, "ehr");
            if (us != null)
            {
                ColumnInfo protocolCol = ti.getColumn("protocol");
                ColumnInfo col2 = ti.addColumn(new WrappedColumn(protocolCol, "totalProjects"));
                col2.setLabel("Total Projects");
                col2.setUserEditable(false);
                col2.setIsUnselectable(true);
                col2.setFk(new QueryForeignKey(us, "protocolTotalProjects", "protocol", "protocol"));
            }
        }

        String name = "displayName";
        if (ti.getColumn(name) == null)
        {
            SQLFragment sql = new SQLFragment("COALESCE(" + ExprColumn.STR_TABLE_ALIAS + ".external_id, " + ExprColumn.STR_TABLE_ALIAS + ".protocol)");
            ExprColumn displayCol = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, ti.getColumn("external_id"), ti.getColumn("protocol"));
            displayCol.setLabel("Display Name");
            ti.addColumn(displayCol);

            ti.setTitleColumn(name);
        }
    }

    private void customizeProjects(AbstractTableInfo ti)
    {
        ti.setTitleColumn("name");

        ti.getColumn("inves").setHidden(true);
        ti.getColumn("inves2").setHidden(true);
        ti.getColumn("reqname").setHidden(true);
        ti.getColumn("research").setHidden(true);
        ti.getColumn("avail").setHidden(true);

        ti.getColumn("project").setLabel("Project Id");
        ti.getColumn("project").setHidden(true);

        ColumnInfo invest = ti.getColumn("investigatorId");
        invest.setHidden(false);
        UserSchema us = getUserSchema(ti, "onprc_ehr");
        if (us != null)
            invest.setFk(new QueryForeignKey(us, "investigators", "rowid", "lastname"));

        ColumnInfo nameCol = ti.getColumn("name");
        nameCol.setHidden(false);
        nameCol.setLabel("Project");
    }

    private void customizeRooms(AbstractTableInfo ti)
    {
        UserSchema us = getUserSchema(ti, "ehr_lookups");

        ColumnInfo roomCol = ti.getColumn("room");
        ColumnInfo assignments = ti.getColumn("assignments");
        if (assignments == null)
        {
            WrappedColumn col = new WrappedColumn(roomCol, "assignments");
            col.setReadOnly(true);
            col.setIsUnselectable(true);
            col.setUserEditable(false);
            col.setFk(new QueryForeignKey(us, "roomsAssignment", "room", "room"));
            ti.addColumn(col);
        }
    }

    private ColumnInfo getWrappedIdCol(UserSchema us, AbstractTableInfo ds, String name, String queryName)
    {
        String ID_COL = "Id";
        WrappedColumn col = new WrappedColumn(ds.getColumn(ID_COL), name);
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new QueryForeignKey(us, queryName, ID_COL, ID_COL));

        return col;
    }

    private UserSchema getStudyUserSchema(AbstractTableInfo ds)
    {
        return getUserSchema(ds, "study");
    }

    public UserSchema getUserSchema(AbstractTableInfo ds, String name)
    {
        if (!(ds instanceof FilteredTable))
        {
            return null;
        }

        if (_userSchemas.containsKey(name))
            return _userSchemas.get(name);

        User u;
        Container c = ((FilteredTable)ds).getContainer();

        if (HttpView.hasCurrentView()){
            u = HttpView.currentContext().getUser();
        }
        else
        {
            u = EHRService.get().getEHRUser(c);
        }

        if (u == null)
            return null;

        UserSchema us = QueryService.get().getUserSchema(u, c, name);
        if (us != null)
            _userSchemas.put(name, us);

        return us;
    }

    private boolean matches(TableInfo ti, String schema, String query)
    {
        return ti.getSchema().getName().equalsIgnoreCase(schema) && ti.getName().equalsIgnoreCase(query);
    }

    private void appendEnddate(AbstractTableInfo ti, ColumnInfo sourceCol, String label)
    {
        String sourceColName = sourceCol.getName();
        if (ti.getColumn(sourceColName + "Coalesced") == null)
        {
            SQLFragment sql = new SQLFragment("COALESCE(" + ExprColumn.STR_TABLE_ALIAS + "." + sourceColName + ", {fn curdate()})");
            ExprColumn col = new ExprColumn(ti, sourceColName + "Coalesced", sql, JdbcType.TIMESTAMP);
            col.setCalculated(true);
            col.setUserEditable(false);
            col.setHidden(true);
            col.setLabel(label);
            ti.addColumn(col);
        }
    }

    private void customizeCageTable(AbstractTableInfo table)
    {

//        if (table.getColumn("row") == null)
//        {
//            ColumnInfo cageCol = table.getColumn("cage");
//
//            SQLFragment sql = new SQLFragment(table.getSqlDialect().getSubstringFunction(ExprColumn.STR_TABLE_ALIAS + ".cage", "1", "1"));
//            ExprColumn rowCol = new ExprColumn(table, "row", sql, JdbcType.VARCHAR, cageCol);
//            rowCol.setLabel("Row");
//            table.addColumn(rowCol);
//
//            String colSql = table.getSqlDialect().getSubstringFunction(ExprColumn.STR_TABLE_ALIAS + ".cage", "2", table.getSqlDialect().getVarcharLengthFunction() + "(" + ExprColumn.STR_TABLE_ALIAS + ".cage)");
//            colSql = "(" + colSql + ")";
//            if (table.getSqlDialect().isSqlServer())
//            {
//                colSql = "CASE WHEN ISNUMERIC(" + colSql + ") = 1 THEN CAST(" + colSql + " AS INTEGER) ELSE null END";
//            }
//            else if (table.getSqlDialect().isPostgreSQL())
//            {
//                colSql = "CASE WHEN (" + colSql + ") ~ '^[0-9]+$' THEN CAST(" + colSql + " AS INTEGER) ELSE null END";
//            }
//            else
//            {
//                throw new UnsupportedOperationException("Unknown SQL Dialect: " + table.getSqlDialect().toString());
//            }
//
//            SQLFragment sql2 = new SQLFragment(colSql);
//            ExprColumn columnCol = new ExprColumn(table, "column", sql2, JdbcType.INTEGER, cageCol);
//            columnCol.setLabel("Column");
//            table.addColumn(columnCol);
//        }

        String name = "availability";
        if (table.getColumn(name) == null)
        {

        }
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

    private void appendCaseHistoryCol(AbstractTableInfo ti)
    {
        if (ti.getColumn("caseHistory") != null)
            return;

        ColumnInfo ci = new WrappedColumn(ti.getColumn("Id"), "caseHistory");
        ci.setDisplayColumnFactory(new DisplayColumnFactory()
        {
            @Override
            public DisplayColumn createRenderer(final ColumnInfo colInfo)
            {
                return new DataColumn(colInfo){

                    public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
                    {
                        String objectid = (String)ctx.get("objectid");
                        String id = (String)ctx.get("Id");

                        out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" onclick=\"EHR.Utils.showCaseHistory('" + objectid + "', '" + id + "', this);\">Show Case History</a></span>");
                    }

                    @Override
                    public void addQueryFieldKeys(Set<FieldKey> keys)
                    {
                        super.addQueryFieldKeys(keys);
                        keys.add(FieldKey.fromString("objectid"));
                    }

                    public boolean isSortable()
                    {
                        return false;
                    }

                    public boolean isFilterable()
                    {
                        return false;
                    }

                    public boolean isEditable()
                    {
                        return false;
                    }
                };
            }
        });
        ci.setIsUnselectable(false);
        ci.setLabel("Case History");

        ti.addColumn(ci);
    }


    private void customizeUrinalysisTable(AbstractTableInfo ti)
    {
        String name = "results";
        if (ti.getColumn(name) == null)
        {
            //this provides a single column that rolls together the 3 possible sources of results into a single string
            String resultSql = "CAST(" + ExprColumn.STR_TABLE_ALIAS + ".result AS VARCHAR)";
            String resultOORSql = "COALESCE(" + ExprColumn.STR_TABLE_ALIAS + ".resultoorindicator, '')";
            SQLFragment sql = new SQLFragment("CASE \n" +
                    " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".rangeMax IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".result IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".qualResult IS NOT NULL THEN \n" +
                        ti.getSqlDialect().concatenate(resultOORSql, resultSql, "'-'", "CAST(" + ExprColumn.STR_TABLE_ALIAS + ".rangeMax AS VARCHAR)", "', '", ExprColumn.STR_TABLE_ALIAS + ".qualResult") + "\n" +
                    " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".rangeMax IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".result IS NOT NULL THEN \n" +
                        ti.getSqlDialect().concatenate(resultOORSql, resultSql, "'-'", "CAST(" + ExprColumn.STR_TABLE_ALIAS + ".rangeMax AS VARCHAR)") + "\n" +
                    " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".result IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".qualResult IS NOT NULL THEN \n" +
                        ti.getSqlDialect().concatenate(resultOORSql, resultSql, "', '", ExprColumn.STR_TABLE_ALIAS + ".qualResult") + "\n" +
                    " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".result IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".qualResult IS NULL THEN \n" +
                        ti.getSqlDialect().concatenate(resultOORSql, resultSql) + "\n" +
                    " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".qualResult IS NOT NULL THEN \n" +
                        ExprColumn.STR_TABLE_ALIAS + ".qualResult \n" +
                    " ELSE null \n" +
                    " END"
            );
            ExprColumn newCol = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, ti.getColumn("result"), ti.getColumn("rangeMax"), ti.getColumn("qualResult"));
            newCol.setLabel("Results");
            newCol.setHidden(true);
            newCol.setDisplayWidth("50");
            newCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
            ti.addColumn(newCol);
        }
    }

    private void appendAssignmentAtTimeCol(final UserSchema us, final AbstractTableInfo ds)
    {
        String name = "assignmentAtTime";
        if (ds.getColumn(name) != null)
            return;

        WrappedColumn col = new WrappedColumn(ds.getColumn("lsid"), name);
        col.setLabel("Assignments At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = ds.getName() + "_assignmentsAtTime";
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd.lsid,\n" +
                        "group_concat(DISTINCT h.project.name) as AssignmentsAtTime\n" +
                        "FROM study.\"" + ds.getName() + "\" sd\n" +
                        "JOIN study.assignment h\n" +
                        "  ON (sd.id = h.id AND h.date <= sd.date AND sd.date < COALESCE(h.enddate, now()) AND h.qcstate.publicdata = true)\n" +
                        "group by sd.lsid");
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<QueryException>();
                TableInfo ti = qd.getTable(errors, true);

                ti.getColumn("lsid").setHidden(true);
                ti.getColumn("lsid").setKeyField(true);

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendProblemsAtTimeCol(final UserSchema us, final AbstractTableInfo ds)
    {
        final String colName = "problemsAtTime";
        if (ds.getColumn(colName) != null)
            return;

        WrappedColumn col = new WrappedColumn(ds.getColumn("lsid"), colName);
        col.setLabel("Problems At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = ds.getName() + "_" + colName;
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd.lsid,\n" +
                        "group_concat(DISTINCT h.category) as ProblemsAtTime\n" +
                        "FROM study.\"" + ds.getName() + "\" sd\n" +
                        "JOIN study.\"Problem List\" h\n" +
                        "  ON (sd.id = h.id AND h.date <= sd.date AND sd.date < COALESCE(h.enddate, now()) AND h.qcstate.publicdata = true)\n" +
                        "group by sd.lsid");
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<QueryException>();
                TableInfo ti = qd.getTable(errors, true);

                ti.getColumn("lsid").setHidden(true);
                ti.getColumn("lsid").setKeyField(true);

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendGroupsAtTimeCol(final UserSchema us, final AbstractTableInfo ds)
    {
        final String colName = "groupsAtTime";
        if (ds.getColumn(colName) != null)
            return;

        WrappedColumn col = new WrappedColumn(ds.getColumn("lsid"), colName);
        col.setLabel("Groups At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = ds.getName() + "_" + colName;
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd.lsid,\n" +
                        "group_concat(DISTINCT h.groupId.name) as GroupsAtTime\n" +
                        "FROM study.\"" + ds.getName() + "\" sd\n" +
                        "JOIN ehr.animal_group_members h\n" +
                        "  ON (sd.id = h.id AND h.date <= sd.date AND sd.date < COALESCE(h.enddate, now()))\n" +
                        "group by sd.lsid");
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<QueryException>();
                TableInfo ti = qd.getTable(errors, true);
                if (errors.size() > 0)
                {
                    for (QueryException error : errors)
                    {
                        _log.error(error.getMessage(), error);
                    }
                    return null;
                }

                ti.getColumn("lsid").setHidden(true);
                ti.getColumn("lsid").setKeyField(true);

                return ti;
            }
        });

        ds.addColumn(col);
    }
}
