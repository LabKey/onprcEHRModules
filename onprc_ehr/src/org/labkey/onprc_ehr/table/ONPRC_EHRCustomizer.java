/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.gwt.client.FacetingBehaviorType;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.query.AliasedColumn;
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
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.study.DataSet;
import org.labkey.api.study.DataSetTable;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyService;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ehr.ONPRC_EHRManager;
import org.labkey.onprc_ehr.ONPRC_EHRSchema;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 12/7/12
 * Time: 2:22 PM
 */
public class ONPRC_EHRCustomizer extends AbstractTableCustomizer
{
    private static final Logger _log = Logger.getLogger(ONPRC_EHRCustomizer.class);
    private Map<String, DataSet> _cachedDatasets;

    public ONPRC_EHRCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        _cachedDatasets = new HashMap<>();

        if (table instanceof AbstractTableInfo)
        {
            customizeColumns((AbstractTableInfo) table);

            if (table.getColumn("date") != null)
            {
                addCalculatedCols((AbstractTableInfo) table, "date");
            }

            if (matches(table, "study", "Animal"))
            {
                customizeAnimalTable((AbstractTableInfo)table);
            }
            else if (matches(table, "ehr", "animal_groups"))
            {
                customizeAnimalGroups((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "cage_observations"))
            {
                customizeCageObservations((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Demographics"))
            {
                customizeDemographicsTable((AbstractTableInfo)table);
            }
            else if (matches(table, "study", "treatment_order"))
            {
                customizeTreatmentOrdersTable((AbstractTableInfo)table);
            }
            else if (matches(table, "study", "Clinpath Runs") || matches(table, "study", "clinpathRuns"))
            {
                customizeClinpathRunsTable((AbstractTableInfo)table);
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
            else if (matches(table, "ehr_lookups", "treatment_frequency"))
            {
                customizeTreatmentFrequency((AbstractTableInfo)table);
            }
            else if (matches(table, "ehr", "tasks") || matches(table, "ehr", "my_tasks"))
            {
                customizeTasks((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "requests") || matches(table, "ehr", "my_requests"))
            {
                customizeRequests((AbstractTableInfo) table);
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

    private boolean isDemographicsTable(TableInfo ti)
    {
        return ti.getName().equalsIgnoreCase("demographics") && ti.getPublicSchemaName().equalsIgnoreCase("study");
    }

    private void addCalculatedCols(AbstractTableInfo ds, String dateColName)
    {
        UserSchema us = getStudyUserSchema(ds);
        if (us != null && !isDemographicsTable(ds))
        {
            appendAssignmentAtTimeCol(us, ds, dateColName);
            appendGroupsAtTimeCol(us, ds, dateColName);
            appendProblemsAtTimeCol(us, ds, dateColName);
            appendFlagsAtTimeCol(us, ds, dateColName);
            appendIsAssignedAtTimeCol(us, ds, dateColName);
        }
    }

    private void customizeColumns(AbstractTableInfo ti)
    {
        ColumnInfo project = ti.getColumn("project");
        if (project != null)
        {
            project.setLabel("Center Project");
            if (!ti.getName().equalsIgnoreCase("project"))
            {
                UserSchema us = getEHRUserSchema(ti, "ehr");
                if (us != null)
                {
                    if (project.getJavaClass().equals(Integer.class))
                        project.setFk(new QueryForeignKey(us, us.getContainer(), "project", "project", "displayName"));
                    else if (project.getJavaClass().equals(String.class))
                        project.setFk(new QueryForeignKey(us, us.getContainer(), "project", "displayName", "displayName"));
                }
            }
        }

        ColumnInfo projectName = ti.getColumn("projectName");
        if (projectName != null)
        {
            projectName.setLabel("Center Project");
            if (!ti.getName().equalsIgnoreCase("project"))
            {
                UserSchema us = getEHRUserSchema(ti, "ehr");
                if (us != null)
                {
                    projectName.setFk(new QueryForeignKey(us, us.getContainer(), "projectNames", "displayName", "displayName"));
                }
            }
        }

        ColumnInfo account = ti.getColumn("account");
        if (account != null && !ti.getName().equalsIgnoreCase("accounts"))
        {
            account.setLabel("Alias");
            if (ti instanceof DataSetTable)
            {
                account.setHidden(true);
            }
        }

        ColumnInfo protocolCol = ti.getColumn("protocol");
        if (protocolCol != null)
        {
            //NOTE: we keep the lookup even on the protocol table, so we always use displayName to identify the column
            UserSchema us = getEHRUserSchema(ti, "ehr");
            if (us != null){
                protocolCol.setFk(new QueryForeignKey(us, us.getContainer(), "protocol", "protocol", "displayName"));
            }

            protocolCol.setLabel("IACUC Protocol");
            //protocolCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
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

        ColumnInfo snomed = ti.getColumn("snomed");
        if (snomed != null)
        {
            UserSchema us = getEHRUserSchema(ti, "ehr_lookups");
            if (us != null){
                snomed.setFk(new QueryForeignKey(us, us.getContainer(), "snomed", "code", "meaning"));
            }
            snomed.setLabel("SNOMED");
        }

        ColumnInfo procedureId = ti.getColumn("procedureId");
        if (procedureId != null)
        {
            UserSchema us = getEHRUserSchema(ti, "ehr_lookups");
            if (us != null){
                procedureId.setFk(new QueryForeignKey(us, us.getContainer(), "procedures", "rowid", "name"));
            }
            procedureId.setLabel("Procedure");
        }

        boolean found = false;
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
                    UserSchema us = getEHRUserSchema(ti, "onprc_ehr");
                    if (us != null){
                        investigator.setFk(new QueryForeignKey(us, us.getContainer(), "investigators", "rowid", "lastname"));
                    }
                }
                investigator.setLabel("Investigator");
            }
        }

        ColumnInfo fiscalAuthority = ti.getColumn("fiscalAuthority");
        if (fiscalAuthority != null)
        {
            UserSchema us = getUserSchema(ti, "onprc_billing_public");
            if (us != null){
                fiscalAuthority.setFk(new QueryForeignKey(us, null, "fiscalAuthorities", "rowid", "lastName"));
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
                UserSchema us = getEHRUserSchema(ti, "study");
                if (us != null)
                    caseId.setFk(new QueryForeignKey(us, null, "cases", "objectid", "category"));
            }
        }

        ColumnInfo taskId = ti.getColumn("taskId");
        if (taskId != null)
        {
            taskId.setURL(DetailsURL.fromString("/ehr/dataEntryFormDetails.view?formType=${taskid/formtype}&taskId=${taskid}"));
        }

        ColumnInfo requestId = ti.getColumn("requestId");
        if (requestId != null)
        {
            requestId.setURL(DetailsURL.fromString("/ehr/dataEntryFormDetails.view?formType=${requestId/formtype}&requestId=${requestId}"));
        }

        ColumnInfo billedby = ti.getColumn("billedby");
        if (billedby != null)
        {
            billedby.setLabel("Assigned To");
        }

        customizeDateColumn(ti);

    }

    private void customizeDateColumn(AbstractTableInfo ti)
    {
        EHRService.get().customizeDateColumn(ti, "date");
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
            col.setLabel("Active Flags By Category");
            col.setDescription("This provides columns to summarize active flags for the animal by category, such as medical alerts, viral status, etc.");
            ds.addColumn(col);
        }

        if (ds.getColumn("Surgery") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "Surgery", "demographicsSurgery");
            col.setLabel("Surgical History");
            col.setDescription("Calculates whether this animal has ever had any surgery or a surgery flagged as major");
            ds.addColumn(col);
        }

        if (ds.getColumn("activeFlagList") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activeFlagList", "demographicsActiveFlags");
            col.setLabel("Active Flags");
            col.setDescription("This provides a columm summarizing all active flags per animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("activeTreatments") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activeTreatments", "demographicsActiveTreatments");
            col.setLabel("Active Treatments");
            col.setDescription("This provides a summary of active treatments for this animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("returnLocation") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "returnLocation", "demographicsReturnLocation");
            col.setLabel("Housing - Return Location");
            col.setDescription("This calculates the most likely location to return this animal during a transfer");
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

        if (ds.getColumn("caseHistory") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "caseHistory", "demographicsCaseHistory");
            col.setLabel("Case History");
            col.setDescription("Summarizes all cases opened in the previous 6 months");
            ds.addColumn(col);
        }

        if (ds.getColumn("problemHistory") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "problemHistory", "demographicsProblemHistory");
            col.setLabel("Clinical Problem History");
            col.setDescription("Summarizes all clinical problems for this animal over the previous 2 years");
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

        if (ds.getColumn("activeAnimalGroups") == null)
        {
            ColumnInfo col21 = getWrappedIdCol(us, ds, "activeAnimalGroups", "demographicsActiveAnimalGroups");
            col21.setLabel("Animal Groups - Active");
            col21.setDescription("Displays the animal groups to which this animal currently belongs");
            ds.addColumn(col21);
        }

        if (ds.getColumn("source") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "source", "demographicsSource");
            col.setLabel("Source");
            col.setDescription("Contains fields related to the source of the animal (ie. center vs. acquired), arrival date at the center, etc.");
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

        if (ds.getColumn("totalOffspring") == null)
        {
            ColumnInfo col15 = getWrappedIdCol(us, ds, "totalOffspring", "demographicsTotalOffspring");
            col15.setLabel("Number of Offspring");
            col15.setDescription("Shows the total offspring of each animal");
            ds.addColumn(col15);
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

        if (ds.getColumn("surgeryChecklist") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "surgeryChecklist", "surgeryChecklist");
            col.setLabel("Surgery Checklist");
            col.setDescription("Shows information to review prior to surgeries");
            ds.addColumn(col);
        }

        if (ds.getColumn("demographicsAssignmentHistory") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "assignmentHistory", "demographicsAssignmentHistory");
            col.setLabel("Assignments - Total");
            col.setDescription("Shows all projects to which the animal has ever been assigned, including active projects");
            ds.addColumn(col);
        }

        if (ds.getColumn("treatmentSummary") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "treatmentSummary", "demographicsTreatmentSummary");
            col.setLabel("Treatment Summary");
            col.setDescription("Provides columns that summarize the active treatments for each animal");
            ds.addColumn(col);
        }

        if (ds.getColumn("housingStats") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "housingStats", "demographicsHousingStats");
            col.setLabel("Housing Stats");
            col.setDescription("Provides columns that summarize the recent housing history of each animal");
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
            TableInfo realTable = getRealTableForDataSet(ti, "Problem List");
            if (realTable == null)
                return;

            SQLFragment sql = new SQLFragment("(select CAST(" + ti.getSqlDialect().getGroupConcat(new SQLFragment("pl.category"), true, true, getChr(ti) + "(10)") + "AS varchar(200)) as expr FROM " + realTable.getSelectName() + " pl WHERE pl.caseId = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND (pl.enddate IS NULL OR pl.enddate > {fn now()}))");
            ExprColumn newCol = new ExprColumn(ti, problemCategories, sql, JdbcType.VARCHAR, ti.getColumn("objectid"));
            newCol.setLabel("Active Master Problem(s)");
            ti.addColumn(newCol);

            SQLFragment sql2 = new SQLFragment("(select CAST(" + ti.getSqlDialect().getGroupConcat(new SQLFragment("pl.category"), true, true, getChr(ti) + "(10)") + "AS varchar(200)) as expr FROM " + realTable.getSelectName() + " pl WHERE pl.caseId = " + ExprColumn.STR_TABLE_ALIAS + ".objectid)");
            ExprColumn newCol2 = new ExprColumn(ti, "allProblemCategories", sql2, JdbcType.VARCHAR, ti.getColumn("objectid"));
            newCol2.setLabel("All Master Problem(s)");
            ti.addColumn(newCol2);
        }

        String isActive = "isActive";
        ColumnInfo isActiveCol = ti.getColumn(isActive);
        if (isActiveCol != null)
        {
            ti.removeColumn(isActiveCol);
        }

        SQLFragment sql = new SQLFragment("(CASE " +
                " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".lsid) IS NULL THEN " + ti.getSqlDialect().getBooleanFALSE() +
                " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".enddate <= {fn curdate()}) THEN " + ti.getSqlDialect().getBooleanFALSE() +
                " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".reviewdate IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".reviewdate > {fn curdate()}) THEN " + ti.getSqlDialect().getBooleanFALSE() +
                " ELSE " + ti.getSqlDialect().getBooleanTRUE() + " END)");
        ExprColumn newCol = new ExprColumn(ti, isActive, sql, JdbcType.BOOLEAN, ti.getColumn("lsid"), ti.getColumn("enddate"), ti.getColumn("reviewdate"));
        newCol.setLabel("Is Active?");
        ti.addColumn(newCol);

        SQLFragment sql2 = new SQLFragment("(CASE " +
                " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".lsid) IS NULL THEN " + ti.getSqlDialect().getBooleanFALSE() +
                " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NOT NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".enddate <= {fn curdate()}) THEN " + ti.getSqlDialect().getBooleanFALSE() +
                " ELSE " + ti.getSqlDialect().getBooleanTRUE() + " END)");
        ExprColumn newCol2 = new ExprColumn(ti, "isOpen", sql2, JdbcType.BOOLEAN, ti.getColumn("lsid"), ti.getColumn("enddate"), ti.getColumn("reviewdate"));
        newCol2.setLabel("Is Open?");
        newCol2.setDescription("Displays whether this case is still open, which will includes cases that have been closed for review");
        ti.addColumn(newCol2);

        //days since vet review
        String lastVetReview = "lastVetReview";
        if (ti.getColumn(lastVetReview) == null)
        {
            TableInfo obsRealTable = getRealTableForDataSet(ti, "Clinical Observations");
            if (obsRealTable != null)
            {
                SQLFragment obsSql = new SQLFragment("(SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category = ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId)", ONPRC_EHRManager.VET_REVIEW);
                ExprColumn obsCol = new ExprColumn(ti, lastVetReview, obsSql, JdbcType.TIMESTAMP, ti.getColumn("Id"));
                obsCol.setLabel("Last Vet Review");
                ti.addColumn(obsCol);

                String daysSinceLastReview = "daysSinceLastVetReview";
                SQLFragment obsSql2 = new SQLFragment("(SELECT coalesce((" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "max(t.date)") + "), 999) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category = ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId)", ONPRC_EHRManager.VET_REVIEW);
                ExprColumn obsCol2 = new ExprColumn(ti, daysSinceLastReview, obsSql2, JdbcType.INTEGER, ti.getColumn("Id"));
                obsCol2.setLabel("Days Since Last Vet Review");
                ti.addColumn(obsCol2);

                //also add days since last observations (proxy for rounds)
                String lastRoundsObs = "lastRoundsObs";
                SQLFragment roundsSql = new SQLFragment("(SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category != ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId AND " + ExprColumn.STR_TABLE_ALIAS + ".objectid = t.caseid)", ONPRC_EHRManager.VET_REVIEW);
                ExprColumn roundsCol = new ExprColumn(ti, lastRoundsObs, roundsSql, JdbcType.TIMESTAMP, ti.getColumn("Id"), ti.getColumn("objectid"));
                roundsCol.setLabel("Last Rounds Observations");
                ti.addColumn(roundsCol);

                String daysSinceLastRounds = "daysSinceLastRounds";
                SQLFragment roundsSql2 = new SQLFragment(ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "COALESCE((SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category != ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId AND " + ExprColumn.STR_TABLE_ALIAS + ".objectid = t.caseid), " + ExprColumn.STR_TABLE_ALIAS + ".date)"), ONPRC_EHRManager.VET_REVIEW);
                ExprColumn roundsCol2 = new ExprColumn(ti, daysSinceLastRounds, roundsSql2, JdbcType.INTEGER, ti.getColumn("Id"), ti.getColumn("objectid"), ti.getColumn("date"));
                roundsCol2.setLabel("Days Since Last Rounds Observations");
                ti.addColumn(roundsCol2);
            }
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
                col.setFk(new QueryForeignKey(us, null, "housingEffectiveCage", "lsid", "effectiveCage"));
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
                wrapped.setFk(new QueryForeignKey(us, null, "cage_positions", "cage", "cage"));
                ti.addColumn(wrapped);
            }
        }
    }

    private void customizeClinpathRunsTable(AbstractTableInfo ti)
    {
        if (ti.getColumn("collectedby") != null)
        {
            ti.getColumn("collectedby").setHidden(true);
        }

        if (ti.getColumn("condition") != null)
        {
            ti.getColumn("condition").setHidden(true);
        }

    }

    private void customizeTreatmentOrdersTable(AbstractTableInfo ti)
    {
        //for now, sqlserver only
        if (!ti.getSqlDialect().isSqlServer())
            return;

        String name = "treatmentTimes";
        if (ti.getColumn(name) == null)
        {
            String chr = ti.getSqlDialect().isPostgreSQL() ? "chr" : "char";
            SQLFragment sql = new SQLFragment("COALESCE(" +
                "(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("REPLICATE('0', 4 - LEN(tt.time))  + cast(tt.time as varchar(4))"), true, false, chr + "(10)") + " as _expr " +
                " FROM ehr.treatment_times tt " +
                " WHERE tt.treatmentId = " + ExprColumn.STR_TABLE_ALIAS + ".objectid)" +
                ", (SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("REPLICATE('0', 4 - LEN(ft.hourofday))  + cast(ft.hourofday as varchar(4))"), true, false, chr + "(10)") + " as _expr " +
                " FROM ehr_lookups.treatment_frequency f " +
                " JOIN ehr_lookups.treatment_frequency_times ft ON (f.meaning = ft.frequency) WHERE f.rowid = " + ExprColumn.STR_TABLE_ALIAS + ".frequency)" +
                ", 'Custom')"
            );
            ExprColumn col = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, ti.getColumn("objectid"));
            col.setLabel("Times");
            ti.addColumn(col);
        }

        ti.getColumn("meaning").setHidden(true);
        ti.getColumn("qualifier").setHidden(true);
    }

    private void customizeTreatmentFrequency(AbstractTableInfo ti)
    {
        //for now, sqlserver only
        if (!ti.getSqlDialect().isSqlServer())
            return;

        String name = "times";
        ColumnInfo existing = ti.getColumn(name);
        if (existing == null)
        {
            SQLFragment sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("REPLICATE('0', 4 - LEN(t.hourofday))  + cast(t.hourofday as varchar(4))"), true, true, "','") +
                    "FROM ehr_lookups.treatment_frequency_times t " +
                    " WHERE t.frequency = " + ExprColumn.STR_TABLE_ALIAS + ".meaning " +
                    " GROUP BY t.frequency " +
                    " )");

            ExprColumn newCol = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, ti.getColumn("meaning"));
            newCol.setLabel("Times");
            newCol.setDisplayWidth("80");
            ti.addColumn(newCol);
        }
    }

    private void customizeDemographicsTable(AbstractTableInfo ti)
    {
        ColumnInfo originCol = ti.getColumn("origin");
        if (originCol != null)
        {
            originCol.setLabel("Source");
        }

        String hxName = "mostRecentHx";
        if (ti.getColumn(hxName) == null)
        {
            TableInfo realTable = getRealTableForDataSet(ti, "Clinical Remarks");
            if (realTable == null)
            {
                _log.warn("Unable to find real table for clin remarks");
                return;
            }

            ColumnInfo idCol = ti.getColumn("Id");
            assert idCol != null;

            SQLFragment sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.hx"), true, false, getChr(ti) + "(10)") + " FROM " + realTable.getSelectName() +
                    " r WHERE r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.hx IS NOT NULL AND (r.category != ? OR r.category IS NULL) AND r.date = (SELECT max(date) as expr FROM " + realTable.getSelectName() + " r2 "
                    + " WHERE r2.participantId = r.participantId AND r2.hx is not null AND (r2.category != ? OR r2.category IS NULL)))", ONPRC_EHRManager.REPLACED_SOAP, ONPRC_EHRManager.REPLACED_SOAP
            );
            ExprColumn latestHx = new ExprColumn(ti, hxName, sql, JdbcType.VARCHAR, idCol);
            latestHx.setLabel("Most Recent Hx");
            latestHx.setDisplayWidth("200");
            ti.addColumn(latestHx);
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
                wrapped.setFk(new QueryForeignKey(us, null, "matingOutcome", "lsid", "confirmations"));

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
                wrapped.setFk(new QueryForeignKey(us, null, "pregnancyOutcome", "lsid", "confirmations"));

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
                cond.setFk(new QueryForeignKey(us, null, "birth_condition", "value", "value"));
            }
        }

        ColumnInfo dam = ti.getColumn("dam");
        if (dam != null)
        {
            dam.setLabel("Observed Dam");
        }

        ColumnInfo sire = ti.getColumn("sire");
        if (sire != null)
        {
            sire.setLabel("Observed Sire");
        }
    }

    private void appendLatestHxCol(AbstractTableInfo ti)
    {
        String hxName = "latestHx";
        if (ti.getColumn(hxName) != null)
            return;

        TableInfo realTable = getRealTableForDataSet(ti, "Clinical Remarks");
        if (realTable == null)
        {
            _log.warn("Unable to find real table for clin remarks");
            return;
        }

        String prefix = ti.getSqlDialect().isSqlServer() ? " TOP 1 " : "";
        String suffix = ti.getSqlDialect().isSqlServer() ? "" : " LIMIT 1 ";

        //uses caseId
        ColumnInfo objectId = ti.getColumn("objectid");
        String chr = ti.getSqlDialect().isPostgreSQL() ? "chr" : "char";
        SQLFragment latestHxSql = new SQLFragment("(SELECT " + prefix + " (" + "r.hx" + ") as _expr FROM " + realTable.getSelectName() +
                " r WHERE "
                + " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.hx IS NOT NULL AND (r.category != ? OR r.category IS NULL) ORDER BY r.date desc " + suffix + ")", ONPRC_EHRManager.REPLACED_SOAP);

        ExprColumn latestHx = new ExprColumn(ti, hxName, latestHxSql, JdbcType.VARCHAR, objectId, ti.getColumn("Id"));
        latestHx.setLabel("Latest Hx For Case");
        latestHx.setDisplayWidth("200");
        ti.addColumn(latestHx);

        //does not use caseId
        SQLFragment recentp2Sql = new SQLFragment("(SELECT " + prefix + " (" + "r.p2" + ") as _expr FROM " + realTable.getSelectName() +
                " r WHERE "
                //+ " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.p2 IS NOT NULL AND (r.category != ? OR r.category IS NULL) ORDER BY r.date desc " + suffix + ")", ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn recentP2 = new ExprColumn(ti, "mostRecentP2", recentp2Sql, JdbcType.VARCHAR, objectId);
        recentP2.setLabel("Most Recent P2");
        recentP2.setDescription("This column will display the most recent P2 that has been entered for the animal.");
        recentP2.setDisplayWidth("200");
        ti.addColumn(recentP2);

        //uses caseId.  this is a proxy for rounds
        SQLFragment recentRemarkSql = new SQLFragment("(SELECT " + prefix + " (" + "r.remark" + ") as _expr FROM " + realTable.getSelectName() +
                " r WHERE "
                + " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.remark IS NOT NULL AND (r.category != ? OR r.category IS NULL) ORDER BY r.date desc " + suffix + ")", ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn recentRemark = new ExprColumn(ti, "mostRecentRemark", recentRemarkSql, JdbcType.VARCHAR, objectId);
        recentRemark.setLabel("Most Recent Remark For Case");
        recentRemark.setDescription("This column will display the most recent remark that has been entered for the animal.");
        recentRemark.setDisplayWidth("200");
        ti.addColumn(recentRemark);

        //does not use caseId
        SQLFragment p2Sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'P2: '", "r.p2")), true, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE "
                //+ " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.p2 IS NOT NULL AND CAST(r.date AS date) = CAST(? as date) AND (r.category != ? OR r.category IS NULL))", new Date(), ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn todaysP2 = new ExprColumn(ti, "todaysP2", p2Sql, JdbcType.VARCHAR, objectId);
        todaysP2.setLabel("P2s Entered Today");
        todaysP2.setDisplayWidth("200");
        ti.addColumn(todaysP2);

        Calendar yesterday = Calendar.getInstance();
        yesterday.setTime(new Date());
        yesterday.add(Calendar.DATE, -1);

        //does not use caseId
        SQLFragment p2Sql2 = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'P2: '", "r.p2")), true, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE "
                //+ " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.p2 IS NOT NULL AND CAST(r.date AS date) = CAST(? as date) AND (r.category != ? OR r.category IS NULL))", yesterday.getTime(), ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn yesterdaysP2 = new ExprColumn(ti, "yesterdaysP2", p2Sql2, JdbcType.VARCHAR, objectId);
        yesterdaysP2.setLabel("P2s Entered Yesterday");
        yesterdaysP2.setDisplayWidth("200");
        ti.addColumn(yesterdaysP2);

        //uses caseId as a proxy for rounds
        SQLFragment rmSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.remark"), true, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE "
                + " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.remark IS NOT NULL AND CAST(r.date AS date) = CAST(? as date) AND (r.category != ? OR r.category IS NULL))", new Date(), ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn todaysRemarks = new ExprColumn(ti, "todaysRemarks", rmSql, JdbcType.VARCHAR, objectId);
        todaysRemarks.setLabel("Remarks Entered Today");
        todaysRemarks.setDescription("This shows any remarks entered today for this case");
        todaysRemarks.setDisplayWidth("200");
        ti.addColumn(todaysRemarks);

//        SQLFragment rmSql2 = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.remark"), true, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
//                " r WHERE "
//                + " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
//                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.remark IS NOT NULL AND r.date = " + ExprColumn.STR_TABLE_ALIAS + ".date AND (r.category != ? OR r.category IS NULL))", ONPRC_EHRManager.REPLACED_SOAP);
//        ExprColumn remarksOnOpenDate = new ExprColumn(ti, "remarksOnOpenDate", rmSql2, JdbcType.VARCHAR, objectId);
//        remarksOnOpenDate.setLabel("Remarks Entered On Open Date");
//        remarksOnOpenDate.setDisplayWidth("200");
//        ti.addColumn(remarksOnOpenDate);

        //TODO: convert to a real column
        SQLFragment assesmentSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.a"), true, false, chr + "(10)") + " FROM " + realTable.getSelectName() +
                " r WHERE "
                + " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.a IS NOT NULL AND r.date = " + ExprColumn.STR_TABLE_ALIAS + ".date AND (r.category != ? OR r.category IS NULL))", ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn assessmentOnOpenDate = new ExprColumn(ti, "assessmentOnOpenDate", assesmentSql, JdbcType.VARCHAR, objectId);
        assessmentOnOpenDate.setLabel("Assessment Entered On Open Date");
        assessmentOnOpenDate.setDisplayWidth("200");
        ti.addColumn(assessmentOnOpenDate);

        //based on caseid
        if (ti.getColumn("mostRecentObservations") == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            ColumnInfo col17 = getWrappedCol(us, ti, "mostRecentObservations", "mostRecentObservations", "objectid", "caseid");
            col17.setLabel("Most Recent Observations");
            col17.setDescription("Displays the most recent set of observations associated with this case");
            col17.setDisplayWidth("150");
            ti.addColumn(col17);
        }
    }

    private void appendSurgeryCol(AbstractTableInfo ti)
    {
        String name = "proceduresPerformed";
        if (ti.getColumn(name) != null)
            return;

        TableInfo realTable = getRealTableForDataSet(ti, "Clinical Encounters");
        if (realTable == null)
        {
            _log.warn("Unable to find real table for clin encounters");
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
        procedureCol.setLabel("Procedures Performed On Open Date");
        procedureCol.setDisplayWidth("300");
        ti.addColumn(procedureCol);
    }

    private void customizeTasks(AbstractTableInfo ti)
    {
        DetailsURL detailsURL = DetailsURL.fromString("/ehr/dataEntryFormDetails.view?formType=${formtype}&taskid=${taskid}");
        ti.setDetailsURL(detailsURL);

        ColumnInfo titleCol = ti.getColumn("title");
        if (titleCol != null)
        {
            titleCol.setURL(detailsURL);
        }

        ColumnInfo rowIdCol = ti.getColumn("rowid");
        if (rowIdCol != null)
        {
            rowIdCol.setURL(detailsURL);
        }

        ColumnInfo updateCol = ti.getColumn("updateTitle");
        if (updateCol == null)
        {
            updateCol = new WrappedColumn(ti.getColumn("title"), "updateTitle");
            ti.addColumn(updateCol);
        }

        if (ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), EHRDataEntryPermission.class))
            updateCol.setURL(DetailsURL.fromString("/ehr/dataEntryForm.view?formType=${formtype}&taskid=${taskid}"));
        else
            updateCol.setURL(detailsURL);

        updateCol.setLabel("Title");
        updateCol.setHidden(true);
        updateCol.setDisplayWidth("150");
    }

    private void customizeRequests(AbstractTableInfo ti)
    {
        DetailsURL detailsURL = DetailsURL.fromString("/ehr/dataEntryFormDetails.view?formType=${formtype}&requestId=${requestId}");
        ti.setDetailsURL(detailsURL);

        ColumnInfo titleCol = ti.getColumn("title");
        if (titleCol != null)
        {
            titleCol.setURL(detailsURL);
        }

        ColumnInfo rowIdCol = ti.getColumn("rowid");
        if (rowIdCol != null)
        {
            rowIdCol.setURL(detailsURL);
        }

//        ColumnInfo updateCol = ti.getColumn("updateTitle");
//        if (updateCol == null)
//        {
//            updateCol = new WrappedColumn(ti.getColumn("title"), "updateTitle");
//            ti.addColumn(updateCol);
//        }
//
//        if (ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), EHRDataEntryPermission.class))
//            updateCol.setURL(DetailsURL.fromString("/ehr/dataEntryForm.view?formType=${formtype}&taskid=${taskid}"));
//        else
//            updateCol.setURL(detailsURL);
//
//        updateCol.setLabel("Title");
//        updateCol.setHidden(true);
//        updateCol.setDisplayWidth("150");
    }

    private void customizeProtocol(AbstractTableInfo ti)
    {
        ti.getColumn("inves").setHidden(true);
        ti.getColumn("maxAnimals").setHidden(true);
        ti.getColumn("title").setScale(80);
        ti.getColumn("investigatorId").setHidden(false);
        ti.getColumn("approve").setLabel("Initial Approval Date");
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
                col2.setFk(new QueryForeignKey(us, null, "protocolTotalProjects", "protocol", "protocol"));
            }
        }

        if (ti.getSqlDialect().isSqlServer())
        {
            String annualReviewDate = "annualReviewDate";
            if (ti.getColumn(annualReviewDate) == null)
            {
                //NOTE: day used instead of year to be PG / LK12.3 compatible
                String sqlString = "(CASE " +
                        //if the protocol is already ended, or began more than 3 years ago, assume it is ended
                        " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NOT NULL THEN NULL " +
                        " WHEN (" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", ExprColumn.STR_TABLE_ALIAS + ".approve") + " >= 1095) THEN NULL" +
                        //otherwise, show the next annual renewal date
                        " ELSE {fn timestampadd(SQL_TSI_DAY, -1, {fn timestampadd(SQL_TSI_YEAR, {fn ceiling((" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", ExprColumn.STR_TABLE_ALIAS + ".approve") + ") / 365.0)}, " + ExprColumn.STR_TABLE_ALIAS + ".approve)})}" +
                        " END)";
                SQLFragment sql = new SQLFragment(sqlString);
                ExprColumn annualReviewDateCol = new ExprColumn(ti, annualReviewDate, sql, JdbcType.DATE, ti.getColumn("approve"));
                annualReviewDateCol.setLabel("Annual Review Date");
                ti.addColumn(annualReviewDateCol);

                String daysUntilAnnual = "daysUntilAnnualReview";
                SQLFragment sql2 = new SQLFragment("(CASE " +
                        // see above for logic behind this
                        " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NOT NULL THEN NULL " +
                        " WHEN (" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", ExprColumn.STR_TABLE_ALIAS + ".approve") + " >= 1095) THEN NULL" +
                        //NOTE: these expire 1 day prior to a full year, so use 364 instead of 365
                        " ELSE 364 - ((" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", ExprColumn.STR_TABLE_ALIAS + ".approve") + ") % 365)" +
                        " END)");
                ExprColumn daysUntilAnnualCol = new ExprColumn(ti, daysUntilAnnual, sql2, JdbcType.INTEGER, ti.getColumn("approve"));
                daysUntilAnnualCol.setLabel("Days Until Annual Review");
                daysUntilAnnualCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
                ti.addColumn(daysUntilAnnualCol);
            }

            String renewalDate = "renewalDate";
            if (ti.getColumn(renewalDate) == null)
            {
                //NOTE: while SQL_TSI_YEAR is not PG compatible, use it to deal w/ leap years.
                String sqlString = "(CASE WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NULL THEN {fn timestampadd(SQL_TSI_DAY, -1, {fn timestampadd(SQL_TSI_YEAR, 3, " + ExprColumn.STR_TABLE_ALIAS + ".approve)})} ELSE null END)";
                SQLFragment sql = new SQLFragment(sqlString);
                ExprColumn renewalCol = new ExprColumn(ti, renewalDate, sql, JdbcType.DATE, ti.getColumn("approve"));
                renewalCol.setLabel("3-Yr Renewal Date");
                ti.addColumn(renewalCol);

                String daysUntil = "daysUntilRenewal";
                SQLFragment sql2 = new SQLFragment("(CASE " +
                        " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NULL " +
                        " THEN (" + ti.getSqlDialect().getDateDiff(Calendar.DATE, sqlString, "{fn curdate()}") + ") - 1" +
                        " ELSE NULL END)");
                ExprColumn daysUntilCol = new ExprColumn(ti, daysUntil, sql2, JdbcType.INTEGER, ti.getColumn("approve"));
                daysUntilCol.setLabel("Days Until 3-Yr Renewal");
                daysUntilCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
                ti.addColumn(daysUntilCol);
            }
        }
    }

    private void customizeProjects(AbstractTableInfo ti)
    {
        ti.setTitleColumn("displayName");

        ti.getColumn("inves").setHidden(true);
        ti.getColumn("inves2").setHidden(true);
        ti.getColumn("reqname").setHidden(true);
        ti.getColumn("research").setHidden(true);
        ti.getColumn("avail").setHidden(true);
        ti.getColumn("contact_emails").setHidden(true);

        ti.getColumn("project").setLabel("Project Id");
        ti.getColumn("project").setHidden(true);

        ColumnInfo invest = ti.getColumn("investigatorId");
        invest.setHidden(false);
        UserSchema us = getEHRUserSchema(ti, "onprc_ehr");
        if (us != null)
            invest.setFk(new QueryForeignKey(us, null, "investigators", "rowid", "lastname"));
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
            col.setFk(new QueryForeignKey(us, null, "roomsAssignment", "room", "room"));
            ti.addColumn(col);
        }
    }

    private ColumnInfo getWrappedIdCol(UserSchema us, AbstractTableInfo ds, String name, String queryName)
    {
        return getWrappedCol(us, ds, name, queryName, "Id", "Id");
    }

    private ColumnInfo getWrappedCol(UserSchema us, AbstractTableInfo ds, String name, String queryName, String colName, String targetCol)
    {

        WrappedColumn col = new WrappedColumn(ds.getColumn(colName), name);
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new QueryForeignKey(us, null, queryName, targetCol, targetCol));

        return col;
    }

    private UserSchema getStudyUserSchema(AbstractTableInfo ds)
    {
        return getUserSchema(ds, "study");
    }

    public UserSchema getEHRUserSchema(AbstractTableInfo ds, String name)
    {
        Container ehrContainer = EHRService.get().getEHRStudyContainer(ds.getUserSchema().getContainer());
        if (ehrContainer == null)
            return null;

        return getUserSchema(ds, name, ehrContainer);
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
                            String runId = (String)ctx.get(new FieldKey(getBoundColumn().getFieldKey().getParent(), "runIdPLT"));
                            String id = (String)ctx.get(new FieldKey(getBoundColumn().getFieldKey().getParent(), "Id"));
                            out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" onclick=\"EHR.panel.LabworkSummaryPanel.showRunSummary(" + PageFlowUtil.jsString(runId) + ", '" + id + "', this);\">" + getFormattedValue(ctx) + "</a></span>");
                        }

                        @Override
                        public void addQueryFieldKeys(Set<FieldKey> keys)
                        {
                            super.addQueryFieldKeys(keys);
                            keys.add(new FieldKey(getBoundColumn().getFieldKey().getParent(), "runIdPLT"));
                            keys.add(new FieldKey(getBoundColumn().getFieldKey().getParent(), "Id"));
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
                            String runId = (String)ctx.get(new FieldKey(getBoundColumn().getFieldKey().getParent(), "runIdHCT"));
                            String id = (String)ctx.get(new FieldKey(getBoundColumn().getFieldKey().getParent(), "Id"));
                            out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" onclick=\"EHR.panel.LabworkSummaryPanel.showRunSummary(" + PageFlowUtil.jsString(runId) + ", '" + id + "', this);\">" + getFormattedValue(ctx) + "</a></span>");
                        }

                        @Override
                        public void addQueryFieldKeys(Set<FieldKey> keys)
                        {
                            super.addQueryFieldKeys(keys);
                            keys.add(new FieldKey(getBoundColumn().getFieldKey().getParent(), "runIdHCT"));
                            keys.add(new FieldKey(getBoundColumn().getFieldKey().getParent(), "Id"));
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
                col.setFk(new QueryForeignKey(us, null, "availableCages", "location", "location"));
                table.addColumn(col);
            }
        }
    }

    private TableInfo getRealTableForDataSet(AbstractTableInfo ti, String label)
    {
        Container ehrContainer = EHRService.get().getEHRStudyContainer(ti.getUserSchema().getContainer());
        if (ehrContainer == null)
            return null;

        DataSet ds;
        String key = ehrContainer.getId() + "||" + label;
        if (_cachedDatasets.containsKey(key))
        {
            ds = _cachedDatasets.get(key);
        }
        else
        {
            Study s = StudyService.get().getStudy(ehrContainer);
            if (s == null)
                return null;

            ds = s.getDataSetByLabel(label);
            if (ds == null)
            {
                _log.error("A dataset was requested that does not exist: " + label);
            }

            _cachedDatasets.put(key, null);
        }

        if (ds != null)
        {
            String tableName = ds.getDomain().getStorageTableName();
            DbSchema dbSchema = DbSchema.get("studydataset");
            return dbSchema.getTable(tableName);
        }

        return null;
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

                        out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" onclick=\"EHR.window.CaseHistoryWindow.showCaseHistory('" + objectid + "', '" + id + "', this);\">[Show Case Hx]</a></span>");
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

    private ColumnInfo getPkCol(TableInfo ti)
    {
        List<ColumnInfo> pks = ti.getPkColumns();
        return (pks.size() != 1) ? null : pks.get(0);
    }

    private void appendIsAssignedAtTimeCol(final UserSchema us, AbstractTableInfo ds, final String dateColName)
    {
        Container ehrContainer = EHRService.get().getEHRStudyContainer(ds.getUserSchema().getContainer());
        if (ehrContainer == null)
            return;

        String name = "isAssignedAtTime";
        if (ds.getColumn(name) != null)
            return;

        if (ds.getColumn("Id") == null || ds.getColumn("date") == null || ds.getColumn("project") == null)
            return;

        if (matches(ds, "study", "assignment"))
            return;

        TableInfo realTable = getRealTableForDataSet(ds, "Assignment");
        if (realTable == null)
            return;

        String idColSql = ds.getColumn("Id").getValueSql(ExprColumn.STR_TABLE_ALIAS).toString();
        String dateColSql = ds.getColumn("date").getValueSql(ExprColumn.STR_TABLE_ALIAS).toString();
        SQLFragment sql = new SQLFragment("CASE " +
            " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".project IS NULL THEN NULL " +
            " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".project NOT IN (select a.project FROM " + realTable.getSelectName() + " a WHERE a.participantid = " + idColSql + " AND CAST(a.date AS DATE) <= CAST(" + dateColSql + " as DATE) AND (a.enddate IS NULL OR a.enddate >= " + dateColSql + ")) THEN 'Y'" +
            " ELSE 'N' END");
        ExprColumn newCol = new ExprColumn(ds, name, sql, JdbcType.VARCHAR, ds.getColumn("Id"), ds.getColumn("date"), ds.getColumn("project"));
        newCol.setLabel("Is Assigned At Time?");
        newCol.setDescription("Displays whether the animal is assigned to the selected project on the date of each record");
        ds.addColumn(newCol);
    }

    private void appendAssignmentAtTimeCol(final UserSchema us, AbstractTableInfo ds, final String dateColName)
    {
        String name = "assignmentAtTime";
        if (ds.getColumn(name) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "study", "assignment"))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();

        WrappedColumn col = new WrappedColumn(pkCol, name);
        col.setLabel("Assignments At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_assignmentsAtTime";
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.project.displayName, chr(10)) as projectsAtTime,\n" +
                        "group_concat(DISTINCT h.project.protocol.displayName, chr(10)) as protocolsAtTime,\n" +
                        "group_concat(DISTINCT h.project.investigatorId.lastName, chr(10)) as investigatorsAtTime,\n" +
                        "group_concat(DISTINCT h.project.name, chr(10)) as projectNumbersAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN study.assignment h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced) AND h.qcstate.publicdata = true)\n" +
                        "group by sd." + pkCol.getSelectName());
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

                ti.getColumn(pkCol.getSelectName()).setHidden(true);
                ti.getColumn(pkCol.getSelectName()).setKeyField(true);

                ti.getColumn("projectsAtTime").setLabel("Center Projects At Time");
                ti.getColumn("protocolsAtTime").setLabel("IACUC Protocols At Time");
                ti.getColumn("investigatorsAtTime").setLabel("Investigators At Time");

                ti.getColumn("projectNumbersAtTime").setLabel("Project Numbers At Time");
                ti.getColumn("projectNumbersAtTime").setHidden(true);

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendFlagsAtTimeCol(final UserSchema us, AbstractTableInfo ds, final String dateColName)
    {
        String name = "flagsAtTime";
        if (ds.getColumn(name) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "study", "flags"))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();

        WrappedColumn col = new WrappedColumn(pkCol, name);
        col.setLabel("Flags At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_flagsAtTime";
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.value, chr(10)) as flagsAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN study.flags h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced) AND h.qcstate.publicdata = true)\n" +
                        "group by sd." + pkCol.getSelectName());
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

                ti.getColumn(pkCol.getSelectName()).setHidden(true);
                ti.getColumn(pkCol.getSelectName()).setKeyField(true);

                ti.getColumn("flagsAtTime").setLabel("Flags At Time");

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendProblemsAtTimeCol(final UserSchema us, AbstractTableInfo ds, final String dateColName)
    {
        final String colName = "problemsAtTime";
        if (ds.getColumn(colName) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "study", "problem"))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();

        WrappedColumn col = new WrappedColumn(pkCol, colName);
        col.setLabel("Problems At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_" + colName;
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.category, chr(10)) as problemsAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN study.\"Problem List\" h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced) AND h.qcstate.publicdata = true)\n" +
                        "group by sd." + pkCol.getSelectName());
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

                ti.getColumn(pkCol.getSelectName()).setHidden(true);
                ti.getColumn(pkCol.getSelectName()).setKeyField(true);

                ti.getColumn("problemsAtTime").setLabel("Problems At Time");

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendGroupsAtTimeCol(final UserSchema us, AbstractTableInfo ds, final String dateColName)
    {
        final String colName = "groupsAtTime";
        if (ds.getColumn(colName) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "ehr", "animal_group_members"))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();

        WrappedColumn col = new WrappedColumn(pkCol, colName);
        col.setLabel("Groups At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_" + colName;
                QueryDefinition qd = QueryService.get().createQueryDef(us.getUser(), us.getContainer(), us, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.groupId.name, chr(10)) as groupsAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN ehr.animal_group_members h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced))\n" +
                        "group by sd." + pkCol.getSelectName());
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

                ti.getColumn(pkCol.getSelectName()).setHidden(true);
                ti.getColumn(pkCol.getSelectName()).setKeyField(true);

                ti.getColumn("groupsAtTime").setLabel("Groups At Time");

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void customizeCageObservations(AbstractTableInfo ti)
    {
        ti.getColumn("userid").setHidden(true);
        ti.getColumn("feces").setHidden(true);
        ti.getColumn("no_observations").setHidden(true);
    }

    private void customizeAnimalGroups(AbstractTableInfo ti)
    {
        if (ti.getColumn("majorityLocation") == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            if (us != null)
            {
                ColumnInfo rowidCol = ti.getColumn("rowid");
                ColumnInfo col = ti.addColumn(new WrappedColumn(rowidCol, "majorityLocation"));
                col.setLabel("Majority Location");
                col.setUserEditable(false);
                col.setIsUnselectable(true);
                col.setFk(new QueryForeignKey(us, null, "animalGroupMajorityLocation", "rowid", "room"));
            }
        }
    }

    private boolean hasTable (AbstractTableInfo ti, String schemaName, String queryName)
    {
        UserSchema us = getUserSchema(ti, schemaName);
        if (us == null)
            return false;

        return us.getTableNames().contains(queryName);
    }
}
