/*
 * Copyright (c) 2012-2017 LabKey Corporation
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

import org.apache.commons.beanutils.ConversionException;
import org.apache.log4j.Logger;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.ConvertHelper;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.ehr.EHRQCState;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.exp.api.StorageProvisioner;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.gwt.client.FacetingBehaviorType;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.module.ModuleProperty;
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
import org.labkey.api.settings.LookAndFeelProperties;
import org.labkey.api.study.Dataset;
import org.labkey.api.study.DatasetTable;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyService;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ehr.ONPRC_EHRManager;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Set;

/**
 * User: bimber
 * Date: 12/7/12
 * Time: 2:22 PM
 */
public class ONPRC_EHRCustomizer extends AbstractTableCustomizer
{
    private static final Logger _log = Logger.getLogger(ONPRC_EHRCustomizer.class);

    public ONPRC_EHRCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        if (table instanceof AbstractTableInfo)
        {
            customizeColumns((AbstractTableInfo) table);

            if (table.getColumn("date") != null)
            {
                addCalculatedCols((AbstractTableInfo) table, "date");
            }

            if (matches(table, "study", "Animal"))
            {
                customizeAnimalTable((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "animal_groups"))
            {
                customizeAnimalGroups((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "cage_observations"))
            {
                customizeCageObservations((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "protocolProcedures"))
            {
                customizeProtocolProcedures((AbstractTableInfo) table);
            }
            else if (matches(table, "onprc_ehr", "housing_transfer_requests"))
            {
                customizeHousingRequests((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Demographics"))
            {
                customizeDemographicsTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "treatment_order"))
            {
                customizeTreatmentOrdersTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Clinpath Runs") || matches(table, "study", "clinpathRuns"))
            {
                customizeClinpathRunsTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Birth"))
            {
                customizeBirthTable((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Deaths"))
            {
                customizeDeathTable((AbstractTableInfo) table);
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
            else if (matches(table, "study", "Clinical Observations") || matches(table, "study", "clinical_observations"))
            {
                customizeClinicalObservations((AbstractTableInfo) table);
            }
            else if (matches(table, "study", "Clinical Encounters") || matches(table, "study", "encounters"))
            {
                customizeEncounters((AbstractTableInfo) table);
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
                customizeTreatmentFrequency((AbstractTableInfo) table);
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

            //check for datasets
            if (table instanceof DatasetTable)
            {
                customizeDataset((AbstractTableInfo)table);
            }
        }

        if (matches(table, "study", "surgeryChecklist"))
        {
            customizeSurgChecklistTable(table);
        }
    }

    private Date getDefaultVetReviewDate(Container c)
    {
        ModuleProperty mp = ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class).getModuleProperties().get(ONPRC_EHRManager.VetReviewStartDateProp);
        String dateValue = mp.getEffectiveValue(c);
        Date defaultDate = null;
        if (dateValue != null)
        {
            try
            {
                defaultDate = ConvertHelper.convert(dateValue, Date.class);
            }
            catch (ConversionException e)
            {
                _log.error("Invalid date for ModuleProperty: " + dateValue);
            }
        }

        if (defaultDate == null)
        {
            Calendar cal = Calendar.getInstance();
            cal.set(1900, 1, 1);
            defaultDate = cal.getTime();
        }

        return defaultDate;
    }

    private void customizeDataset(AbstractTableInfo ti)
    {
        String name = "enteredSinceVetReview";
        if (ti.getColumn(name) == null)
        {
            TableInfo obsRealTable = getRealTableForDataset(ti, "Clinical Observations");
            if (obsRealTable != null)
            {
                //clinical remarks entered since last vet review is a proxy for whether it needs to be reviewed again
                SQLFragment sql = new SQLFragment("(CASE WHEN " + ExprColumn.STR_TABLE_ALIAS + ".date > COALESCE((SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category = ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId), ?) THEN " + ti.getSqlDialect().getBooleanTRUE() + " ELSE " + ti.getSqlDialect().getBooleanFALSE() + " END)", ONPRC_EHRManager.VET_REVIEW, getDefaultVetReviewDate(ti.getUserSchema().getContainer()));
                ExprColumn remarkCol = new ExprColumn(ti, name, sql, JdbcType.BOOLEAN, ti.getColumn("Id"), ti.getColumn("date"));
                remarkCol.setLabel("Entered Since Last Vet Review?");
                ti.addColumn(remarkCol);
            }
        }
    }

    private boolean isDemographicsTable(TableInfo ti)
    {
        return ti.getName().equalsIgnoreCase("demographics") && ti.getPublicSchemaName().equalsIgnoreCase("study");
    }

    private void addCalculatedCols(AbstractTableInfo ds, String dateColName)
    {
        UserSchema ehrSchema = getEHRUserSchema(ds, "study");
        if (ehrSchema != null && !isDemographicsTable(ds))
        {
            appendAssignmentAtTimeCol(ehrSchema, ds, dateColName);
            appendGroupsAtTimeCol(ehrSchema, ds, dateColName);
            appendProblemsAtTimeCol(ehrSchema, ds, dateColName);
            appendFlagsAtTimeCol(ehrSchema, ds, dateColName);
            appendIsAssignedAtTimeCol(ehrSchema, ds, dateColName);
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
                    if (project.getJdbcType().getJavaClass().equals(Integer.class))
                        project.setFk(new QueryForeignKey(us, us.getContainer(), "project", "project", "displayName"));
                    else if (project.getJdbcType().getJavaClass().equals(String.class))
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
            account.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
            if (ti instanceof DatasetTable)
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

                if (!ti.getName().equalsIgnoreCase("investigators") && investigator.getJdbcType().getJavaClass().equals(Integer.class))
                {
                    UserSchema us = getEHRUserSchema(ti, "onprc_ehr");
                    if (us != null){
                        investigator.setFk(new QueryForeignKey(us, us.getContainer(), "investigators", "rowid", "lastname"));
                    }
                }
                investigator.setLabel("Investigator");
            }
        }

        ColumnInfo financialAnalyst = ti.getColumn("financialanalyst");
        if (financialAnalyst != null)
        {
            UserSchema us = getUserSchema(ti, "onprc_billing_public");
            if (us != null){
                financialAnalyst.setFk(new QueryForeignKey(us, null, "fiscalAuthorities", "rowid", "lastName"));
            }
            financialAnalyst.setLabel("Financial Authority");
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

        addNaturalSort(ti, "cage");
        addNaturalSort(ti, "cage1");
        addNaturalSort(ti, "cage2");

        addNaturalSort(ti, "room");
        addNaturalSort(ti, "room1");
        addNaturalSort(ti, "room2");
    }

    private void addNaturalSort(AbstractTableInfo ti, String columnName)
    {
        ColumnInfo column = ti.getColumn(columnName);
        if (column != null)
        {
            LDKService.get().applyNaturalSort(ti, columnName);
        }
    }

    private void customizeDateColumn(AbstractTableInfo ti)
    {
        EHRService.get().customizeDateColumn(ti, "date");
    }

    private void customizeEncounters(AbstractTableInfo ti)
    {
        String name = "afterHours";
        if (ti.getColumn(name) == null && ti.getColumn("date") != null && ti.getColumn("enddate") != null)
        {
            SQLFragment sql = new SQLFragment("CASE " +
                    //sat/sun are overtime
                    //"WHEN " + ti.getSqlDialect().getDatePart(Calendar.DAY_OF_WEEK, ExprColumn.STR_TABLE_ALIAS + ".date") + " IN (1, 7) THEN 'Y' " +
                    "WHEN {fn dayofweek(" + ExprColumn.STR_TABLE_ALIAS + ".date)}" + " IN (1, 7) THEN 'Y' " +
                    //otherwise base off enddate
                    //any time after 1600 is overtime
                    "WHEN {fn hour(" + ExprColumn.STR_TABLE_ALIAS + ".date)}" + " >= 16 THEN 'Y' " +
                    "WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NULL THEN NULL " +
                    "WHEN {fn hour(" + ExprColumn.STR_TABLE_ALIAS + ".enddate)}" + " >= 16 THEN 'Y' " +
                    "ELSE null END"
            );

            ExprColumn newCol = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, ti.getColumn("date"), ti.getColumn("enddate"));
            newCol.setLabel("Is After Hours?");
            newCol.setDescription("This will flag any record where the date is on a weekend, or if the enddate is after 1600.  If the enddate is blank, records during the week will not get tagged as after-hours.");
            newCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
            ti.addColumn(newCol);
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

//         Created: 1-3-2017  R.Blasa
        if (ds.getColumn("activeTreatmentsGiven") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activeTreatmentsGiven", "demographicsTreatmentsGiven");
            col.setLabel("Active Treatments Given");
            col.setDescription("This provides a summary of active treatments Given for this animal");
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

        if (ds.getColumn("assignedVet") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "assignedVet", "demographicsAssignedVet");
            col.setLabel("Assigned Vet");
            col.setDescription("Calculates the assigned veterinarian, based on assignment and housing.");
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
            col2.setLabel("Active Notes By Category");
            //col.setDescription("");
            ds.addColumn(col2);
        }

        if (ds.getColumn("activeNoteList") == null)
        {
            ColumnInfo col = getWrappedIdCol(us, ds, "activeNoteList", "demographicsActiveNotes");
            col.setLabel("Active Notes");
            col.setDescription("This provides a columm summarizing all active DCM notes per animal");
            ds.addColumn(col);
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

        if (ds.getColumn("mostRecentBCS") == null)
        {
            ColumnInfo col17 = getWrappedIdCol(us, ds, "mostRecentBCS", "demographicsMostRecentBCS");
            col17.setLabel("Body Condition Score");
            col17.setDescription("Calculates the most recent BCS for each animal");
            ds.addColumn(col17);
        }

        if (ds.getColumn("mostRecentAlopeciaScore") == null)
        {
            ColumnInfo col17 = getWrappedIdCol(us, ds, "mostRecentAlopeciaScore", "demographicsMostRecentAlopecia");
            col17.setLabel("Alopecia Score");
            col17.setDescription("Calculates the most recent alopecia score for each animal");
            ds.addColumn(col17);
        }

        if (ds.getColumn("clinicalActions") == null)
        {
            ColumnInfo col17 = new AliasedColumn("clinicalActions", ds.getColumn("Id"));
            col17.setLabel("Clinical Actions");
            col17.setHidden(true);
            col17.setDescription("This column displays a menu with direct access to manage treatments, cases, etc");
            col17.setDisplayColumnFactory(new DisplayColumnFactory()
            {
                @Override
                public DisplayColumn createRenderer(ColumnInfo colInfo)
                {
                    return new ClinicalActionsDisplayColumn(colInfo);
                }
            });
            ds.addColumn(col17);
        }

        if (ds.getColumn("historicAnimalGroups") == null)
        {
            ColumnInfo col22 = getWrappedIdCol(us, ds, "historicAnimalGroups", "demographicsAnimalGroups");
            col22.setLabel("Animal Groups - Historic");
            col22.setDescription("Displays all animal groups to which this animal has ever belonged");
            ds.addColumn(col22);
        }

        if (ds.getColumn("animalGroupsPivoted") == null)
        {
            ColumnInfo agPivotCol = getWrappedIdCol(us, ds, "animalGroupsPivoted", "animalGroupsPivoted");
            agPivotCol.setLabel("Active Group Summary");
            agPivotCol.setHidden(true);
            agPivotCol.setDescription("Displays the active groups for each animal");
            ds.addColumn(agPivotCol);
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
            TableInfo realTable = getRealTableForDataset(ti, "Problem List");
            if (realTable == null)
                return;

            SQLFragment sql = new SQLFragment("(select CAST(" + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("pl.category", "CASE WHEN pl.subcategory IS NULL THEN '' ELSE (" + ti.getSqlDialect().concatenate("': '", "pl.subcategory") + ") END")), true, true, getChr(ti) + "(10)").getSqlCharSequence() + "AS varchar(200)) as expr FROM " + realTable.getSelectName() + " pl WHERE pl.caseId = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND (pl.enddate IS NULL OR pl.enddate > {fn now()}))");
            ExprColumn newCol = new ExprColumn(ti, problemCategories, sql, JdbcType.VARCHAR, ti.getColumn("objectid"));
            newCol.setLabel("Active Master Problem(s)");
            ti.addColumn(newCol);

            SQLFragment sql2 = new SQLFragment("(select CAST(" + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("pl.category", "CASE WHEN pl.subcategory IS NULL THEN '' ELSE (" + ti.getSqlDialect().concatenate("': '", "pl.subcategory") + ") END")), true, true, getChr(ti) + "(10)").getSqlCharSequence() + "AS varchar(200)) as expr FROM " + realTable.getSelectName() + " pl WHERE pl.caseId = " + ExprColumn.STR_TABLE_ALIAS + ".objectid)");
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
            TableInfo obsRealTable = getRealTableForDataset(ti, "Clinical Observations");
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
                SQLFragment roundsSql2 = new SQLFragment("COALESCE(" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "COALESCE((SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category != ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId AND " + ExprColumn.STR_TABLE_ALIAS + ".objectid = t.caseid), " + ExprColumn.STR_TABLE_ALIAS + ".date)") + ", 999)", ONPRC_EHRManager.VET_REVIEW);
                ExprColumn roundsCol2 = new ExprColumn(ti, daysSinceLastRounds, roundsSql2, JdbcType.INTEGER, ti.getColumn("Id"), ti.getColumn("objectid"), ti.getColumn("date"));
                roundsCol2.setLabel("Days Since Last Rounds Observations");
                ti.addColumn(roundsCol2);
            }
        }

        if (ti.getColumn("cagematesAtOpen") == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            if (us != null)
            {
                ColumnInfo lsidCol = ti.getColumn("lsid");
                ColumnInfo col = ti.addColumn(new WrappedColumn(lsidCol, "cagematesAtOpen"));
                col.setLabel("Cagemates At Open");
                col.setUserEditable(false);
                col.setIsUnselectable(true);
                col.setFk(new QueryForeignKey(us, null, "caseHousingAtOpen", "lsid", "locations"));
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
            if (realTable != null && realTable.getColumn("participantid") != null && realTable.getColumn("date") != null && realTable.getColumn("enddate") != null)
            {
                SQLFragment roomSql = new SQLFragment(realTable.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "(SELECT max(h2.enddate) as d FROM " + realTable.getSelectName() + " h2 WHERE h2.enddate IS NOT NULL AND h2.enddate <= " + ExprColumn.STR_TABLE_ALIAS + ".date AND h2.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid and h2.room != " + ExprColumn.STR_TABLE_ALIAS + ".room)"));
                ExprColumn roomCol = new ExprColumn(ti, "daysInRoom", roomSql, JdbcType.INTEGER, realTable.getColumn("participantid"), realTable.getColumn("date"), realTable.getColumn("enddate"));
                roomCol.setLabel("Days In Room");
                ti.addColumn(roomCol);

                SQLFragment sql = new SQLFragment(realTable.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "(SELECT max(h2.enddate) as d FROM " + realTable.getSelectName() + " h2 LEFT JOIN ehr_lookups.rooms r1 ON (r1.room = h2.room) WHERE h2.enddate IS NOT NULL AND h2.enddate <= " + ExprColumn.STR_TABLE_ALIAS + ".date AND h2.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid and r1.area != (select area FROM ehr_lookups.rooms r WHERE r.room = " + ExprColumn.STR_TABLE_ALIAS + ".room))"));
                ExprColumn areaCol = new ExprColumn(ti, "daysInArea", sql, JdbcType.INTEGER, realTable.getColumn("participantid"), realTable.getColumn("date"), realTable.getColumn("enddate"));
                areaCol .setLabel("Days In Area");
                ti.addColumn(areaCol );

            }
        }

        String cagePosition = "cagePosition";
        if (ti.getColumn(cagePosition) == null && ti.getColumn("cage") != null)
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

        if (ti.getColumn("cond") != null)
        {
            ti.getColumn("cond").setHidden(true);
        }

        if (ti.getColumn("previousLocation") == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            if (us != null)
            {
                ColumnInfo lsidCol = ti.getColumn("lsid");
                ColumnInfo col = ti.addColumn(new WrappedColumn(lsidCol, "previousLocation"));
                col.setLabel("Previous Location");
                col.setUserEditable(false);
                col.setIsUnselectable(true);
                col.setFk(new QueryForeignKey(us, null, "housingPreviousLocation", "lsid", "location"));
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
                "(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("REPLICATE('0', 4 - LEN(tt.time))  + cast(tt.time as varchar(4))"), true, false, chr + "(10)").getSqlCharSequence() + " as _expr " +
                " FROM ehr.treatment_times tt " +
                " WHERE tt.treatmentId = " + ExprColumn.STR_TABLE_ALIAS + ".objectid)" +
                ", (SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("REPLICATE('0', 4 - LEN(ft.hourofday))  + cast(ft.hourofday as varchar(4))"), true, false, chr + "(10)").getSqlCharSequence() + " as _expr " +
                " FROM ehr_lookups.treatment_frequency f " +
                " JOIN ehr_lookups.treatment_frequency_times ft ON (f.meaning = ft.frequency) WHERE f.rowid = " + ExprColumn.STR_TABLE_ALIAS + ".frequency)" +
                ", 'Custom')"
            );
            ExprColumn col = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, ti.getColumn("objectid"));
            col.setLabel("Times");
            ti.addColumn(col);
        }

        if (ti.getColumn("meaning") != null)
        {
            ti.getColumn("meaning").setHidden(true);
        }

        if (ti.getColumn("qualifier") != null)
        {
            ti.getColumn("qualifier").setHidden(true);
        }
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
            SQLFragment sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("REPLICATE('0', 4 - LEN(t.hourofday))  + cast(t.hourofday as varchar(4))"), true, true, "','").getSqlCharSequence() +
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
            TableInfo realTable = getRealTableForDataset(ti, "Clinical Remarks");
            if (realTable == null)
            {
                _log.warn("Unable to find real table for clin remarks");
                return;
            }

            ColumnInfo idCol = ti.getColumn("Id");
            assert idCol != null;

            SQLFragment sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.hx"), true, false, getChr(ti) + "(10)").getSqlCharSequence() + " FROM " + realTable.getSelectName() +
                    " r WHERE r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.hx IS NOT NULL AND (r.category != ? OR r.category IS NULL) AND r.date = (SELECT max(date) as expr FROM " + realTable.getSelectName() + " r2 "
                    + " WHERE r2.participantId = r.participantId AND r2.hx is not null AND (r2.category != ? OR r2.category IS NULL)))", ONPRC_EHRManager.REPLACED_SOAP, ONPRC_EHRManager.REPLACED_SOAP
            );
            ExprColumn latestHx = new ExprColumn(ti, hxName, sql, JdbcType.VARCHAR, idCol);
            latestHx.setLabel("Most Recent Hx");
            latestHx.setDisplayColumnFactory(new DisplayColumnFactory()
            {
                @Override
                public DisplayColumn createRenderer(ColumnInfo colInfo)
                {
                    return new FixedWidthDisplayColumn(colInfo, 200);
                }
            });

            ti.addColumn(latestHx);
        }

        //vet review
        String lastVetReview = "lastVetReview";
        if (ti.getColumn(lastVetReview) == null)
        {
            TableInfo obsRealTable = getRealTableForDataset(ti, "Clinical Observations");
            TableInfo remarksTable = getRealTableForDataset(ti, "Clinical Remarks");
            if (obsRealTable != null && remarksTable != null)
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


                //clinical remarks entered since last vet review is a proxy for whether it needs to be reviewed again
                EHRQCState completedQCState = EHRService.get().getQCStates(ti.getUserSchema().getContainer()).get(EHRService.QCSTATES.Completed.name());
                if (completedQCState != null)
                {
                    SQLFragment totalRemarkSql = new SQLFragment("(SELECT count(*) FROM " + remarksTable.getSelectName() + " cr WHERE cr.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid AND cr.qcstate = ? AND cr.datefinalized >= COALESCE((SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category = ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId), ?) AND (cr.category IS NULL or cr.category = ? or cr.category = ?))", completedQCState.getRowId(), ONPRC_EHRManager.VET_REVIEW, getDefaultVetReviewDate(ti.getUserSchema().getContainer()), ONPRC_EHRManager.CLINICAL_SOAP_CATEGORY, ONPRC_EHRManager.RECORD_AMENDMENT);
                    ExprColumn totalRemarkCol = new ExprColumn(ti, "totalRemarksEnteredSinceReview", totalRemarkSql, JdbcType.INTEGER, ti.getColumn("Id"));
                    totalRemarkCol.setLabel("# Remarks Entered Since Last Vet Review");
                    ti.addColumn(totalRemarkCol);

                    SQLFragment earliestRemarkSql = new SQLFragment("(SELECT min(cr.datefinalized) as expr FROM " + remarksTable.getSelectName() + " cr WHERE cr.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid AND cr.qcstate = ? AND cr.datefinalized >= COALESCE((SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category = ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId), ?) AND (cr.category IS NULL or cr.category = ? or cr.category = ?))", completedQCState.getRowId(), ONPRC_EHRManager.VET_REVIEW, getDefaultVetReviewDate(ti.getUserSchema().getContainer()), ONPRC_EHRManager.CLINICAL_SOAP_CATEGORY, ONPRC_EHRManager.RECORD_AMENDMENT);
                    ExprColumn earliestRemarkCol = new ExprColumn(ti, "earliestRemarkSinceReview", earliestRemarkSql, JdbcType.TIMESTAMP, ti.getColumn("Id"));
                    earliestRemarkCol.setLabel("Earliest Remark Entered Since Last Vet Review");
                    ti.addColumn(earliestRemarkCol);

                    //date part not supported in postgres
                    if (ti.getSqlDialect().isSqlServer())
                    {
                        //NOTE: the first token in the group_concat() is used for sorting
                        SQLFragment groupConatSql = new SQLFragment(ti.getSqlDialect().concatenate("LEFT(CONVERT(VARCHAR, cr.date, 120), 19)", "'<>'", "CAST(" + ti.getSqlDialect().getDatePart(Calendar.MONTH, "cr.date") + " AS VARCHAR)", "'/'", "CAST(" + ti.getSqlDialect().getDatePart(Calendar.DATE, "cr.date") + " AS VARCHAR)", "': '", getChr(ti) + "(10)", "CASE WHEN cr.description IS NULL THEN '' ELSE " + ti.getSqlDialect().concatenate("COALESCE(cr.description, '')", getChr(ti) + "(10)") + " END", "CASE WHEN cr.remark IS NULL THEN '' ELSE " + ti.getSqlDialect().concatenate("'Remark: '",  "COALESCE(cr.remark, '')", getChr(ti) + "(10)") + " END", "CASE WHEN cr.performedby IS NULL THEN '' ELSE " + ti.getSqlDialect().concatenate("'Entered By: '",  "COALESCE(cr.performedby, '')", getChr(ti) + "(10)") + " END", "'<>'","cr.objectid", "'<:>'"));
                        SQLFragment remarkSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(groupConatSql, false, true, ti.getSqlDialect().concatenate(getChr(ti) + "(10)", getChr(ti) + "(10)")).getSqlCharSequence() + " as expr1 FROM " + remarksTable.getSelectName() + " cr WHERE cr.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid AND cr.qcstate = ? AND cr.datefinalized <= {fn now()} AND (cr.category IS NULL or cr.category = ? or cr.category = ?) AND cr.datefinalized >= COALESCE((SELECT max(t.date) as expr FROM " + obsRealTable.getSelectName() + " t WHERE t.category = ? AND " + ExprColumn.STR_TABLE_ALIAS + ".participantId = t.participantId), ?))", completedQCState.getRowId(), ONPRC_EHRManager.CLINICAL_SOAP_CATEGORY, ONPRC_EHRManager.RECORD_AMENDMENT, ONPRC_EHRManager.VET_REVIEW, getDefaultVetReviewDate(ti.getUserSchema().getContainer()));
                        ExprColumn remarkCol = new ExprColumn(ti, "remarksEnteredSinceReview", remarkSql, JdbcType.VARCHAR, ti.getColumn("Id"), ti.getColumn("date"));
                        remarkCol.setLabel("Remarks Entered Since Last Vet Review");
                        remarkCol.setDisplayWidth("200");
                        remarkCol.setDisplayColumnFactory(new DisplayColumnFactory()
                        {
                            @Override
                            public DisplayColumn createRenderer(ColumnInfo colInfo)
                            {
                                return new VetReviewDisplayColumn(colInfo);
                            }
                        });
                        ti.addColumn(remarkCol);
                    }
                }
            }
        }

        if (ti.getColumn("mostRecentClinicalObservations") == null)
        {
            UserSchema us = getStudyUserSchema(ti);
            ColumnInfo col17 = getWrappedCol(us, ti, "mostRecentClinicalObservations", "mostRecentClinicalObservationsForAnimal", "Id", "Id");
            col17.setLabel("Most Recent Clinical Observations");
            col17.setDescription("Displays the most recent set of clinical observations for this animal");
            col17.setDisplayWidth("150");
            col17.setDisplayColumnFactory(new ObservationDisplayColumnFactory());        //Added:9-8-2016 R.Blasa
            ti.addColumn(col17);
        }

        ColumnInfo birthCol = ti.getColumn("birth");
        if (birthCol != null)
        {
            birthCol.setFormat(LookAndFeelProperties.getInstance(ti.getUserSchema().getContainer()).getDefaultDateTimeFormat());
        }

        ColumnInfo deathCol = ti.getColumn("death");
        if (deathCol != null)
        {
            deathCol.setFormat(LookAndFeelProperties.getInstance(ti.getUserSchema().getContainer()).getDefaultDateTimeFormat());
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

    private void customizeDeathTable(AbstractTableInfo ti)
    {
        if (ti.getColumn("manner") != null)
        {
            ti.getColumn("manner").setHidden(true);
        }
    }

    private void customizeBirthTable(AbstractTableInfo ti)
    {
        ColumnInfo birthCondition = ti.getColumn("birth_condition");
        if (birthCondition != null)
        {
            birthCondition.setLabel("Birth Condition");
            UserSchema us = getUserSchema(ti, "onprc_ehr");
            if (us != null)
            {
                birthCondition.setFk(new QueryForeignKey(us, null, "birth_condition", "value", "value"));
            }
        }

        ColumnInfo cond = ti.getColumn("cond");
        if (cond != null)
        {
            cond.setHidden(true);
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

        TableInfo realTable = getRealTableForDataset(ti, "Clinical Remarks");
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
        SQLFragment p2Sql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'P2: '", "r.p2")), true, false, chr + "(10)").getSqlCharSequence() + " FROM " + realTable.getSelectName() +
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
        SQLFragment p2Sql2 = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment(ti.getSqlDialect().concatenate("'P2: '", "r.p2")), true, false, chr + "(10)").getSqlCharSequence() + " FROM " + realTable.getSelectName() +
                " r WHERE "
                //+ " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.p2 IS NOT NULL AND CAST(r.date AS date) = CAST(? as date) AND (r.category != ? OR r.category IS NULL))", yesterday.getTime(), ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn yesterdaysP2 = new ExprColumn(ti, "yesterdaysP2", p2Sql2, JdbcType.VARCHAR, objectId);
        yesterdaysP2.setLabel("P2s Entered Yesterday");
        yesterdaysP2.setDisplayWidth("200");
        ti.addColumn(yesterdaysP2);

        //uses caseId as a proxy for rounds
        SQLFragment rmSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.remark"), true, false, chr + "(10)").getSqlCharSequence() + " FROM " + realTable.getSelectName() +
                " r WHERE "
                + " r.caseid = " + ExprColumn.STR_TABLE_ALIAS + ".objectid AND "
                + " r.participantId = " + ExprColumn.STR_TABLE_ALIAS + ".participantId AND r.remark IS NOT NULL AND CAST(r.date AS date) = CAST(? as date) AND (r.category != ? OR r.category IS NULL))", new Date(), ONPRC_EHRManager.REPLACED_SOAP);
        ExprColumn todaysRemarks = new ExprColumn(ti, "todaysRemarks", rmSql, JdbcType.VARCHAR, objectId);
        todaysRemarks.setLabel("Remarks Entered Today");
        todaysRemarks.setDescription("This shows any remarks entered today for this case");
        todaysRemarks.setDisplayWidth("200");
        ti.addColumn(todaysRemarks);

        //TODO: convert to a real column
        SQLFragment assesmentSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("r.a"), true, false, chr + "(10)").getSqlCharSequence() + " FROM " + realTable.getSelectName() +
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
            ColumnInfo col17 = getWrappedCol(us, ti, "mostRecentObservations", "mostRecentObservationsForCase", "objectid", "caseid");
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

        TableInfo realTable = getRealTableForDataset(ti, "Clinical Encounters");
        if (realTable == null)
        {
            _log.warn("Unable to find real table for clin encounters");
            return;
        }

        //find any surgical procedures from the same date as this case
        String chr = ti.getSqlDialect().isPostgreSQL() ? "chr" : "char";
        SQLFragment procedureSql = new SQLFragment("(SELECT " + ti.getSqlDialect().getGroupConcat(new SQLFragment("p.name"), false, false, chr + "(10)").getSqlCharSequence() +
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

        ColumnInfo updateTaskId = ti.getColumn("updateTaskId");
        if (updateTaskId == null)
        {
            updateTaskId = new WrappedColumn(ti.getColumn("rowid"), "updateTaskId");
            ti.addColumn(updateTaskId);
        }

        if (ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), EHRDataEntryPermission.class))
        {
            updateCol.setURL(DetailsURL.fromString("/ehr/dataEntryForm.view?formType=${formtype}&taskid=${taskid}"));
            updateTaskId.setURL(DetailsURL.fromString("/ehr/dataEntryForm.view?formType=${formtype}&taskid=${taskid}"));
        }
        else
        {
            updateCol.setURL(detailsURL);
            updateTaskId.setURL(detailsURL);
        }

        updateCol.setLabel("Title");
        updateCol.setHidden(true);
        updateCol.setDisplayWidth("150");

        updateTaskId.setLabel("Task Id");
        updateTaskId.setHidden(true);
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
        ti.getColumn("approve").setLabel("Initial IACUC Approval Date");
        ti.getColumn("enddate").setLabel("Date Disabled");
        ti.getColumn("enddate").setDescription("This shows the date this protocol was disabled.  This is most commonly when the IACUC expires; however, it is possible for a protocol to be disabled prior to a full 3-year period for other reasons");
        ColumnInfo externalId = ti.getColumn("external_id");
        externalId.setHidden(false);
        externalId.setLabel("eIACUC #");

        ti.getColumn("first_approval").setHidden(true);
        ti.getColumn("project_type").setHidden(true);
        //ti.getColumn("ibc_approval_required").setHidden(false);
        ti.getColumn("ibc_approval_num").setHidden(false);

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
                        //when both dates are null, show null
                        " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".approve" + " IS NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".lastAnnualReview" + " IS NULL) THEN NULL" +
                        //otherwise, show the next annual renewal date
                        " ELSE {fn timestampadd(SQL_TSI_DAY, 364, COALESCE(" + ExprColumn.STR_TABLE_ALIAS + ".lastAnnualReview, " + ExprColumn.STR_TABLE_ALIAS + ".approve)" + ")}" +
                        " END)";
                SQLFragment sql = new SQLFragment(sqlString);
                ExprColumn annualReviewDateCol = new ExprColumn(ti, annualReviewDate, sql, JdbcType.DATE, ti.getColumn("approve"));
                annualReviewDateCol.setLabel("IACUC Annual Update Due Date");
                annualReviewDateCol.setDescription("This column calculates the date when the next annual update is due.  This is 364 days after the last annual review, or blank if more than 3 years after the initial IACUC approval");
                ti.addColumn(annualReviewDateCol);

                String daysUntilAnnual = "daysUntilAnnualReview";
                SQLFragment sql2 = new SQLFragment("(CASE " +
                        // see above for logic behind this
                        " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NOT NULL THEN NULL " +
                        " WHEN (" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", ExprColumn.STR_TABLE_ALIAS + ".approve") + " >= 1095) THEN NULL" +
                        //when both date are null, it is due
                        " WHEN (" + ExprColumn.STR_TABLE_ALIAS + ".approve" + " IS NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".lastAnnualReview" + " IS NULL) THEN 0" +
                        //NOTE: these expire 1 day prior to a full year, so use 364 instead of 365
                        " ELSE 364 - (" + ti.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "COALESCE(" + ExprColumn.STR_TABLE_ALIAS + ".lastAnnualReview, " + ExprColumn.STR_TABLE_ALIAS + ".approve)") + ")" +
                        " END)");
                ExprColumn daysUntilAnnualCol = new ExprColumn(ti, daysUntilAnnual, sql2, JdbcType.INTEGER, ti.getColumn("approve"));
                daysUntilAnnualCol.setLabel("Days Until IACUC Annual Update");
                daysUntilAnnualCol.setDescription("This column calculates the days until the next annual update is due.  This is 364 days after the last annual review, or blank if more than 3 years after the initial IACUC approval");
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
                renewalCol.setLabel("3-Yr Expiration Date");
                ti.addColumn(renewalCol);

                String daysUntil = "daysUntilRenewal";
                SQLFragment sql2 = new SQLFragment("(CASE " +
                        " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".enddate IS NULL " +
                        " THEN (" + ti.getSqlDialect().getDateDiff(Calendar.DATE, sqlString, "{fn curdate()}") + ") - 1" +
                        " ELSE NULL END)");
                ExprColumn daysUntilCol = new ExprColumn(ti, daysUntil, sql2, JdbcType.INTEGER, ti.getColumn("approve"));
                daysUntilCol.setLabel("Days Until 3-Yr Expiration");
                daysUntilCol.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
                ti.addColumn(daysUntilCol);
            }
        }
    }

    private void customizeProjects(AbstractTableInfo ti)
    {
        ti.setTitleColumn("displayName");
        LDKService.get().applyNaturalSort(ti, "displayName");

        ti.getColumn("inves").setHidden(true);
        ti.getColumn("inves2").setHidden(true);
        ti.getColumn("reqname").setHidden(true);
        ti.getColumn("research").setHidden(true);
        ti.getColumn("avail").setHidden(true);
        ti.getColumn("contact_emails").setHidden(true);
        ti.getColumn("projecttype").setHidden(true);

        ti.getColumn("project").setLabel("Project Id");
        ti.getColumn("project").setHidden(true);

        ti.getColumn("startdate").setLabel("Project Start");
        ti.getColumn("enddate").setLabel("Project End");

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

            SQLFragment sql3 = new SQLFragment("(CASE WHEN " + ExprColumn.STR_TABLE_ALIAS + ".use_category = 'Center Resource' THEN 1 ELSE 0 END)");
            ExprColumn col3 = new ExprColumn(ti, "isResource", sql3, JdbcType.INTEGER, useCol);
            col3.setLabel("Is Resource?");
            col3.setHidden(true);
            ti.addColumn(col3);
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

        ti.getColumn("housingCondition").setNullable(false);
        ti.getColumn("housingType").setNullable(false);
        ti.getColumn("maxCages").setHidden(true);
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
                    return new DataColumn(colInfo)
                    {

                        public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
                        {
                            String runId = (String) ctx.get(new FieldKey(getBoundColumn().getFieldKey().getParent(), "runIdHCT"));
                            String id = (String) ctx.get(new FieldKey(getBoundColumn().getFieldKey().getParent(), "Id"));
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

        table.getColumn("length").setHidden(true);
        table.getColumn("width").setHidden(true);
        table.getColumn("height").setHidden(true);

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

    private TableInfo getRealTableForDataset(AbstractTableInfo ti, String label)
    {
        Container ehrContainer = EHRService.get().getEHRStudyContainer(ti.getUserSchema().getContainer());
        if (ehrContainer == null)
            return null;

        Dataset ds;
        Study s = StudyService.get().getStudy(ehrContainer);
        if (s == null)
            return null;

        ds = s.getDatasetByLabel(label);
        if (ds == null)
        {
            // NOTE: this seems to happen during study import on TeamCity.  It does not seem to happen during normal operation
            _log.info("A dataset was requested that does not exist: " + label + " in container: " + ehrContainer.getPath());
            StringBuilder sb = new StringBuilder();
            for (Dataset d : s.getDatasets())
            {
                sb.append(d.getName() + ", ");
            }
            _log.info("datasets present: " + sb.toString());

            return null;
        }
        else
        {
            return StorageProvisioner.createTableInfo(ds.getDomain());
        }
    }

    private TableInfo getRealTable(TableInfo targetTable)
    {
        TableInfo realTable = null;
        if (targetTable instanceof FilteredTable)
        {
            if (targetTable instanceof DatasetTable)
            {
                Domain domain = targetTable.getDomain();
                if (domain != null)
                {
                    realTable = StorageProvisioner.createTableInfo(domain);
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

    private void appendIsAssignedAtTimeCol(UserSchema ehrSchema, AbstractTableInfo ds, final String dateColName)
    {
        String name = "isAssignedAtTime";
        if (ds.getColumn(name) != null)
            return;

        if (ds.getColumn("Id") == null || ds.getColumn(dateColName) == null || ds.getColumn("project") == null)
            return;

        if (matches(ds, "study", "assignment"))
            return;

        TableInfo realTable = getRealTableForDataset(ds, "Assignment");
        if (realTable == null)
            return;

        SQLFragment idColSql = ds.getColumn("Id").getValueSql(ExprColumn.STR_TABLE_ALIAS);
        SQLFragment dateColSql = ds.getColumn(dateColName).getValueSql(ExprColumn.STR_TABLE_ALIAS);
        SQLFragment sql = new SQLFragment("CASE " +
            " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".project IS NULL THEN NULL " +
            " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".project IN (select a.project FROM " + realTable.getSelectName() + " a WHERE a.participantid = ").append(idColSql).append(" AND CAST(a.date AS DATE) <= CAST(").append(dateColSql).append(" as DATE) AND (a.enddate IS NULL OR a.enddate >= ").append(dateColSql).append(")) THEN 'Y'" +
            " ELSE 'N' END");
        ExprColumn newCol = new ExprColumn(ds, name, sql, JdbcType.VARCHAR, ds.getColumn("Id"), ds.getColumn("date"), ds.getColumn("project"));
        newCol.setLabel("Is Assigned At Time?");
        newCol.setDescription("Displays whether the animal is assigned to the selected project on the date of each record");
        ds.addColumn(newCol);

        SQLFragment sql2 = new SQLFragment("CASE " +
                " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".project IS NULL THEN NULL " +
                " WHEN " + ExprColumn.STR_TABLE_ALIAS + ".project IN (" +
                    "select p2.project FROM " + realTable.getSelectName() + " a " +
                    "JOIN ehr.project p ON (p.container = ? AND p.project = a.project) " +
                    "JOIN ehr.project p2 ON (p2.container = ? AND p.protocol = p2.protocol AND (p.project = p2.project OR p2.enddate IS NULL or p2.enddate >= {fn curdate()})) " +
                "WHERE a.participantid = ").append(idColSql).append(" AND CAST(a.date AS DATE) <= CAST(").append(dateColSql).append(" as DATE) AND (a.enddate IS NULL OR a.enddate >= ").append(dateColSql).append(")) THEN 'Y'" +
                " ELSE 'N' END")
            .add(ehrSchema.getContainer().getId())
            .add(ehrSchema.getContainer().getId());
        ExprColumn newCol2 = new ExprColumn(ds, "isAssignedToProtocolAtTime", sql2, JdbcType.VARCHAR, ds.getColumn("Id"), ds.getColumn("date"), ds.getColumn("project"));
        newCol2.setLabel("Is Assigned To Protocol At Time?");
        newCol2.setDescription("Displays whether the animal is assigned to the provided IACUC protocol on the date of each record");
        ds.addColumn(newCol2);
    }

    private void appendAssignmentAtTimeCol(UserSchema ehrSchema, AbstractTableInfo ds, final String dateColName)
    {
        String name = "assignmentAtTime";
        if (ds.getColumn(name) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "study", "assignment", ehrSchema.getContainer()))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();
        final UserSchema targetSchema = ds.getUserSchema();
        final String ehrPath = ehrSchema.getContainer().getPath();

        WrappedColumn col = new WrappedColumn(pkCol, name);
        col.setLabel("Assignments At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey()
        {
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_assignmentsAtTime";
                QueryDefinition qd = QueryService.get().createQueryDef(targetSchema.getUser(), targetSchema.getContainer(), targetSchema, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.project.displayName, chr(10)) as projectsAtTime,\n" +
                        "group_concat(DISTINCT h.project.protocol.displayName, chr(10)) as protocolsAtTime,\n" +
                        "group_concat(DISTINCT h.project.investigatorId.lastName, chr(10)) as investigatorsAtTime,\n" +
                        "group_concat(DISTINCT h.project.name, chr(10)) as projectNumbersAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN \"" + ehrPath + "\".study.assignment h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced) AND h.qcstate.publicdata = true)\n" +
                        "group by sd." + pkCol.getSelectName());
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
                TableInfo ti = qd.getTable(errors, true);
                if (errors.size() > 0)
                {
                    _log.error("Error creating lookup table for: " + schemaName + "." + queryName + " in container: " + targetSchema.getContainer().getPath());
                    for (QueryException error : errors)
                    {
                        _log.error(error.getMessage(), error);
                    }
                    return null;
                }

                ti.getColumn(pkCol.getName()).setHidden(true);
                ti.getColumn(pkCol.getName()).setKeyField(true);

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

    private void appendFlagsAtTimeCol(final UserSchema ehrSchema, AbstractTableInfo ds, final String dateColName)
    {
        String name = "flagsAtTime";
        if (ds.getColumn(name) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "study", "flags", ehrSchema.getContainer()))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();
        final UserSchema targetSchema = ds.getUserSchema();
        final String ehrPath = ehrSchema.getContainer().getPath();

        WrappedColumn col = new WrappedColumn(pkCol, name);
        col.setLabel("Flags At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_flagsAtTime";
                QueryDefinition qd = QueryService.get().createQueryDef(targetSchema.getUser(), targetSchema.getContainer(), targetSchema, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.flag.value, chr(10)) as flagsAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN \"" + ehrPath + "\".study.flags h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced) AND h.qcstate.publicdata = true)\n" +
                        "group by sd." + pkCol.getSelectName());
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
                TableInfo ti = qd.getTable(errors, true);
                if (errors.size() > 0)
                {
                    _log.error("Error creating lookup table for: " + schemaName + "." + queryName + " in container: " + targetSchema.getContainer().getPath());
                    for (QueryException error : errors)
                    {
                        _log.error(error.getMessage(), error);
                    }
                    return null;
                }

                ti.getColumn(pkCol.getName()).setHidden(true);
                ti.getColumn(pkCol.getName()).setKeyField(true);

                ti.getColumn("flagsAtTime").setLabel("Flags At Time");

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendProblemsAtTimeCol(final UserSchema ehrSchema, AbstractTableInfo ds, final String dateColName)
    {
        final String colName = "problemsAtTime";
        if (ds.getColumn(colName) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "study", "problem", ehrSchema.getContainer()))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();
        final UserSchema targetSchema = ds.getUserSchema();
        final String ehrPath = ehrSchema.getContainer().getPath();

        WrappedColumn col = new WrappedColumn(pkCol, colName);
        col.setLabel("Problems At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_" + colName;
                QueryDefinition qd = QueryService.get().createQueryDef(targetSchema.getUser(), targetSchema.getContainer(), targetSchema, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.category, chr(10)) as problemsAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN \"" + ehrPath + "\".study.\"Problem List\" h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced) AND h.qcstate.publicdata = true)\n" +
                        "group by sd." + pkCol.getSelectName());
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
                TableInfo ti = qd.getTable(errors, true);
                if (errors.size() > 0)
                {
                    _log.error("Error creating lookup table for: " + schemaName + "." + queryName + " in container: " + targetSchema.getContainer().getPath());
                    for (QueryException error : errors)
                    {
                        _log.error(error.getMessage(), error);
                    }
                    return null;
                }

                ti.getColumn(pkCol.getName()).setHidden(true);
                ti.getColumn(pkCol.getName()).setKeyField(true);

                ti.getColumn("problemsAtTime").setLabel("Problems At Time");

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void appendGroupsAtTimeCol(final UserSchema ehrSchema, AbstractTableInfo ds, final String dateColName)
    {
        final String colName = "groupsAtTime";
        if (ds.getColumn(colName) != null)
            return;

        final ColumnInfo pkCol = getPkCol(ds);
        if (pkCol == null)
            return;

        if (ds.getColumn("Id") == null)
            return;

        if (!hasTable(ds, "study", "animal_group_members", ehrSchema.getContainer()))
            return;

        final String tableName = ds.getName();
        final String queryName = ds.getPublicName();
        final String schemaName = ds.getPublicSchemaName();
        final UserSchema targetSchema = ds.getUserSchema();
        final String ehrPath = ehrSchema.getContainer().getPath();

        WrappedColumn col = new WrappedColumn(pkCol, colName);
        col.setLabel("Groups At Time");
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new LookupForeignKey(){
            public TableInfo getLookupTableInfo()
            {
                String name = tableName + "_" + colName;
                QueryDefinition qd = QueryService.get().createQueryDef(targetSchema.getUser(), targetSchema.getContainer(), targetSchema, name);
                qd.setSql("SELECT\n" +
                        "sd." + pkCol.getSelectName() + ",\n" +
                        "group_concat(DISTINCT h.groupId.name, chr(10)) as groupsAtTime\n" +
                        "FROM \"" + schemaName + "\".\"" + queryName + "\" sd\n" +
                        "JOIN \"" + ehrPath + "\".study.animal_group_members h\n" +
                        "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd." + dateColName + " AS DATE) AND (CAST(sd." + dateColName + " AS DATE) <= h.enddateCoalesced))\n" +
                        "group by sd." + pkCol.getSelectName());
                qd.setIsTemporary(true);

                List<QueryException> errors = new ArrayList<>();
                TableInfo ti = qd.getTable(errors, true);
                if (errors.size() > 0)
                {
                    _log.error("Error creating lookup table for: " + schemaName + "." + queryName + " in container: " + targetSchema.getContainer().getPath());
                    for (QueryException error : errors)
                    {
                        _log.error(error.getMessage(), error);
                    }
                    return null;
                }

                ti.getColumn(pkCol.getName()).setHidden(true);
                ti.getColumn(pkCol.getName()).setKeyField(true);

                ti.getColumn("groupsAtTime").setLabel("Groups At Time");

                return ti;
            }
        });

        ds.addColumn(col);
    }

    private void customizeHousingRequests(AbstractTableInfo ti)
    {
        String name = "existingAnimals";
        if (ti.getColumn(name) == null)
        {
            TableInfo housing = getRealTableForDataset(ti, "housing");
            if (housing != null)
            {
                SQLFragment sql = new SQLFragment("(SELECT CASE WHEN count(h.participantid) > 8 THEN '>8 Animals' ELSE " + ti.getSqlDialect().getGroupConcat(new SQLFragment("h.participantid"), true, true, "', '").getSqlCharSequence() + " END as expr FROM studydataset." + housing.getName() + " h WHERE h.room = " + ExprColumn.STR_TABLE_ALIAS + ".room AND ((h.enddate IS NULL AND h.date <= {fn now()} AND h.cage IS NULL AND " + ExprColumn.STR_TABLE_ALIAS + ".cage IS NULL) OR (h.cage = " + ExprColumn.STR_TABLE_ALIAS + ".cage)))");
                ExprColumn newCol = new ExprColumn(ti, name, sql, JdbcType.VARCHAR, ti.getColumn("room"), ti.getColumn("cage"));
                newCol.setLabel("Animals Housed In Destination");
                ti.addColumn(newCol);
            }
        }
    }

    private void customizeCageObservations(AbstractTableInfo ti)
    {
        ti.getColumn("userid").setHidden(true);
        ti.getColumn("feces").setHidden(true);
        ti.getColumn("no_observations").setHidden(true);
    }

    private void customizeProtocolProcedures(AbstractTableInfo ti)
    {
        ColumnInfo procedureName = ti.getColumn("procedureName");
        if (procedureName != null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null)
            {
                procedureName.setFk(new QueryForeignKey(us, null, "procedureNames", "procedureName", "procedureName", true));
            }
            procedureName.setNullable(false);
        }

        ti.getColumn("code").setHidden(true);
        ti.getColumn("project").setHidden(true);
        ti.getColumn("frequency").setHidden(true);
        ti.getColumn("rowid").setHidden(true);
    }

    private void customizeClinicalObservations(AbstractTableInfo ti)
    {
        ColumnInfo categoryCol = ti.getColumn("category");
        if (categoryCol != null)
        {
            UserSchema us = getUserSchema(ti, "ehr");
            if (us != null)
            {
                categoryCol.setFk(new QueryForeignKey(us, null, "observation_types", "value", "value", true));
            }
        }
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

    private boolean hasTable(AbstractTableInfo ti, String schemaName, String queryName, Container targetContainer)
    {
        UserSchema us = getUserSchema(ti, schemaName, targetContainer);
        if (us == null)
            return false;

        return us.getTableNames().contains(queryName);
    }


}
