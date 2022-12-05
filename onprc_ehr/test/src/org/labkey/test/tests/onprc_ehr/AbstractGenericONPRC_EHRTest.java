/*
 * Copyright (c) 2016-2019 LabKey Corporation
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
package org.labkey.test.tests.onprc_ehr;

import org.apache.commons.lang3.StringUtils;
import org.json.simple.JSONObject;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.CommandResponse;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.PostCommand;
import org.labkey.remoteapi.query.Filter;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.SaveRowsResponse;
import org.labkey.remoteapi.query.SelectRowsCommand;
import org.labkey.remoteapi.query.SelectRowsResponse;
import org.labkey.test.ModulePropertyValue;
import org.labkey.test.TestFileUtils;
import org.labkey.test.WebTestHelper;
import org.labkey.test.params.FieldDefinition;
import org.labkey.test.params.list.IntListDefinition;
import org.labkey.test.params.list.ListDefinition;
import org.labkey.test.params.list.VarListDefinition;
import org.labkey.test.tests.ehr.AbstractGenericEHRTest;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.ListHelper;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.PasswordUtil;
import org.labkey.test.util.SchemaHelper;
import org.labkey.test.util.SqlserverOnlyTest;
import org.labkey.test.util.ehr.EHRClientAPIHelper;
import org.labkey.test.util.ext4cmp.Ext4CmpRef;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import static org.junit.Assert.assertTrue;

public abstract class AbstractGenericONPRC_EHRTest extends AbstractGenericEHRTest implements SqlserverOnlyTest
{
    protected static final String REFERENCE_STUDY_PATH = "/resources/referenceStudy";
    protected static final String GENETICS_PIPELINE_LOG_PATH = REFERENCE_STUDY_PATH + "/kinship/EHR Kinship Calculation/kinship.txt.log";
    protected static final String ID_PREFIX = "9999";

    //NOTE: use 0-23H to be compatible w/ client-side Ext4 fields
    protected static final SimpleDateFormat _tf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    protected static final SimpleDateFormat _df = new SimpleDateFormat("yyyy-MM-dd");

    protected final String RHESUS = "Rhesus";
    protected final String INDIAN = "INDIA";

    protected static String[] SUBJECTS = {"12345", "23456", "34567", "45678", "56789"};
    protected static String[] ROOMS = {"Room1", "Room2", "Room3"};
    protected static String[] CAGES = {"A1", "B2", "A3"};
    protected static Integer[] PROJECTS = {12345, 123456, 1234567};

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("ehr", "onprc_ehr");
    }

    @Override
    public String getContainerPath()
    {
        return getProjectName();
    }

    @Override
    protected EHRClientAPIHelper getApiHelper()
    {
        return new EHRClientAPIHelper(this, getContainerPath());
    }

    @Override
    protected void setEHRModuleProperties(ModulePropertyValue... extraProps)
    {
        log("Setting EHR Module Properties");
        clickProject(getProjectName());
        super._containerHelper.enableModule("ONPRC_Billing");
        super._containerHelper.enableModule("ONPRC_BillingPublic");
        super._containerHelper.enableModule("SLA");
        super.setEHRModuleProperties(
                new ModulePropertyValue("ONPRC_Billing", "/" + getProjectName(), "BillingContainer", "/" + getContainerPath()),
                new ModulePropertyValue("ONPRC_Billing", "/" + getProjectName(), "BillingContainer_Public", "/" + getContainerPath()),
                new ModulePropertyValue("SLA", "/" + getProjectName(), "SLAContainer", "/" + getContainerPath()),
                new ModulePropertyValue("ONPRC_EHR", "/" + getProjectName(), "DCM_NHP_Resources_Container", "/" + getContainerPath()),
                new ModulePropertyValue("ONPRC_EHR", "/" + getProjectName(), "MHC_Container", "/" + getContainerPath())
        );
    }

    @Override
    public String getModulePath()
    {
        return "server/modules/onprcEHRModules/" + getModuleDirectory();
    }

    @Override
    protected void importStudy()
    {
        importFolderFromPath(1);
    }

    @Override
    protected void doExtraPreStudyImportSetup() throws IOException, CommandException
    {
        //create onprc_billing_public linked schema
        beginAt(getProjectName());
        SchemaHelper schemaHelper = new SchemaHelper(this);
        schemaHelper.createLinkedSchema(this.getProjectName(), "onprc_billing_public", "/" + this.getContainerPath(), "onprc_billing_public", null, null, null);

        //create Labfee_NoChargeProjects
        beginAt(getProjectName());

        ListDefinition listDef = new IntListDefinition("Labfee_NoChargeProjects", "key");
        listDef.addField(new FieldDefinition("project", FieldDefinition.ColumnType.Integer));
        listDef.addField(new FieldDefinition("startDate", FieldDefinition.ColumnType.DateAndTime));
        listDef.addField(new FieldDefinition("dateDisabled", FieldDefinition.ColumnType.DateAndTime));
        listDef.addField(new FieldDefinition("Createdb", FieldDefinition.ColumnType.Integer));
        listDef.addField(new FieldDefinition("Notes", FieldDefinition.ColumnType.String));
        listDef.getCreateCommand().execute(createDefaultConnection(), getProjectName());

        ListDefinition listDef2 = new VarListDefinition("GeneticValue");
        listDef2.setKeyName("Id");
        listDef2.addField(new FieldDefinition("meanKinship", FieldDefinition.ColumnType.Decimal));
        listDef2.addField(new FieldDefinition("zscore", FieldDefinition.ColumnType.Decimal));
        listDef2.addField(new FieldDefinition("genomeUniqueness", FieldDefinition.ColumnType.Decimal));
        listDef2.addField(new FieldDefinition("totalOffspring", FieldDefinition.ColumnType.Integer));
        listDef2.addField(new FieldDefinition("livingOffspring", FieldDefinition.ColumnType.Integer));
        listDef2.addField(new FieldDefinition("assignments", FieldDefinition.ColumnType.Integer));
        listDef2.addField(new FieldDefinition("condition", FieldDefinition.ColumnType.String));
        listDef2.addField(new FieldDefinition("import", FieldDefinition.ColumnType.String));
        listDef2.addField(new FieldDefinition("value", FieldDefinition.ColumnType.String));
        listDef2.addField(new FieldDefinition("rank", FieldDefinition.ColumnType.Integer));
        listDef2.getCreateCommand().execute(createDefaultConnection(), getProjectName());

        ListDefinition listDef3 = new IntListDefinition("Special_Aliases", "Key");
        listDef3.addField(new FieldDefinition("Category", FieldDefinition.ColumnType.String));
        listDef3.addField(new FieldDefinition("Alias", FieldDefinition.ColumnType.String));
        listDef3.getCreateCommand().execute(createDefaultConnection(), getProjectName());

        ListDefinition listDef4 = new IntListDefinition("Rpt_ChargesProjection", "RowId");
        listDef4.addField(new FieldDefinition("ChargeId", FieldDefinition.ColumnType.Integer));
        listDef4.addField(new FieldDefinition("UnitCost", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year1", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year2", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year3", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year4", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year5", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year6", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year7", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("year8", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate1", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate2", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate3", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate4", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate5", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate6", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate7", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate8", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("Aprate9", FieldDefinition.ColumnType.Decimal));
        listDef4.addField(new FieldDefinition("PostedDate", FieldDefinition.ColumnType.DateAndTime));
        listDef4.getCreateCommand().execute(createDefaultConnection(), getProjectName());

        // Mock up a table in the MHC_Data schema instead of needing to mock up all of its dependencies too
        ListDefinition listDef5 = new IntListDefinition("MHC_Data_Unified", "RowId");
        listDef5.addField(new FieldDefinition("Id", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("SubjectId", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("allele", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("shortName", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("totalTests", FieldDefinition.ColumnType.Integer));
        listDef5.addField(new FieldDefinition("assayType", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("marker", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("score", FieldDefinition.ColumnType.Decimal));
        listDef5.addField(new FieldDefinition("datatype", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("result", FieldDefinition.ColumnType.String));
        listDef5.addField(new FieldDefinition("type", FieldDefinition.ColumnType.String));
        listDef5.getCreateCommand().execute(createDefaultConnection(), getProjectName());

        schemaHelper.createLinkedSchema(this.getProjectName(), "dbo", "/" + this.getContainerPath(), null, "lists", null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "MHC_Data", "/" + this.getContainerPath(), null, "lists", null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "ehrSLA", "/" + this.getContainerPath(), "ehrSLA", "sla", null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "financepublic", "/" + this.getContainerPath(), "financepublic", "onprc_billing", null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "publicehr", "/" + this.getContainerPath(), null, "ehr", null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "onprc_ehrSLA", "/" + this.getContainerPath(), null, "onprc_ehr", null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "pf_onprcehrPublic", "/" + this.getContainerPath(), "pf_onprcehrPublic", null, null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "pf_publicEHR", "/" + this.getContainerPath(), "pf_publicEHR", null, null, null);
        schemaHelper.createLinkedSchema(this.getProjectName(), "pf_publicFinance", "/" + this.getContainerPath(), "pf_publicFinance", null, null, null);
    }

    @Override
    @LogMethod
    protected void initProject() throws Exception
    {
        super.initProject("ONPRC EHR");

        //this applies the standard property descriptors, creates indexes, etc.
        // NOTE: this currently will log an error from DatasetDefinition whenever we create a new column.  This really isnt a bug, so ignore
        checkErrors();
        Connection connection = createDefaultConnection(true);
        PostCommand command = new PostCommand("ehr", "ensureDatasetProperties");
        command.setTimeout(1200000);
        CommandResponse response = command.execute(connection, getContainerPath());
        assertTrue("Problem with ehr-ensureDatasetProperties: [" +response.getStatusCode() + "] " + response.getText(), response.getStatusCode() < 400);
        resetErrors();

        cacheIds(Arrays.asList(MORE_ANIMAL_IDS));
    }

    protected void cacheIds(Collection<String> ids)
    {
        beginAt(WebTestHelper.getBaseURL() + "/ehr/" + getContainerPath() + "/getDemographics.view?ids=" + StringUtils.join(ids, "&ids="));
        waitForText(ids.iterator().next());

        goToProjectHome();
    }

    protected void setupNotificationService()
    {
        //set general settings
        beginAt(getBaseURL() + "/ldk/" + getContainerPath() + "/notificationAdmin.view");
        _helper.waitForCmp("field[fieldLabel='Notification User']");
        Ext4FieldRef.getForLabel(this, "Notification User").setValue(PasswordUtil.getUsername());
        Ext4FieldRef.getForLabel(this, "Reply Email").setValue("fakeEmail@fakeDomain.test");
        Ext4CmpRef btn = _ext4Helper.queryOne("button[text='Save']", Ext4CmpRef.class);
        btn.waitForEnabled();
        waitAndClick(Ext4Helper.Locators.ext4Button("Save"));
        waitForElement(Ext4Helper.Locators.window("Success"));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("OK"));
    }

    @Override
    protected void populateInitialData()
    {
        beginAt(getBaseURL() + "/" + getModuleDirectory() + "/" + getContainerPath() + "/populateData.view");

        repopulate("Lookup Sets");
        repopulate("Procedures");
        repopulate("Labwork Types");
        repopulate("All");
        repopulate("SNOMED Codes");

        //also populate templates
        beginAt(getBaseURL() + "/" + getModuleDirectory() + "/" + getContainerPath() + "/populateTemplates.view");

        repopulate("Form Templates");
        repopulate("Formulary");
    }

    @Override
    protected File getStudyPolicyXML()
    {
        return TestFileUtils.getSampleData("onprcEHRStudyPolicy.xml");
    }

    @Override
    @LogMethod
    protected void createTestSubjects() throws Exception
    {
        super.createTestSubjects();
        //create cases
        log("creating cases");
        Date pastDate1 = TIME_FORMAT.parse("2012-01-03 09:30");
        String[] fields = new String[]{"Id", "date", "category"};
        Object[][] data = new Object[][]{
                {SUBJECTS[0], pastDate1, "Clinical"},
                {SUBJECTS[0], pastDate1, "Surgery"},
                {SUBJECTS[0], pastDate1, "Behavior"},
                {SUBJECTS[1], pastDate1, "Clinical"},
                {SUBJECTS[1], pastDate1, "Surgery"}
        };
        PostCommand insertCommand = getApiHelper().prepareInsertCommand("study", "cases", "lsid", fields, data);
        getApiHelper().deleteAllRecords("study", "cases", new Filter("Id", StringUtils.join(SUBJECTS, ";"), Filter.Operator.IN));
        getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), insertCommand, getExtraContext());
    }

    protected String generateGUID()
    {
        return (String)executeScript("return LABKEY.Utils.generateUUID().toUpperCase()");
    }

    protected Date prepareDate(Date date, int daysOffset, int hoursOffset)
    {
        Calendar beforeInterval = Calendar.getInstance();
        beforeInterval.setTime(date);
        beforeInterval.add(Calendar.DATE, daysOffset);
        beforeInterval.add(Calendar.HOUR_OF_DAY, hoursOffset);

        return beforeInterval.getTime();
    }

    @Override
    protected JSONObject getExtraContext()
    {
        JSONObject extraContext = getApiHelper().getExtraContext();
        extraContext.remove("targetQC");
        extraContext.remove("isLegacyFormat");

        return extraContext;
    }

    protected String ensureFlagExists(final String category, final String name, final String code) throws Exception
    {
        SelectRowsCommand select1 = new SelectRowsCommand("ehr_lookups", "flag_values");
        select1.addFilter(new Filter("category", category, Filter.Operator.EQUAL));
        select1.addFilter(new Filter("value", name, Filter.Operator.EQUAL));
        SelectRowsResponse resp = select1.execute(getApiHelper().getConnection(), getContainerPath());

        String objectid = resp.getRowCount().intValue() == 0 ? null : (String)resp.getRows().get(0).get("objectid");
        if (objectid == null)
        {
            InsertRowsCommand insertRowsCommand = new InsertRowsCommand("ehr_lookups", "flag_values");
            insertRowsCommand.addRow(new HashMap<String, Object>(){
                {
                    put("category", category);
                    put("value", name);
                    put("code", code);
                    put("objectid", null);  //will get set on server
                }
            });

            SaveRowsResponse saveRowsResponse = insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());
            objectid = (String)saveRowsResponse.getRows().get(0).get("objectid");
        }

        return objectid;
    }

    protected void ensureRoomExists(final String room) throws Exception
    {
        SelectRowsCommand select1 = new SelectRowsCommand("ehr_lookups", "rooms");
        select1.addFilter(new Filter("room", room, Filter.Operator.EQUAL));
        SelectRowsResponse resp = select1.execute(getApiHelper().getConnection(), getContainerPath());

        if (resp.getRowCount().intValue() == 0)
        {
            log("creating room: " + room);
            InsertRowsCommand insertRowsCommand = new InsertRowsCommand("ehr_lookups", "rooms");
            insertRowsCommand.addRow(new HashMap<String, Object>(){
                {
                    put("room", room);
                    put("housingType", 1);
                    put("housingCondition", 1);
                }
            });

            insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());
        }
        else
        {
            log("room already exists: " + room);
        }
    }

    protected Integer getOrCreateGroup(final String name) throws Exception
    {
        SelectRowsCommand select1 = new SelectRowsCommand("ehr", "animal_groups");
        select1.addFilter(new Filter("name", name, Filter.Operator.EQUAL));
        SelectRowsResponse resp = select1.execute(getApiHelper().getConnection(), getContainerPath());
        Integer groupId = resp.getRowCount().intValue() == 0 ? null : (Integer)resp.getRows().get(0).get("rowid");
        if (groupId == null)
        {
            InsertRowsCommand insertRowsCommand = new InsertRowsCommand("ehr", "animal_groups");
            insertRowsCommand.addRow(new HashMap<String, Object>(){
                {
                    put("name", name);
                }
            });

            SaveRowsResponse saveRowsResponse = insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());
            groupId = ((Long)saveRowsResponse.getRows().get(0).get("rowid")).intValue();
        }

        return groupId;
    }

    protected void ensureGroupMember(final int groupId, final String animalId) throws Exception
    {
        SelectRowsCommand select1 = new SelectRowsCommand("study", "animal_group_members");
        select1.addFilter(new Filter("Id", animalId, Filter.Operator.EQUAL));
        select1.addFilter(new Filter("isActive", true, Filter.Operator.EQUAL));

        SelectRowsResponse resp = select1.execute(getApiHelper().getConnection(), getContainerPath());
        if (resp.getRowCount().intValue() == 0)
        {
            InsertRowsCommand insertRowsCommand = new InsertRowsCommand("study", "animal_group_members");
            insertRowsCommand.addRow(new HashMap<String, Object>(){
                {
                    put("Id", animalId);
                    put("date", prepareDate(new Date(), -2, 0));
                    put("groupId", groupId);
                }
            });

            insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());
        }
    }

    protected String getOrCreateSpfFlag(final String name) throws Exception
    {
        SelectRowsCommand select1 = new SelectRowsCommand("ehr_lookups", "flag_values");
        select1.addFilter(new Filter("category", "SPF", Filter.Operator.EQUAL));
        select1.addFilter(new Filter("value", name, Filter.Operator.EQUAL));
        SelectRowsResponse resp = select1.execute(getApiHelper().getConnection(), getContainerPath());

        String objectid = resp.getRowCount().intValue() == 0 ? null : (String)resp.getRows().get(0).get("objectid");
        if (objectid == null)
        {
            InsertRowsCommand insertRowsCommand = new InsertRowsCommand("ehr_lookups", "flag_values");
            insertRowsCommand.addRow(new HashMap<String, Object>(){
                {
                    put("category", "SPF");
                    put("value", name);
                    put("objectid", null);  //will get set on server
                }
            });

            SaveRowsResponse saveRowsResponse = insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());
            objectid = (String)saveRowsResponse.getRows().get(0).get("objectid");
        }

        return objectid;
    }

    protected <T extends Ext4CmpRef> T getFieldInWindow(String label, Class<T> clazz)
    {
        return _ext4Helper.queryOne("window field[fieldLabel='" + label + "']", clazz);
    }

    protected void cleanRecords(String... ids) throws Exception
    {
        getApiHelper().deleteAllRecords("study", "birth", new Filter("Id", StringUtils.join(ids, ";"), Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "housing", new Filter("Id", StringUtils.join(ids, ";"), Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "flags", new Filter("Id", StringUtils.join(ids, ";"), Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "assignment", new Filter("Id", StringUtils.join(ids, ";"), Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "demographics", new Filter("Id", StringUtils.join(ids, ";"), Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "weight", new Filter("Id", StringUtils.join(ids, ";"), Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "animal_group_members", new Filter("Id", StringUtils.join(ids, ";"), Filter.Operator.IN));
    }

    @Override //Block test that doesn't work with ONPRC
    public void testCalculatedAgeColumns(){}

    @Override
    protected abstract String getAnimalHistoryPath();
}
