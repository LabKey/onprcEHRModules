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
import org.labkey.api.query.DetailsURL;
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

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Calendar;
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
        _userSchemas = new HashMap<>();

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
            else if (matches(table, "study", "Demographics"))
            {
                customizeDemographicsTable((AbstractTableInfo)table);
            }
            else if (matches(table, "study", "Birth"))
            {
                customizeBirthTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Matings"))
            {
                customizeMatingTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Pregnancy Confirmations"))
            {
                customizePregnancyConfirmationTable((AbstractTableInfo) table);
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
            else if (matches(table, "ehr_lookups", "areas"))
            {
                customizeAreaTable((AbstractTableInfo) table);
            }
        }

        if (matches(table, "study", "surgeryChecklist"))
        {
            customizeSurgChecklistTable((AbstractTableInfo) table);
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
            appendFlagsAtTimeCol(us, ds);
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

        customizeDateColumn(ti);

    }

    private void customizeDateColumn(AbstractTableInfo ti)
    {
        ColumnInfo dateCol = ti.getColumn("date");
        if (dateCol == null)
            return;

        String calendarYear = "calendarYear";
        if (ti.getColumn(calendarYear) == null)
        {
            SQLFragment sql = new SQLFragment(ti.getSqlDialect().getDatePart(Calendar.YEAR, ExprColumn.STR_TABLE_ALIAS + "." + dateCol.getSelectName()));
            ExprColumn calCol = new ExprColumn(ti, calendarYear, sql, JdbcType.INTEGER, dateCol);
            calCol.setLabel("Calendar Year");
            calCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
            calCol.setHidden(true);
            ti.addColumn(calCol);

            String fiscalYear = "fiscalYear";
            SQLFragment sql2 = new SQLFragment("(" + ti.getSqlDialect().getDatePart(Calendar.YEAR, ExprColumn.STR_TABLE_ALIAS + "."+ dateCol.getSelectName()) + " + CASE WHEN " + ti.getSqlDialect().getDatePart(Calendar.MONTH, ExprColumn.STR_TABLE_ALIAS + "." + dateCol.getSelectName()) + " < 5 THEN -1 ELSE 0 END)");
            ExprColumn fiscalYearCol = new ExprColumn(ti, fiscalYear, sql2, JdbcType.INTEGER, dateCol);
            fiscalYearCol.setLabel("Fiscal Year (May 1)");
            fiscalYearCol.setDescription("This column will calculate the fiscal year of the record, based on a May 1 cycle");
            fiscalYearCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
            fiscalYearCol.setHidden(true);
            ti.addColumn(fiscalYearCol);

            String fiscalYearJuly = "fiscalYearJuly";
            SQLFragment sql3 = new SQLFragment("(" + ti.getSqlDialect().getDatePart(Calendar.YEAR, ExprColumn.STR_TABLE_ALIAS + "." + dateCol.getSelectName()) + " + CASE WHEN " + ti.getSqlDialect().getDatePart(Calendar.MONTH, ExprColumn.STR_TABLE_ALIAS + "." + dateCol.getSelectName()) + " < 7 THEN -1 ELSE 0 END)");
            ExprColumn fiscalYearJulyCol = new ExprColumn(ti, fiscalYearJuly, sql3, JdbcType.INTEGER, dateCol);
            fiscalYearJulyCol.setLabel("Fiscal Year (July 1)");
            fiscalYearJulyCol.setDescription("This column will calculate the fiscal year of the record, based on a July 1 cycle");
            fiscalYearJulyCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
            fiscalYearJulyCol.setHidden(true);
            ti.addColumn(fiscalYearJulyCol);
        }
    }

    private void customizeAnimalTable(AbstractTableInfo ds)
    {
        UserSchema us = getStudyUserSchema(ds);
        if (us == null){
            return;
        }

        String curLocation = "curLocation";
        ColumnInfo existingLocation = ds.getColumn(curLocation);
        if (existingLocation != null)
            ds.removeColumn(existingLocation);

        ColumnInfo col13 = getWrappedIdCol(us, ds, curLocation, "demographicsCurrentLocation");
        col13.setLabel("Housing - Current");
        col13.setDescription("The calculates the current housing location for each living animal.");
        ds.addColumn(col13);

        if (ds.getColumn("activeFlags") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activeFlags", "flagsPivoted");
            col.setLabel("Active Flags");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("activePregnancies") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activePregnancies", "demographicsPregnancy");
            col.setLabel("Pregnancies - Active");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("kinshipAvg") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "kinshipAvg", "kinshipAverage");
            col.setLabel("Kinship - Average");
            col.setDescription("Calculates the average kinship coefficient against all living animals, including the current animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("currentCondition") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "currentCondition", "demographicsCondition");
            col.setLabel("Condition");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("offspringUnder1Yr") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "offspringUnder1Yr", "demographicsTotalOffspringUnder1Yr");
            col.setLabel("Offspring Under 1 Year");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("lastMense") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "lastMense", "demographicsLastMense");
            col.setLabel("Mense Data");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("spfStatus") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "spfStatus", "demographicsSPF");
            col.setLabel("SPF Status");
            //col.setDescription("");
            ds.addColumn(col);
        }

        if (ds.getColumn("openProblems") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "openProblems", "demographicsActiveProblems");
            col.setLabel("Open Problems");
            col.setDescription("This will display open problems for this animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("origin") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "origin", "demographicsOrigin");
            col.setLabel("Origin");
            col.setDescription("Contains fields related to the origin of the animal (ie. center vs. acquired), arrival date at the center, etc.");
            ds.addColumn(col);
        }

        if (ds.getColumn("terminal") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "terminal", "demographicsTermination");
            col.setLabel("Terminal Projects");
            col.setDescription("Summarizes whether the animal is assigned to terminal projects");
            ds.addColumn(col);
        }

        if (ds.getColumn("activeCases") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activeCases", "demographicsActiveCases");
            col.setLabel("Active Cases");
            ds.addColumn(col);
        }

        if (ds.getColumn("parents") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "parents", "demographicsParents");
            col.setLabel("Parents");
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

        if (ds.getColumn("utilization") == null)
        {
            ColumnInfo col21 = getWrappedIdCol(us, ds, "utilization", "demographicsUtilization");
            col21.setLabel("Utilization");
            col21.setDescription("Shows all projects or animal groups to which the animal is actively assigned on the current date");
            ds.addColumn(col21);
        }

        if (ds.getColumn("viral_status") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "viral_status", "demographicsViralStatus");
            col.setLabel("Viral Status");
            col.setDescription("Shows the viral status of each animal");
            ds.addColumn(col);
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
        appendSurgeryCol(ti);
        appendCaseHistoryCol(ti);

        String problemCategories = "problemCategories";
        if (ti.getColumn(problemCategories) == null)
        {
            TableInfo pl = getStudyUserSchema(ti).getTable("Problem List");
            if (pl == null)
                return;

            TableInfo realTable = getRealTable(pl);
            if (realTable == null)
                return;

            String chr = ti.getSqlDialect().isPostgreSQL() ? "chr" : "char";
            SQLFragment sql = new SQLFragment("(select " + ti.getSqlDialect().getGroupConcat(new SQLFragment("pl.category"), true, true, chr + "(10)") + " FROM " + realTable.getSelectName() + " pl WHERE pl.caseId = " + ExprColumn.STR_TABLE_ALIAS + ".objectid)");
            ExprColumn newCol = new ExprColumn(ti, problemCategories, sql, JdbcType.VARCHAR, ti.getColumn("objectid"));
            newCol.setLabel("Master Problem(s)");
            ti.addColumn(newCol);
        }

        String isActive = "isActive";
        if (ti.getColumn(isActive) == null)
        {
            SQLFragment sql = new SQLFragment("(CASE WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NOT NULL) THEN " + ti.getSqlDialect().getBooleanFALSE() + " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".reviewdate IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".reviewdate <= {fn curdate()}) THEN " + ti.getSqlDialect().getBooleanTRUE() + " ELSE " + ti.getSqlDialect().getBooleanTRUE() + " END)");
            ExprColumn newCol = new ExprColumn(ti, isActive, sql, JdbcType.BOOLEAN, ti.getColumn("enddate"), ti.getColumn("reviewdate"));
            newCol.setLabel("Is Active?");
            ti.addColumn(newCol);
        }
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

        if (ti.getColumn("daysInRoom") == null)
        {
            TableInfo realTable = getRealTable(ti);
            if (realTable != null)
            {
                SQLFragment roomSql = new SQLFragment(realTable.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "(SELECT max(h2.enddate) as d FROM " + realTable.getSelectName() + " h2 WHERE h2.enddate IS NOT NULL AND h2.enddate <= " + ExprColumn.STR_TABLE_ALIAS + ".date AND h2.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid and h2.room != " + ExprColumn.STR_TABLE_ALIAS + ".room)"));
                ExprColumn roomCol = new ExprColumn(ti, "daysInRoom", roomSql, JdbcType.INTEGER, realTable.getColumn("participantid"), realTable.getColumn("date"), realTable.getColumn("enddate"));
                roomCol.setLabel("Days In Room");
                ti.addColumn(roomCol);

            }
        }

        if (ti.getColumn("daysInArea") == null)
        {
            TableInfo realTable = getRealTable(ti);
            if (realTable != null)
            {
                SQLFragment sql = new SQLFragment(realTable.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "(SELECT max(h2.enddate) as d FROM " + realTable.getSelectName() + " h2 LEFT JOIN ehr_lookups.rooms r1 ON (r1.room = h2.room) WHERE h2.enddate IS NOT NULL AND h2.enddate <= " + ExprColumn.STR_TABLE_ALIAS + ".date AND h2.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid and r1.area != (select area FROM ehr_lookups.rooms r WHERE r.room = " + ExprColumn.STR_TABLE_ALIAS + ".room))"));
                ExprColumn areaCol = new ExprColumn(ti, "daysInArea", sql, JdbcType.INTEGER, realTable.getColumn("participantid"), realTable.getColumn("date"), realTable.getColumn("enddate"));
                areaCol .setLabel("Days In Area");
                ti.addColumn(areaCol );

            }
        }

        String cagePosition = "cagePosition";
        if (ti.getColumn(cagePosition) == null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null)
            {
                WrappedColumn wrapped = new WrappedColumn(ti.getColumn("cage"), cagePosition);
                wrapped.setLabel("Cage Position");
                wrapped.setIsUnselectable(true);
                wrapped.setUserEditable(false);
                wrapped.setFk(new QueryForeignKey(us, "cage_positions", "cage", "cage"));
                ti.addColumn(wrapped);
            }
        }
    }

    private void customizeDemographicsTable(AbstractTableInfo ti)
    {
        ColumnInfo originCol = ti.getColumn("origin");
        if (originCol != null)
        {
            originCol.setLabel("Source");
        }
    }

    private void customizeMatingTable(AbstractTableInfo ti)
    {
        String colName = "outcome";
        if (ti.getColumn(colName) == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            if (us != null)
            {
                WrappedColumn wrapped = new WrappedColumn(ti.getColumn("lsid"), colName);
                wrapped.setLabel("Mating Outcome");
                wrapped.setIsUnselectable(true);
                wrapped.setUserEditable(false);
                wrapped.setFk(new QueryForeignKey(us, "matingOutcome", "lsid", "confirmations"));

                ti.addColumn(wrapped);
            }
        }
    }

    private void customizePregnancyConfirmationTable(AbstractTableInfo ti)
    {
        String colName = "outcome";
        if (ti.getColumn(colName) == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            if (us != null)
            {
                WrappedColumn wrapped = new WrappedColumn(ti.getColumn("lsid"), colName);
                wrapped.setLabel("Pregnancy Outcome");
                wrapped.setIsUnselectable(true);
                wrapped.setUserEditable(false);
                wrapped.setFk(new QueryForeignKey(us, "pregnancyOutcome", "lsid", "confirmations"));

                ti.addColumn(wrapped);
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

        UserSchema us = getStudyUserSchema(ti);
        TableInfo clinRemarks = us.getTable("Clinical Remarks");
        if (clinRemarks == null)
            return;

        TableInfo realTable = getRealTable(clinRemarks);
        if (realTable == null)
        {
            _log.error("Unable to find real table for clin remarks");
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
        latestHx.setDisplayWidth("250");
        ti.addColumn(latestHx);

        SQLFragment p2Sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'P2: '", "r.p2")), false, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.p2 IS NOT NULL AND CAST(r.date AS date) = CAST(? as date))", new Date());
        ExprColumn todaysP2 = new ExprColumn(ti, "todaysP2", p2Sql, JdbcType.VARCHAR, objectId);
        todaysP2.setLabel("P2s Entered Today");
        todaysP2.setDisplayWidth("250");
        ti.addColumn(todaysP2);

        Calendar yesterday = Calendar.getInstance();
        yesterday.setTime(new Date());
        yesterday.add(Calendar.DATE, -1);

        SQLFragment p2Sql2 = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'P2: '", "r.p2")), false, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.p2 IS NOT NULL AND CAST(r.date AS date) = CAST(? as date))", yesterday.getTime());
        ExprColumn yesterdaysP2 = new ExprColumn(ti, "yesterdaysP2", p2Sql2, JdbcType.VARCHAR, objectId);
        yesterdaysP2.setLabel("P2s Entered Yesterday");
        yesterdaysP2.setDisplayWidth("250");
        ti.addColumn(yesterdaysP2);

        SQLFragment rmSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.remark"), false, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.remark IS NOT NULL AND CAST(r.date AS date) = CAST(? as date))", new Date());
        ExprColumn todaysRemarks = new ExprColumn(ti, "todaysRemarks", rmSql, JdbcType.VARCHAR, objectId);
        todaysRemarks.setLabel("Remarks Entered Today");
        todaysRemarks.setDisplayWidth("250");
        ti.addColumn(todaysRemarks);
    }

    private void appendSurgeryCol(AbstractTableInfo ti)
    {
        String name = "proceduresPerformed";
        if (ti.getColumn(name) != null)
            return;

        UserSchema us = getStudyUserSchema(ti);
        TableInfo clinRemarks = us.getTable("Clinical Encounters");
        if (clinRemarks == null)
            return;

        TableInfo realTable = getRealTable(clinRemarks);
        if (realTable == null)
        {
            _log.error("Unable to find real table for clin encounters");
            return;
        }

        //find any surgical procedures from the same date as this case
        String chr = ti.getSqlDialect().isPostgreSQL() ? "chr" : "char";
        SQLFragment procedureSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("p.name"), false, false, chr + "(10)") +
                " FROM " + realTable.getSelectName() + " r " +
                " JOIN ehr_lookups.procedures p ON (p.rowid = r.procedureid) " +
                //r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND
                " WHERE r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId " +
                " AND CAST(r.date AS date) = CAST(" + ExprColumn.STR_TABLE_ALIAS + ".date as date) " +
                " AND r.type = 'Surgery')");
        ExprColumn procedureCol = new ExprColumn(ti, name, procedureSql, JdbcType.VARCHAR, ti.getColumn("date"));
        procedureCol.setLabel("Procedures Performed On This Date");
        procedureCol.setDisplayWidth("300");
        ti.addColumn(procedureCol);
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

        String renewalDate = "renewalDate";
        if (ti.getColumn(renewalDate) == null)
        {
            //NOTE: day used instead of year to be PG / LK12.3 compatible
            String sqlString = "(CASE WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NULL THEN {fn timestampadd(SQL_TSI_DAY, 1095, " + ExprColumn.STR_TABLE_ALIAS + ".approve)} ELSE null END)";
            SQLFragment sql = new SQLFragment(sqlString);
            ExprColumn renewalCol = new ExprColumn(ti, renewalDate, sql, JdbcType.DATE, ti.getColumn("approve"));
            renewalCol.setLabel("Next Renewal Date");
            ti.addColumn(renewalCol);

            String daysUntil = "daysUntilRenewal";
            SQLFragment sql2 = new SQLFragment("(CASE " +
                    " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NULL " +
                    " THEN (" + ti.getSqlDialect().getDateDiff(Calendar.DATE, sqlString, "{fn curdate()}") + ") " +
                    " ELSE NULL END)");
            ExprColumn daysUntilCol = new ExprColumn(ti, daysUntil, sql2, JdbcType.INTEGER, ti.getColumn("approve"));
            daysUntilCol.setLabel("Days Until Renewal");
            daysUntilCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
            ti.addColumn(daysUntilCol);
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
        invest.setLabel("Project Contact");

        ColumnInfo nameCol = ti.getColumn("name");
        nameCol.setHidden(false);
        nameCol.setLabel("Project");


        String research = "isResearch";
        if (ti.getColumn(research) == null)
        {
            ColumnInfo useCol = ti.getColumn("use_category");
            SQLFragment sql1 = new SQLFragment("(CASE WHEN " + ExprColumn.STR_TABLE_ALIAS + ".use_category = 'Research' THEN 1 ELSE 0 END)");
            ExprColumn col1 = new ExprColumn(ti, research, sql1, JdbcType.INTEGER, useCol);
            col1.setLabel("Is Research?");
            col1.setHidden(true);
            ti.addColumn(col1);

            SQLFragment sql2 = new SQLFragment("(CASE WHEN " + ExprColumn.STR_TABLE_ALIAS + ".use_category IN ('U24', 'U42') THEN 1 ELSE 0 END)");
            ExprColumn col2 = new ExprColumn(ti, "isU24U42", sql2, JdbcType.INTEGER, useCol);
            col2.setLabel("Is U24/U42?");
            col2.setHidden(true);
            ti.addColumn(col2);
        }
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
        if (_userSchemas.containsKey(name))
            return _userSchemas.get(name);

        UserSchema us = ds.getUserSchema();
        if (us != null)
        {
            _userSchemas.put(us.getName(), us);

            if (name.equalsIgnoreCase(us.getName()))
                return us;

            UserSchema us2 = QueryService.get().getUserSchema(us.getUser(), us.getContainer(), name);
            if (us2 != null)
                _userSchemas.put(name, us2);

            return us2;
        }

        return null;
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

    private void customizeSurgChecklistTable(TableInfo table)
    {
        ColumnInfo plt = table.getColumn("PLT");
        if (plt != null)
        {
            plt.setDisplayColumnFactory(new DisplayColumnFactory()
            {
                @Override
                public DisplayColumn createRenderer(final ColumnInfo colInfo)
                {
                    return new DataColumn(colInfo){

                        public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
                        {
                            String runId = (String)ctx.get("runIdPLT");
                            String id = (String)ctx.get("Id");
                            out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" onclick=\"EHR.Utils.showRunSummary('" + runId + "', '" + id + "', this);\">" + getFormattedValue(ctx) + "</a></span>");
                        }

                        @Override
                        public void addQueryFieldKeys(Set<FieldKey> keys)
                        {
                            super.addQueryFieldKeys(keys);
                            keys.add(FieldKey.fromString("runIdPLT"));
                            keys.add(FieldKey.fromString("Id"));
                        }
                    };
                }
            });
        }

        ColumnInfo hct = table.getColumn("HCT");
        if (hct != null)
        {
            hct.setDisplayColumnFactory(new DisplayColumnFactory()
            {
                @Override
                public DisplayColumn createRenderer(final ColumnInfo colInfo)
                {
                    return new DataColumn(colInfo){

                        public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
                        {
                            String runId = (String)ctx.get("runIdHCT");
                            String id = (String)ctx.get("Id");
                            out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" onclick=\"EHR.Utils.showRunSummary('" + runId + "', '" + id + "', this);\">" + getFormattedValue(ctx) + "</a></span>");
                        }

                        @Override
                        public void addQueryFieldKeys(Set<FieldKey> keys)
                        {
                            super.addQueryFieldKeys(keys);
                            keys.add(FieldKey.fromString("runIdHCT"));
                            keys.add(FieldKey.fromString("Id"));
                        }
                    };
                }
            });
        }
    }

    private void customizeAreaTable(AbstractTableInfo table)
    {
        table.setDetailsURL(DetailsURL.fromString("/onprc_ehr/areaDetails.view?area=${area}"));
    }

    private void customizeCageTable(AbstractTableInfo table)
    {
        ColumnInfo joinToCage = table.getColumn("joinToCage");
        if (joinToCage != null)
        {
            joinToCage.setHidden(true);
        }

        String name = "availability";
        if (table.getColumn(name) == null)
        {
            ColumnInfo locationCol = table.getColumn("location");
            UserSchema us = getUserSchema(table, "ehr_lookups");
            if (us != null)
            {
                WrappedColumn col = new WrappedColumn(locationCol, name);
                col.setReadOnly(true);
                col.setIsUnselectable(true);
                col.setUserEditable(false);
                col.setFk(new QueryForeignKey(us, "availableCages", "location", "location"));
                table.addColumn(col);
            }
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

                        out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" onclick=\"EHR.Utils.showCaseHistory('" + objectid + "', '" + id + "', this);\">[Show Case Hx]</a></span>");
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
                        "  ON (sd.id = h.id AND h.dateOnly <= sd.dateOnly AND sd.dateOnly <= h.enddateCoalesced AND h.qcstate.publicdata = true)\n" +
                        "group by sd.lsid");
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
                TableInfo ti = qd.getTable(errors, true);

                ti.getColumn("lsid").setHidden(true);
                ti.getColumn("lsid").setKeyField(true);

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendFlagsAtTimeCol(final UserSchema us, final AbstractTableInfo ds)
    {
        String name = "flagsAtTime";
        if (ds.getColumn(name) != null)
            return;

        WrappedColumn col = new WrappedColumn(ds.getColumn("lsid"), name);
        col.setLabel("Flags At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = ds.getName() + "_flagsAtTime";
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd.lsid,\n" +
                        "group_concat(DISTINCT h.value, chr(10)) as FlagsAtTime\n" +
                        "FROM study.\"" + ds.getName() + "\" sd\n" +
                        "JOIN study.flags h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= sd.dateOnly AND sd.dateOnly <= h.enddateCoalesced AND h.qcstate.publicdata = true)\n" +
                        "group by sd.lsid");
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
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
                        "  ON (sd.id = h.id AND h.dateOnly <= sd.dateOnly AND sd.dateOnly <= h.enddateCoalesced AND h.qcstate.publicdata = true)\n" +
                        "group by sd.lsid");
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
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
                        "  ON (sd.id = h.id AND h.dateOnly <= sd.dateOnly AND sd.dateOnly <= h.enddateCoalesced)\n" +
                        "group by sd.lsid");
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
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
