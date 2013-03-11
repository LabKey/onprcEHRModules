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

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableCustomizer;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.study.DataSetTable;
import org.labkey.api.view.HttpView;

import java.util.HashMap;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/7/12
 * Time: 2:22 PM
 */
public class ONPRC_EHRCustomizer implements TableCustomizer
{
    private Map<String, UserSchema> _userSchemas;

    public ONPRC_EHRCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        _userSchemas = new HashMap<String, UserSchema>();

        if (table instanceof AbstractTableInfo)
        {
            customizeColumns((AbstractTableInfo) table);

            if (matches(table, "study", "Animal"))
            {
                customizeAnimalTable((AbstractTableInfo)table);
            }
            else if (matches(table, "study", "Birth"))
            {
                customizeBirthTable((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "project"))
            {
                customizeProjects((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "protocol"))
            {
                customizeProtocol((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr_lookups", "room"))
            {
                customizeRooms((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr_lookups", "cage"))
            {
                customizeCageTable((AbstractTableInfo) table);
            }
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

        if (table.getColumn("row") == null)
        {
            ColumnInfo cageCol = table.getColumn("cage");

            SQLFragment sql = new SQLFragment(table.getSqlDialect().getSubstringFunction(ExprColumn.STR_TABLE_ALIAS + ".cage", "1", "1"));
            ExprColumn rowCol = new ExprColumn(table, "row", sql, JdbcType.VARCHAR, cageCol);
            rowCol.setLabel("Row");
            table.addColumn(rowCol);

            String colSql = table.getSqlDialect().getSubstringFunction(ExprColumn.STR_TABLE_ALIAS + ".cage", "2", table.getSqlDialect().getVarcharLengthFunction() + "(" + ExprColumn.STR_TABLE_ALIAS + ".cage)");
            colSql = "(" + colSql + ")";
            if (table.getSqlDialect().isSqlServer())
            {
                colSql = "CASE WHEN ISNUMERIC(" + colSql + ") = 1 THEN CAST(" + colSql + " AS INTEGER) ELSE null END";
            }
            else if (table.getSqlDialect().isPostgreSQL())
            {
                colSql = "CASE WHEN (" + colSql + ") ~ '^[0-9]+$' THEN CAST(" + colSql + " AS INTEGER) ELSE null END";
            }
            else
            {
                throw new UnsupportedOperationException("Unknown SQL Dialect: " + table.getSqlDialect().toString());
            }

            SQLFragment sql2 = new SQLFragment(colSql);
            ExprColumn columnCol = new ExprColumn(table, "column", sql2, JdbcType.INTEGER, cageCol);
            columnCol.setLabel("Column");
            table.addColumn(columnCol);
        }
    }
}
