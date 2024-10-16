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
import org.apache.commons.lang3.time.DateUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.json.JSONArray;
import org.json.JSONObject;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.CommandResponse;
import org.labkey.remoteapi.query.Filter;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.SelectRowsCommand;
import org.labkey.remoteapi.query.SelectRowsResponse;
import org.labkey.remoteapi.query.Sort;
import org.labkey.remoteapi.query.UpdateRowsCommand;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.Locators;
import org.labkey.test.TestFileUtils;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.ONPRC;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.pages.ehr.AnimalHistoryPage;
import org.labkey.test.pages.ehr.EnterDataPage;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PasswordUtil;
import org.labkey.test.util.RReportHelper;
import org.labkey.test.util.ehr.EHRClientAPIHelper;
import org.labkey.test.util.ext4cmp.Ext4CmpRef;
import org.labkey.test.util.ext4cmp.Ext4ComboRef;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;
import org.labkey.test.util.ext4cmp.Ext4GridRef;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

@Category({CustomModules.class, EHR.class, ONPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 60)
public class ONPRC_EHRTest extends AbstractGenericONPRC_EHRTest
{
    protected String PROJECT_NAME = "ONPRC_EHR_TestProject";
    private boolean _hasCreatedBirthRecords = false;
    private final String ANIMAL_HISTORY_URL = "/" + getProjectName() + "/ehr-animalHistory.view";

    @Override
    protected String getProjectName()
    {
        return PROJECT_NAME;
    }

    @Override
    protected String getModuleDirectory()
    {
        return "onprc_ehr";
    }

    @BeforeClass
    @LogMethod
    public static void doSetup() throws Exception
    {
        ONPRC_EHRTest initTest = (ONPRC_EHRTest)getCurrentTest();

        initTest.initProject();
        initTest.createTestSubjects();
        initTest.createBirthRecords();
        new RReportHelper(initTest).ensureRConfig();

    }

    @Override
    protected boolean doSetUserPasswords()
    {
        return true;
    }

    @Test
    public void testOverriddenActions() throws Exception
    {
        Pair<String, Integer> ids = generateProtocolAndProject();
        String protocolId = ids.getLeft();
        Integer projectId = ids.getRight();

        //this QWP is in the onprc_ehr projectDetails, but not the core EHR version.  because ONPRC_EHR modules
        // overrides this view, EHR should serve the ONPRC_EHR HTML file through EHR controller
        beginAt("/ehr/" + getContainerPath() + "/projectDetails.view?project=" + projectId);
        waitForElement(Locator.tagContainingText("span", "Housing Summary"));

        // same idea as above
        beginAt("/ehr/" + getContainerPath() + "/protocolDetails.view?protocol=" + protocolId);
        waitForElement(Locator.tagContainingText("a", "View Active Animal Assignments"));
    }

    private Pair<String, Integer> generateProtocolAndProject() throws Exception
    {
            //create project
            String protocolTitle = generateGUID();
            InsertRowsCommand protocolCommand = new InsertRowsCommand("ehr", "protocol");
            protocolCommand.addRow(Maps.of("protocol", null, "title", protocolTitle));
            protocolCommand.execute(getApiHelper().getConnection(), getContainerPath());

            SelectRowsCommand protocolSelect = new SelectRowsCommand("ehr", "protocol");
            protocolSelect.addFilter(new Filter("title", protocolTitle));
            final String protocolId = (String)protocolSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("protocol");
            Assert.assertNotNull(StringUtils.trimToNull(protocolId));

            InsertRowsCommand projectCommand = new InsertRowsCommand("ehr", "project");
            String projectName = generateGUID();
            projectCommand.addRow(Maps.of("project", null, "name", projectName, "protocol", protocolId));
            projectCommand.execute(getApiHelper().getConnection(), getContainerPath());

            SelectRowsCommand projectSelect = new SelectRowsCommand("ehr", "project");
            projectSelect.addFilter(new Filter("protocol", protocolId));
            Integer projectId = (Integer)projectSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("project");

            return Pair.of(protocolId, projectId);
}

    @Test
    public void testAssignmentApi() throws Exception
    {
        final String investLastName = "Tester";

        goToProjectHome();

        String[][] CONDITION_FLAGS = new String[][]{
                {"Nonrestricted", "201"},
                {"Protocol Restricted", "202"},
                {"Surgically Restricted", "203"}
        };

        final Map<String, String> flagMap = new HashMap<>();
        for (String[] row : CONDITION_FLAGS)
        {
            flagMap.put(row[0], ensureFlagExists("Condition", row[0], row[1]));
        }

        //pre-clean
        getApiHelper().deleteAllRecords("study", "flags", new Filter("Id", SUBJECTS[1], Filter.Operator.EQUAL));

        //create project
        String protocolTitle = generateGUID();
        InsertRowsCommand protocolCommand = new InsertRowsCommand("ehr", "protocol");
        protocolCommand.addRow(Maps.of("protocol", null, "title", protocolTitle));
        protocolCommand.execute(getApiHelper().getConnection(), getContainerPath());

        SelectRowsCommand protocolSelect = new SelectRowsCommand("ehr", "protocol");
        protocolSelect.addFilter(new Filter("title", protocolTitle));
        final String protocolId = (String)protocolSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("protocol");
        Assert.assertNotNull(StringUtils.trimToNull(protocolId));

        InsertRowsCommand investigatorsCommand = new InsertRowsCommand("onprc_ehr", "investigators");
        investigatorsCommand.addRow(Maps.of("firstName", "Testie", "lastName", investLastName));
        CommandResponse response = investigatorsCommand.execute(getApiHelper().getConnection(), getContainerPath());
        var id = ((HashMap<?, ?>) ((ArrayList<?>) response.getParsedData().get("rows")).get(0)).get("rowid");

        InsertRowsCommand projectCommand = new InsertRowsCommand("ehr", "project");
        String projectName = generateGUID();
        projectCommand.addRow(Maps.of("project", null, "name", projectName, "protocol", protocolId, "investigatorId", id));
        projectCommand.execute(getApiHelper().getConnection(), getContainerPath());

        SelectRowsCommand projectSelect = new SelectRowsCommand("ehr", "project");
        projectSelect.setColumns(List.of("project", "investigatorId/lastName"));
        projectSelect.addFilter(new Filter("protocol", protocolId));
        SelectRowsResponse resp = projectSelect.execute(getApiHelper().getConnection(), getContainerPath());
        final Integer projectId = (Integer)resp.getRows().get(0).get("project");
        final String invest = (String) resp.getRows().get(0).get("investigatorId/lastName");

        assertEquals("Investigator name not correct in project table", invest, investLastName);

        // Try with a row that doesn't pass validation
        Map<String, Object> protocolCountsRow = new HashMap<>();
        protocolCountsRow.put("protocol", protocolId);
        protocolCountsRow.put("species", "Cynomolgus");
        protocolCountsRow.put("allowed", 2);
        protocolCountsRow.put("start", prepareDate(new Date(), -10, 0));
        try
        {
            InsertRowsCommand protocolCountsCommand = new InsertRowsCommand("ehr", "protocol_counts");
            protocolCountsCommand.addRow(protocolCountsRow);
            protocolCountsCommand.execute(getApiHelper().getConnection(), getContainerPath());
            fail("Should have gotten an exception due to missing end date");
        }
        catch (CommandException e)
        {
            assertEquals("Wrong failure message", "ERROR: Must enter Start and End dates", e.getMessage());
        }

        // Then try again with the problem corrected
        protocolCountsRow.put("enddate", prepareDate(new Date(), 370, 0));
        InsertRowsCommand protocolCountsCommand = new InsertRowsCommand("ehr", "protocol_counts");
        protocolCountsCommand.addRow(protocolCountsRow);
        protocolCountsCommand.execute(getApiHelper().getConnection(), getContainerPath());

        //create assignment
        InsertRowsCommand assignmentCommand = new InsertRowsCommand("study", "assignment");
        assignmentCommand.addRow(new HashMap<String, Object>(){
        {
            put("Id", SUBJECTS[1]);
            put("date", prepareDate(new Date(), -10, 0));
            put("objectid", generateGUID());
            put("assignCondition", 202); //Protocol Restricted
            put("projectedReleaseCondition", 203); //Surgically Restricted
            put("project", projectId);
        }});
        assignmentCommand.execute(getApiHelper().getConnection(), getContainerPath());

        //setting of enddatefinalized, datefinalized
        SelectRowsCommand assignmentSelect1 = new SelectRowsCommand("study", "assignment");
        assignmentSelect1.addFilter(new Filter("Id", SUBJECTS[1]));
        assignmentSelect1.addFilter(new Filter("project", projectId));
        assignmentSelect1.setColumns(Arrays.asList("Id", "lsid", "datefinalized", "enddatefinalized", "project/investigatorId/lastName"));
        SelectRowsResponse assignmentResponse1 = assignmentSelect1.execute(getApiHelper().getConnection(), getContainerPath());
        Assert.assertNotNull(assignmentResponse1.getRows().get(0).get("datefinalized"));
        Assert.assertNull(assignmentResponse1.getRows().get(0).get("enddatefinalized"));

        final String assignInvest = (String)assignmentResponse1.getRows().get(0).get("project/investigatorId/lastName");
        assertEquals("Investigator name link broken from assignment dataset", assignInvest, investLastName);

        final String assignmentLsid1 = (String)assignmentResponse1.getRows().get(0).get("lsid");

        //expect animal condition to change
        SelectRowsCommand conditionSelect1 = new SelectRowsCommand("study", "flags");
        conditionSelect1.addFilter(new Filter("Id", SUBJECTS[1]));
        conditionSelect1.addFilter(new Filter("flag/category", "Condition"));
        conditionSelect1.addFilter(new Filter("isActive", true));
        SelectRowsResponse conditionResponse1 = conditionSelect1.execute(getApiHelper().getConnection(), getContainerPath());
        assertEquals(1, conditionResponse1.getRowCount().intValue());
        assertEquals("Protocol Restricted", conditionResponse1.getRows().get(0).get("flag/value"));

        //terminate, expect animal condition to change based on release condition
        UpdateRowsCommand assignmentUpdateCommand = new UpdateRowsCommand("study", "assignment");
        assignmentUpdateCommand.addRow(new HashMap<String, Object>(){
            {
                put("lsid", assignmentLsid1);
                put("enddate", prepareDate(new Date(), -5, 0));
                put("releaseCondition", 203); //Surgically Restricted
            }});
        assignmentUpdateCommand.execute(getApiHelper().getConnection(), getContainerPath());

        SelectRowsCommand conditionSelect2 = new SelectRowsCommand("study", "flags");
        conditionSelect2.addFilter(new Filter("Id", SUBJECTS[1]));
        conditionSelect2.addFilter(new Filter("flag/category", "Condition"));
        conditionSelect2.addFilter(new Filter("isActive", true));
        SelectRowsResponse conditionResponse2 = conditionSelect2.execute(getApiHelper().getConnection(), getContainerPath());
        assertEquals(1, conditionResponse2.getRowCount().intValue());
        assertEquals("Surgically Restricted", conditionResponse2.getRows().get(0).get("flag/value"));

        //make sure other flag terminated on correct date
        SelectRowsCommand conditionSelect3 = new SelectRowsCommand("study", "flags");
        conditionSelect3.addFilter(new Filter("Id", SUBJECTS[1]));
        conditionSelect3.addFilter(new Filter("flag", flagMap.get("Protocol Restricted")));
        conditionSelect3.addFilter(new Filter("enddate", prepareDate(new Date(), -5, 0), Filter.Operator.DATE_EQUAL));
        SelectRowsResponse conditionResponse3 = conditionSelect3.execute(getApiHelper().getConnection(), getContainerPath());
        assertEquals(1, conditionResponse3.getRowCount().intValue());

        //setting of enddatefinalized, datefinalized
        SelectRowsCommand assignmentSelect2 = new SelectRowsCommand("study", "assignment");
        assignmentSelect2.addFilter(new Filter("Id", SUBJECTS[1]));
        assignmentSelect2.addFilter(new Filter("project", projectId));
        assignmentSelect2.setColumns(Arrays.asList("Id", "lsid", "datefinalized", "enddatefinalized"));
        SelectRowsResponse assignmentResponse2 = assignmentSelect2.execute(getApiHelper().getConnection(), getContainerPath());
        Assert.assertNotNull(assignmentResponse2.getRows().get(0).get("datefinalized"));
        Assert.assertNotNull(assignmentResponse2.getRows().get(0).get("enddatefinalized"));

        // insert second animal, should succeed
        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "assignment", new String[]{"Id", "date", "enddate", "project", "_recordId"}, new Object[][]{
                {SUBJECTS[3], prepareDate(new Date(), 10, 0), null, projectId, "recordID"}
        }, Collections.emptyMap());

        // try 2, should fail
        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "assignment", new String[]{"Id", "date", "enddate", "project", "_recordId"}, new Object[][]{
                {SUBJECTS[3], prepareDate(new Date(), 10, 0), null, projectId, "recordID"},
                {SUBJECTS[4], prepareDate(new Date(), 10, 0), null, projectId, "recordID"}
        }, Maps.of(
                "project", Arrays.asList(
                        "INFO: There are not enough spaces on protocol: " + protocolId + ". Allowed: 2, used: 3"
                )
        ));

        // add assignmentsInTransaction, should fail
        Map<String, Object> additionalExtraContext = new HashMap<>();
        JSONArray assignmentsInTransaction = new JSONArray();
        assignmentsInTransaction.put(Maps.of(
                "Id", SUBJECTS[4],
                "objectid", generateGUID(),
                "date", _df.format(new Date()),
                "enddate", null,
                "project", projectId
        ));
        additionalExtraContext.put("assignmentsInTransaction", assignmentsInTransaction.toString());

        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "assignment", new String[]{"Id", "date", "enddate", "project", "_recordId"}, new Object[][]{
                {SUBJECTS[3], prepareDate(new Date(), 10, 0), null, projectId, "recordID"}
        }, Maps.of(
                "project", Arrays.asList(
                        "INFO: There are not enough spaces on protocol: " + protocolId + ". Allowed: 2, used: 3"
                )
        ), additionalExtraContext);
    }

    @Test
    public void testAnimalGroupsApi() throws Exception
    {
        goToProjectHome();

        int group1 = getOrCreateGroup("Group1");
        int group2 = getOrCreateGroup("Group2");

        ensureGroupMember(group1, MORE_ANIMAL_IDS[2]);

        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "animal_group_members", new String[]{"Id", "date", "groupId", "_recordId"}, new Object[][]{
                {MORE_ANIMAL_IDS[2], new Date(), group2, "recordID"}
        }, Maps.of(
                "groupId", Arrays.asList(
                        "INFO: Actively assigned to other groups: Group1"
                )
        ));
    }

    @Test
    public void testProjectProtocolApi() throws Exception
    {
        goToProjectHome();

        //auto-assignment of IDs
        String protocolTitle = generateGUID();
        InsertRowsCommand protocolCommand = new InsertRowsCommand("ehr", "protocol");
        protocolCommand.addRow(Maps.of("protocol", null, "title", protocolTitle));
        protocolCommand.execute(getApiHelper().getConnection(), getContainerPath());

        SelectRowsCommand protocolSelect = new SelectRowsCommand("ehr", "protocol");
        protocolSelect.addFilter(new Filter("title", protocolTitle));
        String protocolId = (String)protocolSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("protocol");
        Assert.assertNotNull(StringUtils.trimToNull(protocolId));

        InsertRowsCommand projectCommand = new InsertRowsCommand("ehr", "project");
        String projectName = generateGUID();
        projectCommand.addRow(Maps.of("project", null, "name", projectName, "protocol", protocolId));
        projectCommand.execute(getApiHelper().getConnection(), getContainerPath());

        SelectRowsCommand projectSelect = new SelectRowsCommand("ehr", "project");
        projectSelect.addFilter(new Filter("protocol", protocolId));
        Integer projectId = (Integer)projectSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("project");
        Assert.assertNotNull(projectId);

        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "ehr", "project", new String[]{"project", "name"}, new Object[][]{
                {null, projectName}
        }, Maps.of(
                "name", Arrays.asList(
                        "ERROR: There is already an old project with the name in ehr: " + projectName
                )
        ));
    }

    @Test
    public void testDrugApi()
    {
        goToProjectHome();

        getApiHelper().testValidationMessage(DATA_ADMIN.getEmail(), "study", "drug", new String[]{"Id", "date", "code", "outcome", "remark", "amount", "amount_units", "volume", "vol_units", "QCStateLabel", "objectid", "_recordId"}, new Object[][]{
                {MORE_ANIMAL_IDS[0], new Date(), "code", "Abnormal", null, 1.0, "mg", 2.0, "mL", EHRQCState.COMPLETED.label, generateGUID(), "recordID"}
        }, Maps.of(
                "remark", Arrays.asList(
                    "WARN: A remark is required if a non-normal outcome is reported"
                )
        ));

        // successful
        getApiHelper().testValidationMessage(DATA_ADMIN.getEmail(), "study", "drug", new String[]{"Id", "date", "code", "outcome", "remark", "amount", "amount_units", "volume", "vol_units", "QCStateLabel", "objectid", "_recordId"}, new Object[][]{
                {MORE_ANIMAL_IDS[0], new Date(), "code", "Normal", null, 1.0, "mg", 2.0, "mL", EHRQCState.COMPLETED.label, generateGUID(), "recordID"}
        }, Collections.emptyMap());


        getApiHelper().testValidationMessage(DATA_ADMIN.getEmail(), "study", "drug", new String[]{"Id", "date", "code", "outcome", "remark", "amount", "amount_units", "volume", "vol_units", "QCStateLabel", "objectid", "_recordId"}, new Object[][]{
                {MORE_ANIMAL_IDS[0], new Date(), null, "Normal", null, 1.0, "mg", 2.0, "mL", EHRQCState.COMPLETED.label, generateGUID(), "recordID"}
        }, Maps.of(
                "code", Arrays.asList(
                        "WARN: Must enter a treatment"
                )
        ));

        //Added more validation code, Kollil Dec, 2023
        getApiHelper().testValidationMessage(DATA_ADMIN.getEmail(), "study", "drug", new String[]{"Id", "date", "code", "outcome", "remark", "amount", "amount_units", "volume", "vol_units", "QCStateLabel", "objectid", "_recordId"}, new Object[][]{
                {MORE_ANIMAL_IDS[0], new Date(), "code", "Normal", null, 1.0, null, 2.0, null, EHRQCState.COMPLETED.label, generateGUID(), "recordID"}
        }, Maps.of(
                "amount_units", Arrays.asList( //added these fields by kollil, Nov 30th
                        "WARN: Must enter Amount Units if Amount is entered"
                ),
                "vol_units", Arrays.asList(
                        "WARN: Must enter Vol Units if Volume is entered"
                )
        ));

        getApiHelper().testValidationMessage(DATA_ADMIN.getEmail(), "study", "drug", new String[]{"Id", "date", "code", "outcome", "remark", "amount", "volume", "QCStateLabel", "objectid", "_recordId"}, new Object[][]{
                {MORE_ANIMAL_IDS[0], new Date(), "code", "Normal", null, null, null, EHRQCState.COMPLETED.label, generateGUID(), "recordID"}
        }, Maps.of(
                "amount", Arrays.asList(
                        "WARN: Must enter an amount or volume"
                ),
                "volume", Arrays.asList(
                        "WARN: Must enter an amount or volume"
                )
        ));

        // ketamine / telazol
        for (String code : Arrays.asList("E-70590", "E-YY928"))
        {
            getApiHelper().testValidationMessage(DATA_ADMIN.getEmail(), "study", "drug", new String[]{"Id", "date", "code", "outcome", "remark", "amount", "amount_units", "volume", "vol_units", "QCStateLabel", "objectid", "_recordId"}, new Object[][]{
                    {MORE_ANIMAL_IDS[0], new Date(), code, "Normal", null, 1.0, "mL", 2.0, "mL", EHRQCState.COMPLETED.label, generateGUID(), "recordID"}
            }, Maps.of(
                    "amount_units", Arrays.asList(
                            "WARN: When entering ketamine or telazol, amount must be in mg"
                    )
            ));

            getApiHelper().testValidationMessage(DATA_ADMIN.getEmail(), "study", "drug", new String[]{"Id", "date", "code", "outcome", "remark", "amount", "amount_units", "volume", "vol_units", "QCStateLabel", "objectid", "_recordId"}, new Object[][]{
                    {MORE_ANIMAL_IDS[0], new Date(), code, "Normal", null, null, "mg", 2.0, "mL", EHRQCState.COMPLETED.label, generateGUID(), "recordID"}
            }, Maps.of(
                    "amount_units", Arrays.asList(
                            "WARN: When entering ketamine or telazol, amount must be in mg"
                    )
            ));
        }
    }

    @Test
    public void testArrivalApi() throws Exception
    {
        goToProjectHome();

        final String arrivalId1 = "Arrival1";
        final String arrivalId2 = "Arrival2";
        final String arrivalId3 = "Arrival3";

        log("deleting existing records");
        cleanRecords(arrivalId1, arrivalId2, arrivalId3);
        String quarrantineFlagId = ensureFlagExists("Surveillance", "Quarantine", null);
        String nonRestrictedFlagId = ensureFlagExists("Condition", "Nonrestricted", null);

        log("Get AcquistionType rowid");
        SelectRowsCommand acquisitionTypeCmd = new SelectRowsCommand("ehr_lookups", "AcquistionType");
        acquisitionTypeCmd.setColumns(Arrays.asList("rowid", "value"));
        acquisitionTypeCmd.addFilter(new Filter("value", "Acquired"));
        Map<String, Object> acquisitionTypeResult= acquisitionTypeCmd.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0);
        Integer acqType = (Integer) acquisitionTypeResult.get("rowid");

        //insert into arrival
        log("Creating Ids");
        Date birth = new Date();
        Date arrivalDate = prepareDate(new Date(), -3, 0);
        getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), getApiHelper().prepareInsertCommand("study", "arrival", "lsid",
                new String[]{"Id", "Date", "gender", "species", "geographic_origin", "birth", "initialRoom", "initialCage", "QCStateLabel", "acquisitionType"},
                new Object[][]{
                        {arrivalId1, arrivalDate, "f", RHESUS, INDIAN, birth, ROOMS[0], CAGES[0], EHRQCState.COMPLETED.label, acqType}
                }
        ), getExtraContext());

        //expect to fail because of birth date
        Date incorrectBirth = DateUtils.addDays(birth, -4);
        getApiHelper().doSaveRowsExpectingError(DATA_ADMIN.getEmail(), getApiHelper().prepareInsertCommand("study", "arrival", "lsid",
                new String[]{"Id", "Date", "gender", "species", "geographic_origin", "birth", "initialRoom", "initialCage", "QCStateLabel"},
                new Object[][]{
                        {arrivalId1, arrivalDate, "f", RHESUS, INDIAN, incorrectBirth, ROOMS[0], CAGES[0], EHRQCState.COMPLETED.label}
                }
        ), getExtraContext());

        //expect to find demographics record.
        assertTrue("demographics row was not created for arrival", getApiHelper().doesRowExist("study", "demographics", new Filter("Id", arrivalId1, Filter.Operator.EQUAL)));

        //and birth
        SelectRowsCommand birthSelect = new SelectRowsCommand("study", "birth");
        birthSelect.addFilter(new Filter("Id", arrivalId1));
        birthSelect.addFilter(new Filter("date", birth, Filter.Operator.DATE_EQUAL));
        birthSelect.addFilter(new Filter("arrival_date", arrivalDate, Filter.Operator.DATE_EQUAL));
        Assert.assertEquals(1, birthSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());

        //validation of housing
        SelectRowsCommand housingSelect = new SelectRowsCommand("study", "housing");
        housingSelect.addFilter(new Filter("Id", arrivalId1));
        housingSelect.addFilter(new Filter("room", ROOMS[0]));
        housingSelect.addFilter(new Filter("cage", CAGES[0]));
        housingSelect.addFilter(new Filter("date", arrivalDate, Filter.Operator.DATE_EQUAL));
        housingSelect.addFilter(new Filter("enddate", null, Filter.Operator.ISBLANK));
        Assert.assertEquals(1, housingSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());

        //and quarantine flag
        SelectRowsCommand flagSelect = new SelectRowsCommand("study", "flags");
        flagSelect.addFilter(new Filter("Id", arrivalId1));
        flagSelect.addFilter(new Filter("flag", quarrantineFlagId));
        flagSelect.addFilter(new Filter("date", arrivalDate, Filter.Operator.DATE_EQUAL));
        flagSelect.addFilter(new Filter("enddate", null, Filter.Operator.ISBLANK));
        Assert.assertEquals(1, flagSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());

        //and nonrestricted flag.  added by birth triggers, should reflect arrival date not birthdate
        SelectRowsCommand flagSelect2 = new SelectRowsCommand("study", "flags");
        flagSelect2.addFilter(new Filter("Id", arrivalId1));
        flagSelect2.addFilter(new Filter("flag", nonRestrictedFlagId));
        flagSelect2.addFilter(new Filter("date", arrivalDate, Filter.Operator.DATE_EQUAL));
        flagSelect2.addFilter(new Filter("enddate", null, Filter.Operator.ISBLANK));
        Assert.assertEquals(1, flagSelect2.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());

        //demographics status
        SelectRowsCommand demographicsSelect = new SelectRowsCommand("study", "demographics");
        demographicsSelect.addFilter(new Filter("Id", arrivalId1));
        demographicsSelect.addFilter(new Filter("Id", arrivalId1));
        demographicsSelect.addFilter(new Filter("calculated_status", "Alive"));
        demographicsSelect.addFilter(new Filter("gender", "f"));
        demographicsSelect.addFilter(new Filter("species", RHESUS));
        demographicsSelect.addFilter(new Filter("geographic_origin", INDIAN));
        Assert.assertEquals(1, demographicsSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
    }

    @Test
    public void testCustomActions() throws Exception
    {
        // make sure we have age class records for these species
        // NOTE: consider populating species table in populateData.html, and switching this test to use ONPRC-style names (ie. RHESUS MACAQUE vs. Rhesus).
        // if doing this, we'd also want to make populateInitialData.html (the core version) populate the wnprc-style names.
        for (String species : new String[]{"Rhesus", "Cynomolgus", "Marmoset"})
        {
            SelectRowsCommand sr1 = new SelectRowsCommand("ehr_lookups", "ageclass");
            sr1.addFilter(new Filter("species", species));
            sr1.addFilter(new Filter("gender", null, Filter.Operator.ISBLANK));
            sr1.addFilter(new Filter("min", 0));

            SelectRowsResponse srr1 = sr1.execute(getApiHelper().getConnection(), getContainerPath());
            if (srr1.getRowCount().intValue() == 0)
            {
                log("creating ehr.ageclass record for: " + species);
                InsertRowsCommand ir1 = new InsertRowsCommand("ehr_lookups", "ageclass");
                ir1.addRow(Maps.of("species", species, "min", 0, "max", 1, "label", "Infant"));
                ir1.execute(getApiHelper().getConnection(), getContainerPath());
            }
        }

        //colony overview
        goToProjectHome();
        waitAndClickAndWait(Locator.tagContainingText("a", "Colony Overview"));

        //NOTE: depending on the test order and whether demographics records were created, so we test this
        EHRClientAPIHelper apiHelper = new EHRClientAPIHelper(this, getProjectName());
        boolean hasDemographics = apiHelper.getRowCount("study", "demographics") > 0;
        boolean hasCases = apiHelper.getRowCount("study", "cases") > 0;
        int aggregatePanelCount = 0;

        if (hasDemographics)
        {
            waitForElement(Locators.panelWebpartTitle.withText("Current Population"), WAIT_FOR_JAVASCRIPT);
            waitForElement(Locator.tagWithClass("div", "ehr-populationpanel-table"), WAIT_FOR_JAVASCRIPT * 3);
        }
        else
        {
            waitForElement(Locator.tagContainingText("div", "No animals were found"), WAIT_FOR_JAVASCRIPT);
        }

        waitAndClick(Locator.tagContainingText("a", "SPF Colony"));
        waitForElement(Locators.panelWebpartTitle.withText("SPF 9 (ESPF)"), WAIT_FOR_JAVASCRIPT * 2);

        waitAndClick(Locator.tagContainingText("a", "Housing Summary"));
        waitForElement(Locator.tagContainingText("div", "No buildings were found"), WAIT_FOR_JAVASCRIPT * 2);

        waitAndClick(Locator.tagContainingText("a", "Utilization Summary"));
        if (hasDemographics)
        {
            waitForElement(Locators.panelWebpartTitle.withText("Colony Utilization"), WAIT_FOR_JAVASCRIPT);
            aggregatePanelCount += 2;
            waitForElements(Locator.tagWithClass("div", "ehr-aggregationpanel-table"), aggregatePanelCount, WAIT_FOR_JAVASCRIPT);
        }
        else
        {
            waitForElement(Locator.tagContainingText("div", "No records found"), WAIT_FOR_JAVASCRIPT * 2);
        }

        waitAndClick(Locator.tagContainingText("a", "Clinical Case Summary"));
        if (hasCases)
        {
            waitForElement(Locator.tagContainingText("h4", "Open Cases:"), WAIT_FOR_JAVASCRIPT * 2);
            aggregatePanelCount += 1;
            waitForElements(Locator.tagWithClass("div", "ehr-aggregationpanel-table"), aggregatePanelCount, WAIT_FOR_JAVASCRIPT);
        }
        else
        {
            waitForElement(Locator.tagContainingText("div", "There are no open cases or problems"), WAIT_FOR_JAVASCRIPT * 2);
        }

        //bulk history export
        log("testing bulk history export");
        goToProjectHome();
        waitAndClickAndWait(Locator.tagContainingText("a", "Bulk History Export"));
        waitForElement(Locator.tagContainingText("label", "Enter Animal Id(s)"));
        Ext4FieldRef.getForLabel(this, "Enter Animal Id(s)").setValue("12345;23432\nABCDE");
        Ext4FieldRef.getForLabel(this, "Show Snapshot Only").setValue(true);
        Ext4FieldRef.getForLabel(this, "Redact Information").setValue(true);
        clickAndWait(Ext4Helper.Locators.ext4Button("Submit"));
        assertElementPresent(Locator.tagContainingText("b", "12345"));
        assertElementPresent(Locator.tagContainingText("b", "23432"));
        assertElementPresent(Locator.tagContainingText("b", "ABCDE"));
        assertElementNotPresent(Locator.tagContainingText("b", "Chronological History").notHidden()); //check hide history
        assertElementNotPresent(Locator.tagContainingText("label", "Projects").notHidden()); //check redaction

        //compare lists of animals
        goToProjectHome();
        waitAndClickAndWait(Locator.tagContainingText("a", "Compare Lists of Animals"));
        waitForElement(Locator.id("unique"));
        setFormElement(Locator.id("unique"), "1,2,1\n3,3;4");
        click(Locator.id("uniqueButton"));
        waitForElement(Locator.id("uniqueInputTotal").withText("6 total"));
        assertElementPresent(Locator.id("uniqueTargetTotal").withText("4 total"));
        Assert.assertEquals("Incorrect text", "1\n2\n3\n4", getDriver().findElement(Locator.id("uniqueTarget")).getAttribute("value"));

        setFormElement(Locator.id("subtract1"), "1,2,1\n3,3;4");
        setFormElement(Locator.id("subtract2"), "1,4;23 48");
        click(Locator.id("compareButton"));
        waitForElement(Locator.id("subtractList1Total").withText("6 total"));
        assertElementPresent(Locator.id("subtractList2Total").withText("4 total"));

        assertElementPresent(Locator.id("intersectTargetTotal").withText("2 total"));
        Assert.assertEquals("Incorrect text", "1\n4", getDriver().findElement(Locator.id("intersectTarget")).getAttribute("value"));

        assertElementPresent(Locator.id("subtractTargetTotal").withText("3 total"));
        Assert.assertEquals("Incorrect text", "2\n3\n3", getDriver().findElement(Locator.id("subtractTarget")).getAttribute("value"));

        assertElementPresent(Locator.id("subtractTargetTotal2").withText("2 total"));
        Assert.assertEquals("Incorrect text", "23\n48", getDriver().findElement(Locator.id("subtractTarget2")).getAttribute("value"));

        //animal groups
        String groupName = "A TestGroup";
        int groupId = getOrCreateGroup(groupName);
        ensureGroupMember(groupId, MORE_ANIMAL_IDS[0]);
        ensureGroupMember(groupId, MORE_ANIMAL_IDS[1]);

        goToProjectHome();
        waitAndClickAndWait(Locator.tagContainingText("a", "Animal Groups"));
        waitForElement(Locator.tagContainingText("span", "Active Groups"));
        DataRegionTable dr = new DataRegionTable("query", this);
        clickAndWait(dr.link(0, dr.getColumnIndex("Name")));
        DataRegionTable membersTable = DataRegionTable.DataRegion(getDriver()).find(new BodyWebPart(this.getDriver(), "Group Members", 0));
        Assert.assertEquals(2, membersTable.getDataRowCount());

        //more reports
        goToProjectHome();
        waitAndClickAndWait(Locator.tagContainingText("a", "More Reports"));
        waitForElement(Locator.tagContainingText("a", "View Summary of Clinical Tasks"));
    }

    @Test
    public void testPrintableReports()
    {
        // NOTE: these primarily run SSRS, so we will just setup the UI and test whether the URL matches expectations
        goToProjectHome();
        waitAndClickAndWait(Locator.tagContainingText("a", "Printable Reports"));
        waitForElement(Ext4Helper.Locators.ext4Button("Print Version"));

        //TODO: test JSESSIONID
    }

    @Test
    public void testPedigreeReport() throws Exception
    {
        goToProjectHome();
        beginAtAnimalHistoryTab();

        String id = ID_PREFIX + 10;
        AnimalHistoryPage animalHistoryPage = new AnimalHistoryPage(getDriver());

        animalHistoryPage.searchSingleAnimal(id);
        animalHistoryPage.clickCategoryTab("Genetics");
        animalHistoryPage.clickReportTab("Pedigree Plot");

        waitForElement(Locator.tagContainingText("span", "Pedigree Plot - " + id), WAIT_FOR_JAVASCRIPT * 3);
        assertTextNotPresent("Error executing command");
        assertTrue(isTextPresent("Console output"));
    }

    @Test
    public void testLabworkResultEntry() throws Exception
    {
        _helper.goToTaskForm("Lab Results");
        _helper.getExt4FieldForFormSection("Task", "Title").setValue("Test Task 1");

        Ext4GridRef panelGrid = _helper.getExt4GridForFormSection("Panels / Services");

        //panel, tissue, type
        String[][] panels = new String[][]{
                {"BASIC Chemistry Panel in-house", "T-0X500", "Biochemistry", "chemistry_tests"},
                {"Anaerobic Culture", null, "Microbiology", null, "T-0X000"},  //NOTE: cultures dont have a default tissue, so we set it using value
                {"CBC with automated differential", "T-0X000", "Hematology", "hematology_tests"},
                {"Antibiotic Sensitivity", null, "Antibiotic Sensitivity", null, "T-0X000"},
                {"Fecal parasite exam", "T-6Y100", "Parasitology", null},
                {"ESPF Surveillance - Monthly", "T-0X500", "Serology/Virology", null},
                {"Urinalysis", "T-7X100", "Urinalysis", "urinalysis_tests"},
                {"Occult Blood", "T-6Y100", "Misc Tests", "misc_tests"}
        };

        int panelIdx = 1;
        for (String[] arr : panels)
        {
            Ext4GridRef panelGrid2 = _helper.getExt4GridForFormSection("Panels / Services");
            Assert.assertEquals(panelGrid.getId(), panelGrid2.getId());

            _helper.addRecordToGrid(panelGrid);
            panelGrid.setGridCell(panelIdx, "Id", MORE_ANIMAL_IDS[(panelIdx % MORE_ANIMAL_IDS.length)]);
            panelGrid.setGridCellJS(panelIdx, "servicerequested", arr[0]);

            if (arr[1] != null && arr.length == 4)
            {
                Assert.assertEquals("Tissue not set properly", arr[1], panelGrid.getFieldValue(panelIdx, "tissue"));
            }
            else if (arr.length > 4)
            {
                //for some panels, tissue will not have a default.  therefore we set one and verify it gets copied into the results downstream
                panelGrid.setGridCellJS(panelIdx, "tissue", arr[4]);
                arr[1] = arr[4];

                Assert.assertEquals("Tissue not set properly", arr[1], panelGrid.getFieldValue(panelIdx, "tissue"));
            }

            Assert.assertEquals("Category not set properly", arr[2], panelGrid.getFieldValue(panelIdx, "type"));

            validatePanelEntry(arr[0], arr[1], arr[2], arr[3], panelIdx == panels.length, panelIdx);

            panelIdx++;
        }


        _helper.discardForm();
    }

    @LogMethod
    public void validatePanelEntry(String panelName, String tissue, String title, String lookupTable, boolean doDeletePanel, int panelRowIdx) throws Exception
    {
        SelectRowsCommand cmd = new SelectRowsCommand("ehr_lookups", "labwork_panels");
        cmd.addFilter(new Filter("servicename", panelName));
        cmd.addSort(new Sort("sort_order"));
        SelectRowsResponse srr = cmd.execute(WebTestHelper.getRemoteApiConnection(), getContainerPath());
        List<Map<String, Object>> expectedRows = srr.getRows();

        waitAndClick(Ext4Helper.Locators.ext4Tab(title));
        Ext4GridRef grid = _helper.getExt4GridForFormSection(title);
        waitForElement(Locator.id(grid.getId()).notHidden());

        grid.clickTbarButton("Copy From Above");
        waitForElement(Ext4Helper.Locators.window("Copy From Above"));
        Ext4CmpRef submitBtn = _ext4Helper.queryOne("button[text='Submit']", Ext4CmpRef.class);
        submitBtn.waitForEnabled();
        click(Ext4Helper.Locators.ext4Button("Submit"));

        if (expectedRows.size() == 0)
        {
            grid.waitForRowCount(1);

            if (tissue != null && grid.isColumnPresent("tissue", true))
            {
                Assert.assertEquals("Tissue was not copied from runs action", tissue, grid.getFieldValue(1, "tissue"));
            }
        }
        else
        {
            grid.waitForRowCount(expectedRows.size());

            int rowIdx = 1;  //1-based
            String testFieldName = null;
            for (Map<String, Object> row : expectedRows)
            {
                testFieldName = (String)row.get("testfieldname");
                String testname = (String)row.get("testname");
                Assert.assertEquals("Wrong testId", testname, grid.getFieldValue(rowIdx, testFieldName));

                String method = (String)row.get("method");
                if (method != null)
                {
                    Assert.assertEquals("Wrong method", method, grid.getFieldValue(rowIdx, "method"));
                }

                if (lookupTable != null)
                {
                    String units = getUnits(lookupTable, testname);
                    if (units != null)
                    {
                        Assert.assertEquals("Wrong units for test: " + testname, units, grid.getFieldValue(rowIdx, "units"));
                    }
                }

                rowIdx++;
            }

            //iterate rows, checking keyboard navigation
            if (testFieldName != null)
            {
                Integer rowCount = grid.getRowCount();

                //TODO: test keyboard navigation
                //grid.startEditing(1, grid.getIndexOfColumn(testFieldName));

                // click through each testId and make sure the value persists.
                // this might not occur if the lookup is invalid
                for (int j = 1; j <= rowCount; j++)
                {
                    log("testing row: " + j);
                    Object origVal = grid.getFieldValue(j, testFieldName);

                    grid.startEditing(j, testFieldName);
                    sleep(50);
                    grid.completeEdit();

                    Object newVal = grid.getFieldValue(j, testFieldName);
                    Assert.assertEquals("Test Id value did not match after key navigation", origVal, newVal);
                }

                //test cascade update + delete
                Ext4GridRef panelGrid = _helper.getExt4GridForFormSection("Panels / Services");
                panelGrid.setGridCell(panelRowIdx, "Id", MORE_ANIMAL_IDS[0]);
                for (int j = 1; j <= rowCount; j++)
                {
                    Assert.assertEquals(MORE_ANIMAL_IDS[0], grid.getFieldValue(j, "Id"));
                }

                if (doDeletePanel)
                {
                    waitAndClick(panelGrid.getRow(panelRowIdx));
                    panelGrid.clickTbarButton("Delete Selected");
                    waitForElement(Ext4Helper.Locators.window("Confirm"));
                    assertTextPresent("along with the " + rowCount + " results associated with them");
                    waitAndClick(Ext4Helper.Locators.window("Confirm").append(Ext4Helper.Locators.ext4Button("Yes")));
                }
                else
                {
                    grid.clickTbarButton("Select All");
                    grid.waitForSelected(grid.getRowCount());
                    grid.clickTbarButton("Delete Selected");
                    waitForElement(Ext4Helper.Locators.window("Confirm"));
                    waitAndClick(Ext4Helper.Locators.ext4Button("Yes"));
                }

                grid.waitForRowCount(0);
                sleep(200);
            }
        }
    }

    private final Map<String, Map<String, String>> _unitsMap = new HashMap<>();

    private String getUnits(String queryName, String testId) throws Exception
    {
        if (_unitsMap.containsKey(queryName))
        {
            return _unitsMap.get(queryName).get(testId);
        }

        Map<String, String> queryResults = new HashMap<>();
        SelectRowsCommand cmd = new SelectRowsCommand("ehr_lookups", queryName);
        SelectRowsResponse srr = cmd.execute(WebTestHelper.getRemoteApiConnection(), getContainerPath());
        for (Map<String, Object> row : srr.getRows())
        {
            if (row.get("units") != null)
                queryResults.put((String)row.get("testid"), (String)row.get("units"));
        }

        _unitsMap.put(queryName, queryResults);

        return _unitsMap.get(queryName).get(testId);
    }

    @Test
    public void testExamEntry() throws Exception
    {
        _helper.goToTaskForm("Exams/Cases", false);
        _helper.getExt4FieldForFormSection("Task", "Title").setValue("Test Exam 1");

        waitAndClick(_helper.getDataEntryButton("More Actions"));
        click(Ext4Helper.Locators.menuItem("Apply Form Template"));
        waitForElement(Ext4Helper.Locators.window("Apply Template To Form"));
        waitForTextToDisappear("Loading...");
        String templateName1 = "Bone Marrow Biopsy";
        String templateName2 = "Achilles Tendon Repair";
        waitForElement(Ext4Helper.Locators.window("Apply Template To Form").append(Locator.tagContainingText("label", "Choose Template")));
        Ext4ComboRef templateCombo = Ext4ComboRef.getForLabel(this, "Choose Template");
        templateCombo.waitForStoreLoad();
        _ext4Helper.selectComboBoxItem("Choose Template:", Ext4Helper.TextMatchTechnique.CONTAINS, templateName1);
        _ext4Helper.selectComboBoxItem("Choose Template:", Ext4Helper.TextMatchTechnique.CONTAINS, templateName2);

        //these should not be shown
        Assert.assertFalse(Ext4FieldRef.isFieldPresent(this, "Task:"));
        Assert.assertFalse(Ext4FieldRef.isFieldPresent(this, "Animal Details"));

        Ext4ComboRef combo = Ext4ComboRef.getForLabel(this, "SOAP");
        if (!templateName2.equals(combo.getDisplayValue()))
        {
            log("combo value not set initially, retrying");
            combo.setComboByDisplayValue(templateName2);
        }
        sleep(100); //allow field to cascade

        Assert.assertEquals("Section template not set", templateName2, Ext4ComboRef.getForLabel(this, "SOAP").getDisplayValue());
        Assert.assertEquals("Section template not set", "Vitals", Ext4ComboRef.getForLabel(this, "Observations").getDisplayValue());
        String obsTemplate = (String) Ext4ComboRef.getForLabel(this, "Observations").getValue();

        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElementToDisappear(Ext4Helper.Locators.window("Apply Template To Form"));
        waitFor(() -> "BAR prior to sedation.".equals(_helper.getExt4FieldForFormSection("SOAP", "Subjective").getValue()),
                "Subjective field not set", WAIT_FOR_JAVASCRIPT);

        sleep(100);

        //this is a proxy the 1st record validation happening
        waitForElement(Locator.tagWithText("div", "The form has the following errors and warnings:"));
        sleep(200);
        setFormElement(Locator.input("Id"), MORE_ANIMAL_IDS[0]);

        // NOTE: we have had problems w/ the ID field value not sticking.  i think it might have to do with the timing of server-side validation,
        //
        WebElement idDisplay = Locator.tag("div").withLabel("Id:").findElement(getDriver());
        waitFor(() -> MORE_ANIMAL_IDS[0].equals(idDisplay.getText()), () -> "Id field not set: " + idDisplay.getText(), 5_000);

        //observations section
        waitAndClick(Ext4Helper.Locators.ext4Tab("Observations"));
        Ext4GridRef observationsGrid = _helper.getExt4GridForFormSection("Observations");
        SelectRowsCommand cmd = new SelectRowsCommand("ehr", "formtemplaterecords");
        cmd.addFilter(new Filter("templateid", obsTemplate));
        cmd.addSort(new Sort("rowid"));
        SelectRowsResponse srr = cmd.execute(WebTestHelper.getRemoteApiConnection(), getContainerPath());

        int expectedObsRows = srr.getRowCount().intValue();
        observationsGrid.waitForRowCount(expectedObsRows);
        Assert.assertEquals("Incorrect row count", expectedObsRows, observationsGrid.getRowCount());
        for (int i=0;i<expectedObsRows;i++)
        {
            Assert.assertEquals("Id not copied properly", MORE_ANIMAL_IDS[0], observationsGrid.getFieldValue(1 + i, "Id"));

            Assert.assertEquals("formSort not set properly on row: " + i, Long.valueOf(i + 1), observationsGrid.getFnEval("return this.store.getAt(arguments[0]).get('formSort');", i));
        }

        int i = 1;
        for (Map<String, Object> row : srr.getRows())
        {
            JSONObject json = new JSONObject((String)row.get("json"));
            Assert.assertEquals(json.getString("category"), observationsGrid.getFieldValue(i, "category"));
            i++;
        }

        //weight section
        waitAndClick(Ext4Helper.Locators.ext4Tab("Weights"));
        Ext4GridRef weightGrid = _helper.getExt4GridForFormSection("Weights");
        Assert.assertEquals("Incorrect row count", 0, weightGrid.getRowCount());
        _helper.addRecordToGrid(weightGrid);
        Assert.assertEquals("Id not copied property", MORE_ANIMAL_IDS[0], weightGrid.getFieldValue(1, "Id"));
        Double weight = 5.3;
        weightGrid.setGridCell(1, "weight", weight.toString());

        //procedures section
        waitAndClick(Ext4Helper.Locators.ext4Tab("Procedures"));
        Ext4GridRef proceduresGrid = _helper.getExt4GridForFormSection("Procedures");
        Assert.assertEquals("Incorrect row count", 0, proceduresGrid.getRowCount());
        _helper.addRecordToGrid(proceduresGrid);
        Assert.assertEquals("Id not copied property", MORE_ANIMAL_IDS[0], proceduresGrid.getFieldValue(1, "Id"));

        //medications section
        waitAndClick(Ext4Helper.Locators.ext4Tab("Medications"));
        Ext4GridRef drugGrid = _helper.getExt4GridForFormSection("Medications/Treatments Given");
        Assert.assertEquals("Incorrect row count", 7, drugGrid.getRowCount());

        Assert.assertEquals(drugGrid.getFieldValue(1, "code"), "E-721X0");
        Assert.assertEquals(drugGrid.getFieldValue(1, "route"), "IM");
        Assert.assertEquals(drugGrid.getFieldValue(1, "dosage"), 25L);

        //verify formulary used
        drugGrid.setGridCellJS(1, "code", "E-YY035");
        Assert.assertEquals("Formulary not applied", "PO", drugGrid.getFieldValue(1, "route"));
        Assert.assertEquals("Formulary not applied", 8L, drugGrid.getFieldValue(1, "dosage"));
        Assert.assertEquals("Formulary not applied", "mg", drugGrid.getFieldValue(1, "amount_units"));

        Ext4GridRef ordersGrid = _helper.getExt4GridForFormSection("Medication/Treatment Orders");
        Assert.assertEquals("Incorrect row count", 3, ordersGrid.getRowCount());
        Assert.assertEquals("E-YY732", ordersGrid.getFieldValue(3, "code"));   //tramadol
        Assert.assertEquals("PO", ordersGrid.getFieldValue(3, "route"));
        Assert.assertEquals(50L, ordersGrid.getFieldValue(3, "concentration"));
        Assert.assertEquals("mg/tablet", ordersGrid.getFieldValue(3, "conc_units"));
        Assert.assertEquals(3L, ordersGrid.getFieldValue(3, "dosage"));
        Assert.assertEquals("mg/kg", ordersGrid.getFieldValue(3, "dosage_units"));

        //note: amount calculation testing handled in surgery test

        //blood draws
        waitAndClick(Ext4Helper.Locators.ext4Tab("Blood Draws"));
        Ext4GridRef bloodGrid = _helper.getExt4GridForFormSection("Blood Draws");
        Assert.assertEquals("Incorrect row count", 0, bloodGrid.getRowCount());
        bloodGrid.clickTbarButton("Templates");
        waitAndClick(Ext4Helper.Locators.menuItem("Apply Template").notHidden());
        waitForElement(Ext4Helper.Locators.window("Apply Template"));
        waitAndClick(Ext4Helper.Locators.ext4Button("Close"));

        Date date = DateUtils.truncate(new Date(), Calendar.DATE);
        Date date2 = DateUtils.addDays(date, 1);

        _helper.applyTemplate(bloodGrid, "CBC and Chem", false, date);
        bloodGrid.waitForRowCount(2);

        _helper.applyTemplate(bloodGrid, "CBC and Chem", true, date2);
        _helper.toggleBulkEditField("Remark");
        String remark = "The Remark";
        Ext4FieldRef.getForLabel(this, "Remark").setValue(remark);
        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        bloodGrid.waitForRowCount(4);

        Assert.assertEquals(bloodGrid.getDateFieldValue(1, "date"), date);
        Assert.assertEquals(bloodGrid.getDateFieldValue(2, "date"), date);
        Assert.assertEquals(bloodGrid.getDateFieldValue(3, "date"), date2);
        Assert.assertEquals(bloodGrid.getDateFieldValue(4, "date"), date2);

        Assert.assertEquals(bloodGrid.getFieldValue(3, "remark"), remark);
        Assert.assertEquals(bloodGrid.getFieldValue(4, "remark"), remark);

        waitAndClickAndWait(_helper.getDataEntryButton("Save & Close"));
        waitForElement(Locator.tagWithText("a", "Enter New Data"));
    }

    @Test
    public void testWeightEntry()
    {
        _helper.goToTaskForm("Weights");
        _helper.getExt4FieldForFormSection("Task", "Title").setValue("Test Weight 1");

        Ext4GridRef weightGrid = _helper.getExt4GridForFormSection("Weights");
        weightGrid.clickTbarButton("Add Batch");
        waitForElement(Ext4Helper.Locators.window("Choose Animals"));
        Ext4FieldRef.getForLabel(this, "Id(s)").setValue(StringUtils.join(MORE_ANIMAL_IDS, ";"));
        waitAndClick(Ext4Helper.Locators.window("Choose Animals").append(Ext4Helper.Locators.ext4Button("Submit")));
        Assert.assertEquals(weightGrid.getRowCount(), MORE_ANIMAL_IDS.length);

        weightGrid.clickTbarButton("Add Batch");
        waitForElement(Ext4Helper.Locators.window("Choose Animals"));
        Ext4FieldRef.getForLabel(this, "Id(s)").setValue(StringUtils.join(MORE_ANIMAL_IDS, ";"));
        Ext4FieldRef.getForLabel(this, "Bulk Edit Before Applying").setChecked(true);
        waitAndClick(Ext4Helper.Locators.window("Choose Animals").append(Ext4Helper.Locators.ext4Button("Submit")));
        waitForElement(Ext4Helper.Locators.window("Bulk Edit"));
        _helper.toggleBulkEditField("Weight (kg)");
        double weight = 4.0;
        Ext4FieldRef.getForLabel(this, "Weight (kg)").setValue(weight);
        waitAndClick(Ext4Helper.Locators.window("Bulk Edit").append(Ext4Helper.Locators.ext4Button("Submit")));
        Assert.assertEquals(weightGrid.getRowCount(), MORE_ANIMAL_IDS.length * 2);

        //verify IDs added in correct order
        for (int i=0;i<MORE_ANIMAL_IDS.length;i++)
        {
            Assert.assertEquals(weightGrid.getFieldValue(i + 1, "Id"), MORE_ANIMAL_IDS[i]);
            Assert.assertEquals(weightGrid.getFieldValue(MORE_ANIMAL_IDS.length + i + 1, "Id"), MORE_ANIMAL_IDS[i]);
        }

        Assert.assertEquals(weight, Double.parseDouble(weightGrid.getFieldValue(MORE_ANIMAL_IDS.length + 1, "weight").toString()), (weight / 10e6));

        //TB section
        Ext4GridRef tbGrid = _helper.getExt4GridForFormSection("TB Tests");
        tbGrid.clickTbarButton("Copy From Section");
        waitAndClick(Ext4Helper.Locators.menuItem("Weights"));
        waitForElement(Ext4Helper.Locators.window("Copy From Weights"));
        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        Assert.assertEquals(tbGrid.getRowCount(), MORE_ANIMAL_IDS.length);

        //sedations
        Ext4GridRef drugGrid = _helper.getExt4GridForFormSection("Medications/Treatments Given");
        drugGrid.clickTbarButton("Add Sedation(s)");
        waitAndClick(Ext4Helper.Locators.menuItem("Copy Ids From: Weights"));
        waitForElement(Ext4Helper.Locators.window("Add Sedations"));
        Ext4FieldRef.getForLabel(this, "Lot # (optional)").setValue("Lot");
        Ext4CmpRef.waitForComponent(this, "field[fieldName='weight']");
        waitForElement(Ext4Helper.Locators.window("Add Sedations").append(Locator.tagWithText("div", MORE_ANIMAL_IDS[4])));

        //set weights
        for (Ext4FieldRef field : _ext4Helper.componentQuery("field[fieldName='weight']", Ext4FieldRef.class))
        {
            field.setValue(4.1);
        }

        //verify dosage
        for (Ext4FieldRef field : _ext4Helper.componentQuery("field[fieldName='dosage']", Ext4FieldRef.class))
        {
            Assert.assertEquals((Object)10.0, field.getDoubleValue());
        }

        //verify amount
        for (Ext4FieldRef field : _ext4Helper.componentQuery("field[fieldName='amount']", Ext4FieldRef.class))
        {
            Assert.assertEquals((Object)40.0, field.getDoubleValue());
        }

        //modify rounding + dosage
        Ext4FieldRef dosageField = Ext4FieldRef.getForLabel(this, "Reset Dosage");
        dosageField.setValue(23);
        dosageField.eval("onTriggerClick()");
        for (Ext4FieldRef field : _ext4Helper.componentQuery("field[fieldName='dosage']", Ext4FieldRef.class))
        {
            Assert.assertEquals((Object)23.0, field.getDoubleValue());
        }

        for (Ext4FieldRef field : _ext4Helper.componentQuery("field[fieldName='amount']", Ext4FieldRef.class))
        {
            Assert.assertEquals((Object)95.0, field.getDoubleValue());
        }

        Ext4FieldRef roundingField = Ext4FieldRef.getForLabel(this, "Round To Nearest");
        roundingField.setValue(0.5);
        roundingField.eval("onTriggerClick()");
        for (Ext4FieldRef field : _ext4Helper.componentQuery("field[fieldName='amount']", Ext4FieldRef.class))
        {
            Assert.assertEquals(94.5, (Object)field.getDoubleValue());
        }

        //deselect the first row
        _ext4Helper.queryOne("field[fieldName='exclude']", Ext4FieldRef.class).setChecked(true);

        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));

        int expectedRecords = MORE_ANIMAL_IDS.length - 1;
        Assert.assertEquals(drugGrid.getRowCount(), expectedRecords);

        for (int i=0;i<expectedRecords;i++)
        {
            Assert.assertEquals(drugGrid.getFieldValue(i + 1, "lot"), "Lot");
            Assert.assertEquals(drugGrid.getFieldValue(i+1, "reason"), "Weight");
            Assert.assertEquals(drugGrid.getFieldValue(i + 1, "amount"), 94.5);
        }

        //TB section
        tbGrid.clickTbarButton("Copy From Section");
        waitAndClick(Ext4Helper.Locators.menuItem("Medications/Treatments Given"));
        waitForElement(Ext4Helper.Locators.window("Copy From Medications/Treatments Given"));
        for (Ext4FieldRef field : _ext4Helper.componentQuery("field[fieldName='exclude']", Ext4FieldRef.class))
        {
            Assert.assertEquals(field.getValue(), true);
        }

        //deselect the first row
        _ext4Helper.queryOne("field[fieldName='exclude']", Ext4FieldRef.class).setChecked(false);

        Ext4FieldRef.getForLabel(this, "Bulk Edit Before Applying").setChecked(true);
        waitAndClick(Ext4Helper.Locators.window("Copy From Medications/Treatments Given").append(Ext4Helper.Locators.ext4Button("Submit")));
        waitForElement(Ext4Helper.Locators.window("Bulk Edit"));
        _helper.toggleBulkEditField("Performed By");
        Ext4FieldRef.getForLabel(this, "Performed By").setValue("me");
        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElementToDisappear(Ext4Helper.Locators.window("Bulk Edit"));

        for (int i=1;i<=5;i++)
        {
            Assert.assertEquals(getDisplayName(), tbGrid.getFieldValue(i, "performedby"));
            i++;
        }
        Assert.assertEquals("me", tbGrid.getFieldValue(6, "performedby"));

        Assert.assertEquals(tbGrid.getRowCount(), MORE_ANIMAL_IDS.length + 1);

        _helper.discardForm();
    }

    @Test
    public void testGeneticsPipeline() throws Exception
    {
        goToProjectHome();

        //retain pipeline log for debugging
        getArtifactCollector().addArtifactLocation(new File(TestFileUtils.getLabKeyRoot(), getModulePath() + GENETICS_PIPELINE_LOG_PATH),
                pathname -> pathname.getName().endsWith(".log"));

        waitAndClickAndWait(Locators.bodyPanel().append(Locator.tagContainingText("a", "EHR Admin Page")));
        waitAndClickAndWait(Locator.tagContainingText("a", "Genetics Calculations"));
        _ext4Helper.checkCheckbox(Ext4Helper.Locators.checkbox(this, "Kinship validation?:"));
        _ext4Helper.checkCheckbox(Ext4Helper.Locators.checkbox(this, "Allow Import During Business Hours?:"));
        Locator loc = Locator.inputByIdContaining("numberfield");
        waitForElement(loc);
        setFormElement(loc, "23");
        click(Ext4Helper.Locators.ext4Button("Save Settings"));
        waitAndClick(Ext4Helper.Locators.ext4Button("OK"));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("Run Now"));
        waitAndClickAndWait(Locator.lkButton("OK"));
        waitForPipelineJobsToComplete(2, "genetics pipeline", false);

        /*
        Test coverage for : https://www.labkey.org/ONPRC/Support%20Tickets/issues-details.view?issueId=41231
        */

        goToProjectHome();
        beginAtAnimalHistoryTab();
        AnimalHistoryPage animalHistoryPage = new AnimalHistoryPage(getDriver());
        animalHistoryPage.searchSingleAnimal("99995,99996,99997,99998,99999,999910");
        animalHistoryPage.refreshReport();
        animalHistoryPage.clickCategoryTab("Genetics")
                .clickReportTab("Kinship");

        log("verify kinship");
        assertTrue(isElementPresent(Locator.linkWithText("CLICK HERE TO LIMIT TO ANIMALS IN SELECTION")));

        DataRegionTable kinshipTable = animalHistoryPage.getActiveReportDataRegion();
        assertEquals("Incorrect number of kinship rows before limiting animal selection", 48, kinshipTable.getDataRowCount());

        // Spot check kinship
        assertEquals("Incorrect kinship coefficient for 999910 and 99998", "0.359375", kinshipTable.getDataAsText(0, "Coefficient"));
        assertEquals("Incorrect kinship coefficient for 999910 and 99992", "0.25", kinshipTable.getDataAsText(3, "Coefficient"));
        assertEquals("Incorrect kinship coefficient for 99995 and 99992", "0.25", kinshipTable.getDataAsText(10, "Coefficient"));
        assertEquals("Incorrect kinship coefficient for 99996 and 99997", "0.15625", kinshipTable.getDataAsText(21, "Coefficient"));
        assertEquals("Incorrect kinship coefficient for 99998 and 99997", "0.234375", kinshipTable.getDataAsText(35, "Coefficient"));

        kinshipTable.doAndWaitForUpdate(() -> Locator.linkWithText("CLICK HERE TO LIMIT TO ANIMALS IN SELECTION").findElement(getDriver()).click());

        kinshipTable = animalHistoryPage.getActiveReportDataRegion();
        assertEquals("Incorrect number of kinship rows after limiting animal selection", 30, kinshipTable.getDataRowCount());

        log("verify inbreeding");
        animalHistoryPage.clickCategoryTab("Genetics")
                .clickReportTab("Inbreeding Coefficients");

        DataRegionTable inbreedingTable = animalHistoryPage.getActiveReportDataRegion();
        assertEquals("Incorrect number of inbreeding rows", 6, inbreedingTable.getDataRowCount());

        // Spot check inbreeding
        assertEquals("Incorrect inbreeding coefficient for 999910", "0.09375", inbreedingTable.getDataAsText(0, "Coefficient"));
        assertEquals("Incorrect inbreeding coefficient for 99995", "0.0", inbreedingTable.getDataAsText(1, "Coefficient"));
        assertEquals("Incorrect inbreeding coefficient for 99997", "0.125", inbreedingTable.getDataAsText(3, "Coefficient"));
        assertEquals("Incorrect inbreeding coefficient for 99998", "0.25", inbreedingTable.getDataAsText(4, "Coefficient"));
        assertEquals("Incorrect inbreeding coefficient for 99999", "0.0", inbreedingTable.getDataAsText(5, "Coefficient"));
    }

    @Test
    public void testNotifications()
    {
        setupNotificationService();

        goToProjectHome();
        waitAndClickAndWait(Locators.bodyPanel().append(Locator.tagContainingText("a", "EHR Admin Page")));
        waitAndClickAndWait(Locator.tagContainingText("a", "Notification Admin"));

        _helper.waitForCmp("field[fieldLabel='Notification User']");

        Locator manageLink = Locator.tagContainingText("a", "Manage Subscribed Users/Groups").index(1);
        waitAndClick(manageLink);
        waitForElement(Ext4Helper.Locators.window("Manage Subscribed Users"));
        Ext4ComboRef.waitForComponent(this, "field[fieldLabel^='Add User Or Group']");
        Ext4ComboRef combo = Ext4ComboRef.getForLabel(this, "Add User Or Group");
        combo.waitForStoreLoad();
        _ext4Helper.selectComboBoxItem(Locator.id(combo.getId()), Ext4Helper.TextMatchTechnique.CONTAINS, DATA_ADMIN.getEmail());
        waitForElement(Ext4Helper.Locators.ext4Button("Remove"));

        Ext4FieldRef.waitForComponent(this, "field[fieldLabel^='Add User Or Group']");
        combo = Ext4ComboRef.getForLabel(this, "Add User Or Group");
        combo.waitForStoreLoad();
        _ext4Helper.selectComboBoxItem(Locator.id(combo.getId()), Ext4Helper.TextMatchTechnique.CONTAINS, BASIC_SUBMITTER.getEmail());
        waitForElement(Ext4Helper.Locators.ext4Button("Remove"), 2);
        waitAndClick(Ext4Helper.Locators.ext4Button("Close"));

        waitAndClick(manageLink);
        waitForElement(Ext4Helper.Locators.window("Manage Subscribed Users"));
        waitForElement(Locator.tagContainingText("div", DATA_ADMIN.getEmail()));
        waitForElement(Locator.tagContainingText("div", BASIC_SUBMITTER.getEmail()));
        waitForElement(Ext4Helper.Locators.ext4Button("Remove"));
        assertElementPresent(Ext4Helper.Locators.ext4Button("Remove"), 2);
        waitAndClick(Ext4Helper.Locators.ext4Button("Remove").index(0));  //remove admin
        waitAndClick(Ext4Helper.Locators.ext4Button("Close"));

        waitAndClick(manageLink);
        waitForElement(Ext4Helper.Locators.window("Manage Subscribed Users"));
        waitForElement(Locator.tagContainingText("div", BASIC_SUBMITTER.getEmail()));
        waitForElement(Ext4Helper.Locators.ext4Button("Remove"));
        assertElementPresent(Ext4Helper.Locators.ext4Button("Remove"), 1);
        waitAndClick(Ext4Helper.Locators.ext4Button("Close"));

        //iterate all notifications and run them.
        log("running all notifications");
        List<String> skippedNotifications = Arrays.asList("ETL Validation Notification", "Billing Validation Notification", "Pregnant NHPs Gestation Notification"); //Skip "Billing Validation Notification" - this is broken on the server and not been run successfully by the client.

        int count = Locator.tagContainingText("a", "Run Report In Browser").findElements(getDriver()).size();
        for (int i = 0; i < count; i++)
        {
            beginAt(WebTestHelper.getBaseURL() + "/ldk/" + getContainerPath() + "/notificationAdmin.view");
            Locator link = Locator.tagContainingText("a", "Run Report In Browser").index(i);
            Locator label = Locator.tag("div").withClass("ldk-notificationlabel").index(i);
            waitForElement(label);
            String notificationName = label.findElement(getDriver()).getText();
            Assert.assertNotNull(notificationName);
            if (skippedNotifications.contains(notificationName))
            {
                log("skipping notification: " + notificationName);
                continue;
            }

            log("running notification: " + notificationName);
            waitAndClickAndWait(link);
            waitForText("The notification email was last sent on:");
            assertTextNotPresent("not configured");
        }
    }

    @Test
    public void testObservationsGrid()
    {
        _helper.goToTaskForm("Bulk Clinical Entry");
        _helper.getExt4FieldForFormSection("Task", "Title").setValue("Test Observations 1");

        Ext4GridRef obsGrid = _helper.getExt4GridForFormSection("Observations");
        _helper.addRecordToGrid(obsGrid);

        // depending on the value set for category, a different editor should appear in the observations field
        obsGrid.setGridCell(1, "Id", MORE_ANIMAL_IDS[0]);
        obsGrid.setGridCell(1, "category", "BCS");

        //first BCS
        Ext4FieldRef editor = obsGrid.getActiveEditor(1, "observation");
        editor.getFnEval("this.expand()");
        Assert.assertEquals("ehr-simplecombo", editor.getFnEval("return this.xtype"));
        waitForElement(Locator.tagContainingText("li", "1.5").notHidden().withClass("x4-boundlist-item"));
        waitForElement(Locator.tagContainingText("li", "4.5").notHidden().withClass("x4-boundlist-item"));
        obsGrid.completeEdit();

        //then alopecia
        obsGrid.setGridCell(1, "category", "Alopecia Score");
        editor = obsGrid.getActiveEditor(1, "observation");
        editor.getFnEval("this.expand()");
        Assert.assertEquals("ehr-simplecombo", editor.getFnEval("return this.xtype"));
        waitForElement(Locator.tagContainingText("li", "1").notHidden().withClass("x4-boundlist-item"));
        waitForElement(Locator.tagContainingText("li", "4").notHidden().withClass("x4-boundlist-item"));
        assertElementNotPresent(Locator.tagContainingText("li", "4.5").notHidden().withClass("x4-boundlist-item"));
        obsGrid.completeEdit();

        //then pain score
        obsGrid.setGridCell(1, "category", "Pain Score");
        editor = obsGrid.getActiveEditor(1, "observation");
        Assert.assertEquals("ldk-numberfield", editor.getFnEval("return this.xtype"));
        assertElementNotPresent(Locator.tagContainingText("li", "4").notHidden().withClass("x4-boundlist-item"));
        obsGrid.completeEdit();
        obsGrid.setGridCell(1, "observation", "10");

        //add new row
        _helper.addRecordToGrid(obsGrid);
        obsGrid.setGridCell(2, "Id", MORE_ANIMAL_IDS[0]);
        obsGrid.setGridCell(2, "category", "BCS");

        //verify BCS working on new row
        editor = obsGrid.getActiveEditor(2, "observation");
        editor.getFnEval("this.expand()");
        Assert.assertEquals("ehr-simplecombo", editor.getFnEval("return this.xtype"));
        waitForElement(Locator.tagContainingText("li", "1.5").notHidden().withClass("x4-boundlist-item"));
        waitForElement(Locator.tagContainingText("li", "4.5").notHidden().withClass("x4-boundlist-item"));
        obsGrid.completeEdit();

        //now return to original row and make sure editor remembered
        editor = obsGrid.getActiveEditor(1, "observation");
        Assert.assertEquals("ldk-numberfield", editor.getFnEval("return this.xtype"));
        assertElementNotPresent(Locator.tagContainingText("li", "4.5").notHidden().withClass("x4-boundlist-item"));
        obsGrid.completeEdit();
        Assert.assertEquals("10", obsGrid.getFieldValue(1, "observation"));

        _helper.discardForm();
    }

    @Test
    public void testPathology()
    {
        _helper.goToTaskForm("Necropsy", false);

        //this is a proxy for the page loading and 1st record validation happening
        waitForElement(Locator.tagWithText("div", "The form has the following errors and warnings:"));

        _helper.getExt4FieldForFormSection("Necropsy", "Id").setValue(MORE_ANIMAL_IDS[1]);
        Ext4ComboRef procedureField = new Ext4ComboRef(_helper.getExt4FieldForFormSection("Necropsy", "Procedure").getId(), this);
        procedureField.setComboByDisplayValue("Necropsy & Histopathology Grade 2: Standard");

        Ext4FieldRef.getForLabel(this, "Case Number").clickTrigger();
        waitForElement(Ext4Helper.Locators.window("Create Case Number"));
        Ext4FieldRef.waitForField(this, "Prefix");
        Ext4FieldRef.getForLabel(this, "Year").setValue(2013);
        waitAndClick(Ext4Helper.Locators.window("Create Case Number").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        final String caseNoBase = "2013A00";
        waitFor(() -> Ext4FieldRef.getForLabel(ONPRC_EHRTest.this, "Case Number").getValue().toString().startsWith(caseNoBase),
                "Case Number field was not set", WAIT_FOR_JAVASCRIPT);
        assertTrue(Ext4FieldRef.getForLabel(this, "Case Number").getValue().toString().startsWith(caseNoBase));
        String caseNo = Ext4FieldRef.getForLabel(this, "Case Number").getValue().toString();

        // apply form template
        waitAndClick(Ext4Helper.Locators.ext4Button("Apply Form Template"));
        waitForElement(Ext4Helper.Locators.window("Apply Template To Form"));
        Ext4FieldRef.waitForField(this, "Diagnoses");
        Ext4ComboRef.getForLabel(this, "Choose Template").setComboByDisplayValue("Necropsy");
        sleep(100);
        Assert.assertEquals("Gross Findings", Ext4ComboRef.getForLabel(this, "Gross Findings").getDisplayValue());
        Assert.assertEquals("Necropsy", Ext4ComboRef.getForLabel(this, "Staff").getDisplayValue());
        waitAndClick(Ext4Helper.Locators.window("Apply Template To Form").append(Ext4Helper.Locators.ext4Button("Submit")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Apply Template To Form"));

        //staff sections
        _ext4Helper.clickExt4Tab("Staff");
        Ext4GridRef staffGrid = _helper.getExt4GridForFormSection("Staff");
        staffGrid.waitForRowCount(3);

        //check gross findings second, because the above is a more reliable wait
        Assert.assertNotNull(StringUtils.trimToNull((String) _helper.getExt4FieldForFormSection("Gross Findings", "Notes").getValue()));

        //test SNOMED codes
        _ext4Helper.clickExt4Tab("Histologic Findings");
        Ext4GridRef histologyGrid = _helper.getExt4GridForFormSection("Histologic Findings");
        _helper.addRecordToGrid(histologyGrid, "Add Record");
        scrollIntoView(histologyGrid.getCell(1,7), true);
        waitAndClick(histologyGrid.getCell(1, 7));
        waitForElement(Ext4Helper.Locators.window("Manage SNOMED Codes"));
        Ext4ComboRef field = Ext4ComboRef.getForLabel(this, "Add Code");
        field.waitForEnabled();
        field.waitForStoreLoad();

        List<WebElement> visible = new ArrayList<>();
        for (WebElement element : getDriver().findElements(By.id(field.getId() + "-inputEl")))
        {
            if (element.isDisplayed())
            {
                visible.add(element);
            }
        }
        Assert.assertEquals(1, visible.size());

        visible.get(0).sendKeys("ketamine");
        sleep(2000);
        visible.get(0).sendKeys(Keys.ENTER);
        String code1 = "Ketamine injectable (100mg/ml) (E-70590)";
        waitForElement(Locator.tagContainingText("div", "1: " + code1),20000);

        visible.get(0).sendKeys("heart");
        sleep(2000);
        visible.get(0).sendKeys(Keys.ENTER);
        String code2 = "APEX OF HEART (T-32040)";
        waitForElement(Locator.tagContainingText("div", "2: " + code2),20000);
        assertTrue(isTextBefore(code1, code2));

        visible.get(0).sendKeys("disease");
        sleep(2000);
        visible.get(0).sendKeys(Keys.ENTER);
        String code3 = "ALEUTIAN DISEASE (D-03550)";
        waitForElement(Locator.tagContainingText("div", "3: " + code3),20000);
        assertTrue(isTextBefore(code2, code3));

        //move first code down
        click(Locator.id(_ext4Helper.componentQuery("button[testLocator=snomedDownArrow]", Ext4CmpRef.class).get(0).getId()));
        waitForElement(Locator.tagContainingText("div", "1: " + code2));
        assertElementPresent(Locator.tagContainingText("div", "2: " + code1));
        assertElementPresent(Locator.tagContainingText("div", "3: " + code3));

        //once more
        click(Locator.id(_ext4Helper.componentQuery("button[testLocator=snomedUpArrow]", Ext4CmpRef.class).get(2).getId()));
        waitForElement(Locator.tagContainingText("div", "3: " + code1));
        assertElementPresent(Locator.tagContainingText("div", "1: " + code2));
        assertElementPresent(Locator.tagContainingText("div", "2: " + code3));

        //this should do nothing
        click(Locator.id(_ext4Helper.componentQuery("button[testLocator=snomedUpArrow]", Ext4CmpRef.class).get(0).getId()));
        waitForElement(Locator.tagContainingText("div", "1: " + code2));
        assertElementPresent(Locator.tagContainingText("div", "2: " + code3));
        assertElementPresent(Locator.tagContainingText("div", "3: " + code1));

        click(Locator.id(_ext4Helper.componentQuery("button[testLocator=snomedDelete]", Ext4CmpRef.class).get(0).getId()));
        assertElementNotPresent(Locator.tagContainingText("div", code2));

        waitAndClick(Ext4Helper.Locators.window("Manage SNOMED Codes").append(Ext4Helper.Locators.ext4Button("Submit")));
        Assert.assertEquals("1<>D-03550;2<>E-70590", histologyGrid.getFieldValue(1, "codesRaw").toString());
        assertTrue(isTextBefore("1: " + code3, "2: " + code1));

        //enter death
        waitAndClick(Ext4Helper.Locators.ext4ButtonEnabled("Enter/Manage Death"));
        Locator.XPathLocator deathWindow = Ext4Helper.Locators.window("Deaths");
        waitForElement(deathWindow);
        Ext4FieldRef.waitForField(this, "Necropsy Case No");
        waitForElement(deathWindow.append(Locator.tagContainingText("div", MORE_ANIMAL_IDS[1])));  //proxy for record loading
        Ext4ComboRef causeField = _ext4Helper.queryOne("window field[name=cause]", Ext4ComboRef.class);
        causeField.waitForEnabled();
        causeField.waitForStoreLoad();
        causeField.setValue("EUTHANASIA, EXPERIMENTAL");
        Assert.assertEquals(caseNo, _ext4Helper.queryOne("window field[name=necropsy]", Ext4FieldRef.class).getValue());
        waitAndClick(deathWindow.append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        waitForElementToDisappear(deathWindow, 20000); //saving can take longer than default 10 seconds
        waitForElementToDisappear(Locator.tagContainingText("div", "Saving Changes...").notHidden());

        waitAndClickAndWait(_helper.getDataEntryButton("Save & Close"));

        //make new necropsy, copy from previous
        _helper.goToTaskForm("Necropsy", false);
        _helper.getExt4FieldForFormSection("Necropsy", "Id").setValue(MORE_ANIMAL_IDS[1]);
        procedureField = new Ext4ComboRef(_helper.getExt4FieldForFormSection("Necropsy", "Procedure").getId(), this);
        procedureField.setComboByDisplayValue("Necropsy & Histopathology Grade 2: Standard");

        waitAndClick(Ext4Helper.Locators.ext4Button("Copy Previous Case"));
        Locator.XPathLocator caseWindow = Ext4Helper.Locators.window("Copy From Previous Case");
        waitForElement(caseWindow);
        Ext4FieldRef.waitForField(this, "Animal Id");
        _ext4Helper.queryOne("window field[fieldLabel=Case No]", Ext4FieldRef.class).setValue(caseNo);
        Ext4FieldRef.getForBoxLabel(this, "Staff").setChecked(true);
        Ext4FieldRef.getForBoxLabel(this, "Notes").setChecked(true);
        Ext4FieldRef.getForBoxLabel(this, "Gross Findings").setChecked(true);
        Ext4FieldRef.getForBoxLabel(this, "Histologic Findings").setChecked(true);
        Ext4FieldRef.getForBoxLabel(this, "Diagnoses").setChecked(true);
        waitAndClick(caseWindow.append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));

        //verify records
        _helper.getExt4GridForFormSection("Staff").waitForRowCount(3);
        _ext4Helper.clickExt4Tab("Histologic Findings");
        Assert.assertEquals(1, _helper.getExt4GridForFormSection("Histologic Findings").getRowCount());
        _ext4Helper.clickExt4Tab("Diagnoses");
        Assert.assertEquals(0, _helper.getExt4GridForFormSection("Diagnoses").getRowCount());
        Assert.assertNotNull(StringUtils.trimToNull((String) _helper.getExt4FieldForFormSection("Gross Findings", "Notes").getValue()));

        _helper.discardForm();
    }

    @Test
    public void testSurgeryForm()
    {
        _helper.goToTaskForm("Surgeries");

        Ext4GridRef proceduresGrid = _helper.getExt4GridForFormSection("Procedures");
        _helper.addRecordToGrid(proceduresGrid);
        proceduresGrid.setGridCell(1, "Id", MORE_ANIMAL_IDS[1]);

        Ext4ComboRef procedureCombo = new Ext4ComboRef(proceduresGrid.getActiveEditor(1, "procedureid"), this);
        procedureCombo.setComboByDisplayValue("Lymph Node and Skin Biopsy - FITC");
        proceduresGrid.completeEdit();
        sleep(100);
        proceduresGrid.setGridCellJS(1, "instructions", "These are my instructions");
        sleep(100);
        proceduresGrid.setGridCellJS(1, "chargetype", "Center Staff");

        waitAndClick(Ext4Helper.Locators.ext4Button("Add Procedure Defaults"));
        waitForElement(Ext4Helper.Locators.window("Add Procedure Defaults"));
        waitForElement(Ext4Helper.Locators.window("Add Procedure Defaults").append(Locator.tagWithText("div", MORE_ANIMAL_IDS[1])));
        waitAndClick(Ext4Helper.Locators.window("Add Procedure Defaults").append(Ext4Helper.Locators.ext4Button("Submit")));

        _ext4Helper.clickExt4Tab("Staff");
        Ext4GridRef staffGrid = _helper.getExt4GridForFormSection("Staff");
        staffGrid.waitForRowCount(1);
        Assert.assertEquals("Surgeon", staffGrid.getFieldValue(1, "role"));

        _ext4Helper.clickExt4Tab("Weight");
        Ext4GridRef weightGrid = _helper.getExt4GridForFormSection("Weight");
        weightGrid.waitForRowCount(1);
        weightGrid.setGridCell(1, "weight", "5");

        _ext4Helper.clickExt4Tab("Medication/Treatment Orders");
        Ext4GridRef treatmentGrid = _helper.getExt4GridForFormSection("Medication/Treatment Orders");
        treatmentGrid.clickTbarButton("Order Post-Op Meds");
        waitForElement(Ext4Helper.Locators.window("Order Post-Op Meds"));
        waitForElement(Ext4Helper.Locators.window("Order Post-Op Meds").append(Locator.tagWithText("div", MORE_ANIMAL_IDS[1])));
        _ext4Helper.queryOne("field[fieldName=analgesiaRx]", Ext4ComboRef.class).waitForStoreLoad();
        _ext4Helper.queryOne("field[fieldName=antibioticRx]", Ext4ComboRef.class).waitForStoreLoad();
        waitAndClick(Ext4Helper.Locators.window("Order Post-Op Meds").append(Ext4Helper.Locators.ext4Button("Submit")));
        treatmentGrid.waitForRowCount(2);
        Assert.assertEquals(0.30, treatmentGrid.getFieldValue(1, "amount"));
        Assert.assertEquals("mg", treatmentGrid.getFieldValue(1, "amount_units"));
        Assert.assertEquals("E-YY792", treatmentGrid.getFieldValue(1, "code"));

        //review amounts window
        treatmentGrid.clickTbarButton("Review Amount(s)");
        waitForElement(Ext4Helper.Locators.window("Review Drug Amounts"));
        waitForElement(Ext4Helper.Locators.window("Review Drug Amounts").append(Locator.tagWithText("div", MORE_ANIMAL_IDS[1])), 2);

        Map<String, Object> expectedVals1 = new HashMap<>();
        expectedVals1.put("weight", 5L);
        expectedVals1.put("concentration", 0.3);
        expectedVals1.put("conc_units", "mg/ml");
        expectedVals1.put("dosage", 0.01);
        expectedVals1.put("dosage_units", "mg/kg");
        expectedVals1.put("volume", 1L);
        expectedVals1.put("vol_units", "mL");
        expectedVals1.put("amount", 0.3);
        expectedVals1.put("amount_units", "mg");
        expectedVals1.put("include", true);

        inspectDrugAmountFields(expectedVals1, 0);

        setDrugAmountField("weight", 0, 6L, expectedVals1);
        expectedVals1.put("volume", 0.2);
        expectedVals1.put("amount", 0.06);
        inspectDrugAmountFields(expectedVals1, 0);

        setDrugAmountField("conc_units", 0, "mg/tablet", expectedVals1);
        expectedVals1.put("vol_units", "tablet(s)");
        inspectDrugAmountFields(expectedVals1, 0);

        setDrugAmountField("dosage_units", 0, "ounces/kg", expectedVals1);
        expectedVals1.put("amount_units", "ounces");
        expectedVals1.put("conc_units", null);
        inspectDrugAmountFields(expectedVals1, 0);

        setDrugAmountField("dosage", 0, 0.02, expectedVals1);
        expectedVals1.put("volume", 0.4);
        expectedVals1.put("amount", 0.12);
        inspectDrugAmountFields(expectedVals1, 0);

        setDrugAmountField("include", 0, false, expectedVals1);
        setDrugAmountField("dosage", 0, 0.01, expectedVals1);
        inspectDrugAmountFields(expectedVals1, 0);

        setDrugAmountField("include", 0, true, expectedVals1);

        //now doses tab
        _ext4Helper.clickExt4Tab("Doses Used");
        waitForElement(Locator.tagContainingText("b", "Standard Conc"));
        _ext4Helper.queryOne("field[fieldName=concentration][recordIdx=0][snomedCode]", Ext4FieldRef.class).setValue(0.5);
        _ext4Helper.queryOne("field[fieldName=dosage][recordIdx=0][snomedCode]", Ext4FieldRef.class).setValue(2);
        _ext4Helper.queryOne("field[fieldName=volume_rounding][recordIdx=0][snomedCode]", Ext4FieldRef.class).setValue(0.8);
        click(Locator.id(_ext4Helper.queryOne("button[recordIdx=0][snomedCode]", Ext4FieldRef.class).getId()));
        _ext4Helper.clickExt4Tab("All Rows");
        waitForElement(Locator.tagContainingText("div", "This tab shows one row per drug"));
        expectedVals1.put("concentration", 0.5);
        expectedVals1.put("conc_units", "mg/ml");
        expectedVals1.put("dosage", 2L);
        expectedVals1.put("dosage_units", "mg/kg");
        expectedVals1.put("volume", null);
        expectedVals1.put("vol_units", "mL");
        expectedVals1.put("amount", null);
        expectedVals1.put("amount_units", "mg");
        inspectDrugAmountFields(expectedVals1, 0);

        click(Ext4Helper.Locators.ext4Button("Recalculate All"));
        click(Ext4Helper.Locators.menuItem("Recalculate Both Amount/Volume"));
        expectedVals1.put("volume", 24L);
        expectedVals1.put("amount", 12L);
        inspectDrugAmountFields(expectedVals1, 0);

        //weight tab
        _ext4Helper.clickExt4Tab("Weights Used");
        waitForElement(Locator.tagContainingText("div", "From Form"));
        _ext4Helper.queryOne("field[fieldName=globalWeight][recordIdx=0]", Ext4FieldRef.class).setValue(3);
        waitForElement(Locator.tagContainingText("div", "Custom"));

        _ext4Helper.clickExt4Tab("All Rows");
        waitForElement(Locator.tagContainingText("div", "This tab shows one row per drug"));
        expectedVals1.put("weight", 3L);
        expectedVals1.put("volume", 12L);
        expectedVals1.put("amount", 6L);
        inspectDrugAmountFields(expectedVals1, 0);

        waitAndClick(Ext4Helper.Locators.window("Review Drug Amounts").append(Ext4Helper.Locators.ext4Button("Submit")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Review Drug Amounts"));

        Assert.assertEquals(12L, treatmentGrid.getFieldValue(1, "volume"));
        Assert.assertEquals(6L, treatmentGrid.getFieldValue(1, "amount"));

        //open cases btn
        waitAndClick(Ext4Helper.Locators.ext4Button("Open Cases"));
        Locator.XPathLocator caseWindow = Ext4Helper.Locators.window("Open Cases");
        waitForElement(caseWindow);
        waitForElement(caseWindow.append(Locator.tagWithText("div", "7"))); //followup days
        waitAndClick(caseWindow.append(Ext4Helper.Locators.ext4ButtonEnabled("Open Selected Cases")));
        waitForElementToDisappear(caseWindow);
        waitForElement(Ext4Helper.Locators.window("Success").append(Locator.tagWithText("div", "Surgical cases opened")));
        waitAndClick(Ext4Helper.Locators.window("Success").append(Ext4Helper.Locators.ext4ButtonEnabled("OK")));
        _helper.discardForm();
    }

    private void inspectDrugAmountFields(Map<String, Object> expectedVals, int rowIdx)
    {
        for (String fieldName : expectedVals.keySet())
        {
            Ext4FieldRef field = _ext4Helper.queryOne("field[fieldName=" +fieldName + "][recordIdx=" + rowIdx + "]", Ext4FieldRef.class);
            Assert.assertEquals("incorrect field value: " + fieldName, expectedVals.get(fieldName), field.getValue());
        }
    }

    private void setDrugAmountField(String fieldName, int rowIdx, Object value, Map<String, Object> expectedVals)
    {
        _ext4Helper.queryOne("field[fieldName=" +fieldName + "][recordIdx=" + rowIdx + "]", Ext4FieldRef.class).setValue(value);
        expectedVals.put(fieldName, value);
    }

    @Test
    public void testBehaviorRounds() throws Exception
    {
        _helper.goToTaskForm("BSU Rounds");

        //create a previous observation for the active case
        SelectRowsCommand select = new SelectRowsCommand("study", "cases");
        select.addFilter(new Filter("Id", SUBJECTS[0], Filter.Operator.EQUAL));
        select.addFilter(new Filter("category", "Behavior", Filter.Operator.EQUAL));
        select.setColumns(Arrays.asList("Id", "objectid"));
        SelectRowsResponse resp = select.execute(getApiHelper().getConnection(), getContainerPath());
        String caseId = (String)resp.getRows().get(0).get("objectid");

        getApiHelper().deleteAllRecords("study", "clinical_observations", new Filter("Id", SUBJECTS[0], Filter.Operator.EQUAL));
        InsertRowsCommand insertRowsCommand = new InsertRowsCommand("study", "clinical_observations");
        Map<String, Object> row = new HashMap<>();
        row.put("Id", SUBJECTS[0]);
        row.put("category", "Alopecia Score");
        row.put("date", prepareDate(new Date(), -4, 0));
        row.put("caseid", caseId);
        row.put("observation", "5");
        row.put("objectid", generateGUID());
        row.put("taskid", generateGUID());  //required for latestObservationsForCase.sql to work
        insertRowsCommand.addRow(row);
        insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());

        Ext4GridRef obsGrid = _helper.getExt4GridForFormSection("Observations");
        obsGrid.clickTbarButton("Add Open Cases");

        Locator.XPathLocator caseWindow = Ext4Helper.Locators.window("Add Open Behavior Cases");
        waitForElement(caseWindow);

        //just load all behavior cases
        waitAndClick(Ext4Helper.Locators.windowButton("Add Open Behavior Cases", "Submit"));
        waitForElementToDisappear(caseWindow);
        obsGrid.waitForRowCount(1);
        Assert.assertEquals("Alopecia Score", obsGrid.getFieldValue(1, "category"));
        String observation = (String)obsGrid.getFieldValue(1, "observation");
        Assert.assertTrue("Expected \"Observation/Score\" to be empty (blank or null) but was \"" + observation + "\"", StringUtils.isEmpty(observation));
        Assert.assertEquals(SUBJECTS[0], obsGrid.getFieldValue(1, "Id"));

        _ext4Helper.clickExt4Tab("Treatments Given");
        waitForElement(Locator.tagWithText("div", "No Charge"));
        Ext4GridRef treatmentsGrid = _ext4Helper.queryOne("panel[title=Treatments Given] ehr-gridpanel", Ext4GridRef.class);
        treatmentsGrid.waitForRowCount(1);
        Assert.assertEquals(SUBJECTS[0], treatmentsGrid.getFieldValue(1, "Id"));
        Assert.assertEquals("No Charge", treatmentsGrid.getFieldValue(1, "chargetype"));

        waitAndClick(Ext4Helper.Locators.ext4Button("Close/Review Cases"));
        Locator.XPathLocator closeCaseWindow = Ext4Helper.Locators.window("Manage Cases");
        waitForElement(closeCaseWindow);
        waitForElement(closeCaseWindow.append(Locator.tagWithText("div", SUBJECTS[0])));

        Ext4FieldRef caseField1 = _ext4Helper.queryOne("window field[fieldName=date]", Ext4FieldRef.class);
        Ext4FieldRef changeField = _ext4Helper.queryOne("#changeAll", Ext4FieldRef.class);
        Ext4CmpRef changeBtn = _ext4Helper.queryOne("button[text=Change All]", Ext4CmpRef.class);
        Date twoWeeks = prepareDate(DateUtils.truncate(new Date(), Calendar.DATE), 14, 0);
        Date fourWeeks = prepareDate(DateUtils.truncate(new Date(), Calendar.DATE), 28, 0);
        Assert.assertEquals(twoWeeks, caseField1.getDateValue());
        Assert.assertEquals(null, changeField.getValue());
        changeField.setValue(_df.format(fourWeeks));
        click(Locator.id(changeBtn.getId()));
        Assert.assertEquals(fourWeeks, caseField1.getDateValue());

        waitAndClick(closeCaseWindow.append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        waitForElementToDisappear(closeCaseWindow);

        _helper.discardForm();
    }
    @Test
    public void testClinicalHistoryPanelOptions(){
        beginAtAnimalHistoryTab();
        openClinicalHistoryForAnimal("TEST1020148");
        List<String> expectedLabels = new ArrayList<String>(
                Arrays.asList(
                        "Alert",
                        "Antibiotic Sensitivity",
                        "Assignments",
                        "Births",
                        "Clinical",
                        "Deliveries",
                        "Housing Transfers",
                        "Microbiology",
                        "Parasitology",
                        "Serology",
                        "Weights",
                        "Behavior",
                        "Animal Groups",
                        "Arrival/Departure",
                        "Biochemistry",
                        "Blood Draws",
                        "Deaths",
                        "Hematology",
                        "Labwork",
                        "Misc Tests",
                        "Pregnancy Confirmations",
                        "Urinalysis",
                        "iStat",
                        "Biopsy",
                        "Epoc"
                ));
        checkClinicalHistoryType(expectedLabels);
    }

    @Test
    public void testNecropsyRequestFlow() throws IOException, CommandException
    {
        String animalId = "12345";
        LocalDateTime tomorrow = LocalDateTime.now().plusDays(1);
        LocalDateTime dayAfterTomorrow = LocalDateTime.now().plusDays(2);
        String projectId = "640991";
        DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        InsertRowsCommand protocolCommand = new InsertRowsCommand("onprc_billing", "chargeableItems");
        protocolCommand.addRow(Maps.of("name", "Pathology- Necropsy Grade 2 Standard", "category", "Pathology", "canRaiseFA", "true", "endDate", dayAfterTomorrow.format(formatter2), "active", "true"));
        protocolCommand.execute(getApiHelper().getConnection(), getContainerPath());

        log("Begin the test with entry data page");
        EnterDataPage enterData = EnterDataPage.beginAt(this, getContainerPath());
        enterData.waitAndClickAndWait(Locator.linkWithText("Pathology Service Request"));
        waitForElement(Locator.pageHeader("Pathology Service Request"));

        log("Setting the Necropsy details");
        setNecropsyFormElement("Id", animalId);
        setNecropsyFormElementbyID("datefield", tomorrow.format(formatter2));
        click(Locator.tagWithClassContaining("div","x4-trigger-index-1").index(0)); // first drop down
        _ext4Helper.selectComboBoxItem("Center Project:",Ext4Helper.TextMatchTechnique.CONTAINS,"Other");
        _ext4Helper.selectComboBoxItem("Project:",Ext4Helper.TextMatchTechnique.CONTAINS,projectId);
        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        click(Locator.tagWithClassContaining("div","x4-trigger-index-1").index(1));
        Ext4ComboRef combo = Ext4ComboRef.getForLabel(this, "Center Project Billing");
        combo.waitForStoreLoad();
        _ext4Helper.selectComboBoxItem(Locator.id(combo.getId()),Ext4Helper.TextMatchTechnique.CONTAINS,"Other");
        _ext4Helper.selectComboBoxItem("Project:",Ext4Helper.TextMatchTechnique.CONTAINS,projectId);
        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        setNecropsyFormElement("fastingtype", "N/A");
        setNecropsyFormElement("animaldelivery", "Deliver from Surgery");
        setNecropsyFormElement("remainingTissues", "Yes");
        setNecropsyFormElement("necropsylocation", "ASA South");

        log("Entering values for Tissue Distributions");
        Ext4GridRef grid = _helper.getExt4GridForFormSection("Tissue Distributions");
        _helper.addRecordToGrid(grid);
        int index = grid.getRowCount();
        grid.setGridCell(index, "Id", animalId);
        grid.setGridCell(index, "date", tomorrow.format(formatter2));
        grid.setGridCell(index, "tissue", "ABDOMINAL VISCERA, NOS (T-Y5000)");
        grid.setGridCell(index, "sampletype", "Biopsy");

        // Avoid JavaScript error from 'RequestStoreCollection.commitChanges'
        sleep(2_000);

        log("Setting the MiscCharges details");
        waitAndClick(Locator.linkWithText("Misc. Charges"));
        Ext4GridRef grid2 = _helper.getExt4GridForFormSection("Misc. Charges");
        _helper.addRecordToGrid(grid2);
        int index2 = grid2.getRowCount();
        grid2.setGridCell(index2, "Id", animalId);
        grid2.setGridCell(index2, "date", tomorrow.format(formatter2));
        click(Locator.tagWithClassContaining("div","x4-trigger-index-1"));
        grid2.setGridCell(index2, "chargeId", "Pathology- Necropsy Grade 2 Standard");
        grid2.setGridCell(index2, "quantity", "1.0");

        // Avoid JavaScript error from 'RequestStoreCollection.commitChanges'
        sleep(2_000);

        log("Submit the request");
        WebElement requestButton = Ext4Helper.Locators.ext4Button("Request").withoutAttributeContaining("class", "disabled").waitForElement(getDriver(), 3_000);
        clickAndWait(requestButton);

        waitAndClick(Locator.linkWithText("My Pending Requests"));
        click(Locator.linkWithText("Procedure"));

        log("Verifying the submitted Necropsy Request");
        DataRegionTable regionTable = new DataRegionTable("study|encounters", getDriver());
//        assertEquals("There should be single approved necropsy request", 1, regionTable.getDataRowCount());

        //code to add for the remaining flow
    }
    private void setNecropsyFormElementbyID(String id, String value)
    {
        Locator loc = Locator.inputByIdContaining(id);
        waitForElement(loc);
        setFormElement(loc, value);
        assertEquals(value, getFormElement(loc));
    }
    private void setNecropsyFormElement(String id, String value)
    {
        Locator loc = Locator.name(id);
        waitForElement(loc);
        setFormElement(loc, value);
        assertEquals(value, getFormElement(loc));
    }

    @Override
    protected String getAnimalHistoryPath()
    {
        return ANIMAL_HISTORY_URL;
    }
}

