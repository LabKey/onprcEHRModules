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
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.CommandResponse;
import org.labkey.remoteapi.GetCommand;
import org.labkey.remoteapi.SimplePostCommand;
import org.labkey.remoteapi.query.ExecuteSqlCommand;
import org.labkey.remoteapi.query.Filter;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.SaveRowsResponse;
import org.labkey.remoteapi.query.SelectRowsCommand;
import org.labkey.remoteapi.query.SelectRowsResponse;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.TestProperties;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.ONPRC;
import org.labkey.test.pages.ehr.AnimalHistoryPage;
import org.labkey.test.util.APIContainerHelper;
import org.labkey.test.util.AbstractContainerHelper;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PasswordUtil;
import org.labkey.test.util.di.DataIntegrationHelper;
import org.labkey.test.util.ext4cmp.Ext4CmpRef;
import org.labkey.test.util.ext4cmp.Ext4ComboRef;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;
import org.labkey.test.util.ext4cmp.Ext4GridRef;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.io.IOException;
import java.net.URI;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.junit.Assert.assertTrue;
import static org.labkey.test.util.Ext4Helper.Locators.ext4Button;
import static org.labkey.test.util.Ext4Helper.elementIfEnabled;

@Category({CustomModules.class, EHR.class, ONPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 18)
public class ONPRC_EHRTest2 extends AbstractONPRC_EHRTest
{
    public AbstractContainerHelper _containerHelper = new APIContainerHelper(this);
    private final String PROJECT_NAME = "ONPRC_EHR_TestProject2";
    public DataIntegrationHelper _etlHelper = new DataIntegrationHelper(PROJECT_NAME);
    private final String ANIMAL_HISTORY_URL = "/ehr/" + getProjectName() + "/animalHistory.view?";
    protected DateTimeFormatter _dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @BeforeClass
    @LogMethod
    public static void setupProject() throws Exception
    {
        ONPRC_EHRTest2 initTest = new ONPRC_EHRTest2();
        initTest.doCleanup(false);

        initTest.doSetUp();
    }

    @Override
    protected String getModuleDirectory()
    {
        return "onprc_ehr";
    }

    @Override
    protected String getProjectName()
    {
        return PROJECT_NAME;
    }

    private void doSetUp() throws Exception
    {
        initProject();
        createTestSubjects();

        //treatmentToDrug ETL is part of this module.
        _containerHelper.enableModule("TreatmentETL");
    }

    @Override
    protected boolean doSetUserPasswords()
    {
        return true;
    }

    @Test
    public void testBirthStatusApi() throws Exception
    {
        goToProjectHome();

        //first create record for dam, along w/ animal group and SPF status.  we expect this to automatically create a demographics record w/ the right status
        final String damId1 = "Dam1";
        final String offspringId1 = "Offspring1";
        final String offspringId2 = "Offspring2";
        final String offspringId3 = "Offspring3";
        final String offspringId4 = "Offspring4";
        final String offspringId5 = "Offspring5";
        final String offspringId6 = "Offspring6";
        final String offspringId7 = "Offspring7";
        final String offspringId8 = "Offspring8";

        log("deleting existing records");
        cleanRecords(damId1, offspringId1, offspringId2, offspringId3, offspringId4, offspringId5, offspringId6, offspringId7, offspringId8);
        ensureFlagExists("Condition", "Nonrestricted", "201");

        final Date dam1Birth = new Date();

        //insert into birth
        log("Creating Dam");
        getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), getApiHelper().prepareInsertCommand("study", "birth", "lsid",
                new String[]{"Id", "Date", "gender", "QCStateLabel"},
                new Object[][]{
                        {damId1, dam1Birth, "f", "In Progress"},
                }
        ), getExtraContext());

        //record is draft, so we shouldnt have a demographics record
        org.junit.Assert.assertFalse("demographics row was created for dam1", getApiHelper().doesRowExist("study", "demographics", new Filter("Id", damId1, Filter.Operator.EQUAL)));

        //update to completed, expect to find demographics record.
        SelectRowsCommand select1 = new SelectRowsCommand("study", "birth");
        select1.addFilter(new Filter("Id", damId1, Filter.Operator.EQUAL));
        final String damLsid = (String) select1.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("lsid");
        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {{
            put("lsid", damLsid);
            put("QCStateLabel", "Completed");
        }}, false);
        assertTrue("demographics row was not created for dam1", getApiHelper().doesRowExist("study", "demographics", new Filter("Id", damId1, Filter.Operator.EQUAL)));

        //update record to get a geographic_origin, which we expect to get entered into demographics
        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {
            {
                put("lsid", damLsid);
                put("geographic_origin", INDIAN);
                put("species", RHESUS);
            }
        }, false);

        SelectRowsCommand select2 = new SelectRowsCommand("study", "demographics");
        select2.addFilter(new Filter("Id", damId1, Filter.Operator.EQUAL));
        List<Map<String, Object>> selectRows2 = select2.execute(getApiHelper().getConnection(), getContainerPath()).getRows();
        org.junit.Assert.assertEquals("Wrong number of demographics rows", 1, selectRows2.size());
        Map<String, Object> selectRow2 = selectRows2.get(0);
        org.junit.Assert.assertEquals("geographic_origin was not updated. Row: " + selectRow2, INDIAN, selectRow2.get("geographic_origin"));
        org.junit.Assert.assertEquals("species was not updated. Row: " + selectRow2, RHESUS, selectRow2.get("species"));
        org.junit.Assert.assertEquals("gender was not updated. Row: " + selectRow2, "f", selectRow2.get("gender"));
        org.junit.Assert.assertEquals("calculated_status was not set properly. Row: " + selectRow2, "Alive", selectRow2.get("calculated_status"));

        //now add SPF status + group for dam.
        String spfStatus = "SPF 9";
        final String spfFlag = getOrCreateSpfFlag(spfStatus);
        InsertRowsCommand insertRowsCommand = new InsertRowsCommand("study", "flags");
        insertRowsCommand.addRow(new HashMap<>()
        {
            {
                put("Id", damId1);
                put("date", dam1Birth);
                put("flag", spfFlag);
            }
        });
        insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());

        String groupName = "TestGroup1";
        final Integer groupId = getOrCreateGroup(groupName);
        InsertRowsCommand insertRowsCommand2 = new InsertRowsCommand("study", "animal_group_members");
        insertRowsCommand2.addRow(new HashMap<>()
        {
            {
                put("Id", damId1);
                put("date", dam1Birth);
                put("groupId", groupId);
            }
        });
        insertRowsCommand2.execute(getApiHelper().getConnection(), getContainerPath());

        //test opening case.  expect WARN message b/c we have no demographics and no draft birth
        Map<String, Object> additionalContext = new HashMap<>();
        additionalContext.put("allowAnyId", false);
        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "cases", new String[]{"Id", "date", "category", "_recordId"}, new Object[][]{
                {offspringId5, prepareDate(new Date(), 10, 0), "Clinical", "recordID"}
        }, Maps.of(
                "Id", Arrays.asList(
                        "WARN: Id not found in demographics table: " + offspringId5
                )
        ), additionalContext);

        //now enter children, testing different modes.
        // offspring 1 is not public, so we dont expect a demographics record.  will update to completed
        // offspring 2 is public, so expect a demographics record, and SPF/groups to be copied
        // offspring 3 is born dead, non-final.  will update to completed
        // offspring 4 is born dead, finalized
        // offspring 5 is entered w/o the dam initially, as non-final.  will update to completed and enter dam at same time
        // offspring 6 is is entered w/o the dam initially, finalized.  will update with dam
        // offspring 7, same as 1, except we leave species/geographic origin blank and expect dam's demographics to be copied to child
        // offspring 8, same as 1, except we leave species/geographic origin blank and and expect dam's demographics to be copied to child
        Date birthDate = new Date();
        double weight = 2.3;
        String room1 = "Room1";
        String cage1 = "A1";
        String bornDead = "Born Dead/Not Born";
        InsertRowsCommand insertRowsCommand1 = new InsertRowsCommand("study", "birth");
        List<String> birthFields = Arrays.asList("Id", "Date", "birth_condition", "species", "geographic_origin", "gender", "room", "cage", "dam", "sire", "weight", "wdate", "QCStateLabel");
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId1, birthDate, "Live Birth", RHESUS, INDIAN, "f", room1, cage1, damId1, null, weight, birthDate, "In Progress"}));
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId2, birthDate, "Live Birth", RHESUS, INDIAN, "f", room1, cage1, damId1, null, weight, birthDate, "Completed"}));
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId3, birthDate, bornDead, RHESUS, INDIAN, "f", room1, cage1, damId1, null, weight, birthDate, "In Progress"}));
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId4, birthDate, bornDead, RHESUS, INDIAN, "f", room1, cage1, damId1, null, weight, birthDate, "Completed"}));
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId5, birthDate, "Live Birth", RHESUS, INDIAN, "f", room1, cage1, null, null, weight, birthDate, "In Progress"}));
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId6, birthDate, "Live Birth", RHESUS, INDIAN, "f", room1, cage1, null, null, weight, birthDate, "Completed"}));
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId7, birthDate, "Live Birth", null, null, "f", room1, cage1, damId1, null, weight, birthDate, "In Progress"}));
        insertRowsCommand1.addRow(getApiHelper().createHashMap(birthFields, new Object[]{offspringId8, birthDate, "Live Birth", null, null, "f", room1, cage1, damId1, null, weight, birthDate, "Completed"}));
        insertRowsCommand1.setTimeout(0);
        SaveRowsResponse insertRowsResp = insertRowsCommand1.execute(getApiHelper().getConnection(), getContainerPath());

        final Map<String, String> lsidMap = new HashMap<>();
        for (Map<String, Object> row : insertRowsResp.getRows())
        {
            lsidMap.put((String) row.get("Id"), (String) row.get("lsid"));
        }

        testBirthRecordStatus(offspringId1);
        testBirthRecordStatus(offspringId2);
        testBirthRecordStatus(offspringId3);
        testBirthRecordStatus(offspringId4);
        testBirthRecordStatus(offspringId5);
        testBirthRecordStatus(offspringId6);
        testBirthRecordStatus(offspringId7);
        testBirthRecordStatus(offspringId8);

        //test opening case.  expect INFO message b/c birth is saved as draft
        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "cases", new String[]{"Id", "date", "category", "_recordId"}, new Object[][]{
                {offspringId5, prepareDate(new Date(), 10, 0), "Clinical", "recordID"}
        }, Maps.of(
                "Id", Arrays.asList(
                        "INFO: Id has been entered in a birth or arrival form, but this form has not been finalized yet.  This might indicate a problem with the ID: " + offspringId5
                )
        ), additionalContext);

        //do updates:
        log("updating records");
        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {
            {
                put("lsid", lsidMap.get(offspringId1));
                put("QCStateLabel", "Completed");
            }
        }, false);
        testBirthRecordStatus(offspringId1);

        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {
            {
                put("lsid", lsidMap.get(offspringId3));
                put("QCStateLabel", "Completed");
            }
        }, false);
        testBirthRecordStatus(offspringId3);

        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {
            {
                put("lsid", lsidMap.get(offspringId5));
                put("QCStateLabel", "Completed");
                put("dam", damId1);
            }
        }, false);
        testBirthRecordStatus(offspringId5);

        //test opening case.  expect no warning b/c birth is now final
        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "cases", new String[]{"Id", "date", "category", "_recordId"}, new Object[][]{
                {offspringId5, prepareDate(new Date(), 10, 0), "Clinical", "recordID"}
        }, Collections.emptyMap(), additionalContext);

        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {
            {
                put("lsid", lsidMap.get(offspringId6));
                put("QCStateLabel", "Completed");
                put("dam", damId1);
            }
        }, false);
        testBirthRecordStatus(offspringId6);

        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {
            {
                put("lsid", lsidMap.get(offspringId7));
                put("QCStateLabel", "Completed");
            }
        }, false);
        testBirthRecordStatus(offspringId7);

        //edit birth date, make sure reflected in demographics
        final Calendar newBirth = Calendar.getInstance();
        newBirth.setTime(birthDate);
        newBirth.add(Calendar.DATE, -4);
        getApiHelper().updateRow("study", "birth", new HashMap<>()
        {
            {
                put("lsid", lsidMap.get(offspringId7));
                put("date", newBirth.getTime());
            }
        }, false);
        testBirthRecordStatus(offspringId7, true);
    }

    private void testBirthRecordStatus(String offspringId) throws Exception
    {
        testBirthRecordStatus(offspringId, false);
    }

    private void testBirthRecordStatus(String offspringId, boolean birthWasChanged) throws Exception
    {
        log("inspecting id: " + offspringId);

        //first query birth record
        SelectRowsCommand select1 = new SelectRowsCommand("study", "birth");
        select1.addFilter(new Filter("Id", offspringId, Filter.Operator.EQUAL));
        select1.setColumns(Arrays.asList("Id", "date", "QCState/PublicData", "birth_condition/alive", "dam", "room", "cage", "weight", "wdate"));
        SelectRowsResponse resp = select1.execute(getApiHelper().getConnection(), getContainerPath());

        org.junit.Assert.assertEquals("Birth record not created: " + offspringId, 1, resp.getRowCount().intValue());

        boolean isPublic = (Boolean) resp.getRows().get(0).get("QCState/PublicData");
        String damId = (String) resp.getRows().get(0).get("dam");
        boolean isAlive = resp.getRows().get(0).get("birth_condition/alive") == null ? true : (Boolean) resp.getRows().get(0).get("birth_condition/alive");
        String room = (String) resp.getRows().get(0).get("room");
        String cage = (String) resp.getRows().get(0).get("cage");
        Double weight = (Double) resp.getRows().get(0).get("weight");
        Date weightDate = (Date) resp.getRows().get(0).get("wdate");
        Date birthDate = (Date) resp.getRows().get(0).get("date");

        SelectRowsCommand select2 = new SelectRowsCommand("study", "demographics");
        select2.addFilter(new Filter("Id", offspringId, Filter.Operator.EQUAL));
        select2.setColumns(Arrays.asList("Id", "date", "species", "geographic_origin", "gender", "death", "birth", "calculated_status"));
        SelectRowsResponse demographicsResp = select2.execute(getApiHelper().getConnection(), getContainerPath());

        SelectRowsCommand conditionSelect = new SelectRowsCommand("study", "flags");
        conditionSelect.addFilter(new Filter("Id", offspringId, Filter.Operator.EQUAL));
        conditionSelect.addFilter(new Filter("flag/category", "Condition", Filter.Operator.EQUAL));
        conditionSelect.addFilter(new Filter("flag/value", "Nonrestricted", Filter.Operator.EQUAL));

        SelectRowsCommand groupSelect = new SelectRowsCommand("study", "animal_group_members");
        groupSelect.addFilter(new Filter("Id", offspringId, Filter.Operator.EQUAL));

        SelectRowsCommand spfFlagSelect = new SelectRowsCommand("study", "flags");
        spfFlagSelect.addFilter(new Filter("Id", offspringId, Filter.Operator.EQUAL));
        spfFlagSelect.addFilter(new Filter("flag/category", "SPF", Filter.Operator.EQUAL));

        SelectRowsCommand housingSelect = new SelectRowsCommand("study", "housing");
        housingSelect.addFilter(new Filter("Id", offspringId, Filter.Operator.EQUAL));

        SelectRowsCommand weightSelect = new SelectRowsCommand("study", "weight");
        weightSelect.addFilter(new Filter("Id", offspringId, Filter.Operator.EQUAL));

        if (!isAlive)
        {
            //if the animal was born dead, we expect these flags to be endded automatically
            groupSelect.addFilter(new Filter("enddate", null, Filter.Operator.NONBLANK));
            spfFlagSelect.addFilter(new Filter("enddate", null, Filter.Operator.NONBLANK));
            conditionSelect.addFilter(new Filter("enddate", null, Filter.Operator.NONBLANK));
            housingSelect.addFilter(new Filter("enddate", null, Filter.Operator.NONBLANK));
        }

        if (isPublic)
        {
            //we expect demographics record to be present
            org.junit.Assert.assertEquals(1, demographicsResp.getRowCount().intValue());
            Map<String, Object> demographicsRow = demographicsResp.getRows().get(0);

            // we expect species/gender to have been copied through once record is public, except for the case of dam being NULL
            if (damId != null)
            {
                org.junit.Assert.assertEquals(RHESUS, demographicsRow.get("species"));
                org.junit.Assert.assertEquals(INDIAN, demographicsRow.get("geographic_origin"));
            }

            //expect death date
            if (!isAlive)
            {
                //in our test scenario, death date always matches birth
                org.junit.Assert.assertEquals("demographics death date should match birth", birthDate, demographicsRow.get("death"));
            }
            else
            {
                //in our test scenario, death date always matches birth
                Assert.assertNull("demographics death date should be null", demographicsRow.get("death"));
            }

            org.junit.Assert.assertEquals("demographics birth date not set properly", birthDate, demographicsRow.get("birth"));

            //always expect condition = Nonrestricted
            org.junit.Assert.assertEquals(1, conditionSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());

            //test copy of SPF/groups
            if (damId != null)
            {
                //we expect infant's SPF + groups to match dam.  NOTE: filters added above for enddate, based on whether alive or not
                org.junit.Assert.assertEquals(1, groupSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
                org.junit.Assert.assertEquals(1, spfFlagSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
            }
            else
            {
                //we do not expect flags or groups
                org.junit.Assert.assertEquals(0, groupSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
                org.junit.Assert.assertEquals(0, spfFlagSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
            }

            //housing creation
            if (room != null)
            {
                org.junit.Assert.assertEquals(1, housingSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
                org.junit.Assert.assertEquals(room, housingSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("room"));
                org.junit.Assert.assertEquals(cage, housingSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("cage"));
                if (!birthWasChanged)
                {
                    //NOTE: housing is rounded to the nearest minute
                    org.junit.Assert.assertEquals(DateUtils.truncate(birthDate, Calendar.MINUTE), housingSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("date"));
                }
            }

            if (weight != null)
            {
                org.junit.Assert.assertEquals(1, weightSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
                org.junit.Assert.assertEquals(weight, weightSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("weight"));
                org.junit.Assert.assertEquals(weightDate, weightSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRows().get(0).get("date"));
            }
        }
        else
        {
            //we do not expect demographic record to exist
            org.junit.Assert.assertEquals(0, demographicsResp.getRowCount().intValue());

            //we do not expect flags or groups
            org.junit.Assert.assertEquals(0, groupSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
            org.junit.Assert.assertEquals(0, spfFlagSelect.execute(getApiHelper().getConnection(), getContainerPath()).getRowCount().intValue());
        }
    }

    @Test
    public void testFlagsApi() throws Exception
    {
        //NOTE: auto-closing of active flags is also covered by assignment test, which updates condition

        //test housing condition
        final String flag1 = ensureFlagExists("Condition", "Cond1", "201");
        final String flag2 = ensureFlagExists("Condition", "Cond2", "202");

        getApiHelper().deleteAllRecords("study", "flags", new Filter("Id", SUBJECTS[0]));

        final Date date = new Date();
        InsertRowsCommand insertRowsCommand = new InsertRowsCommand("study", "flags");
        insertRowsCommand.addRow(new HashMap<>()
        {
            {
                put("Id", SUBJECTS[0]);
                put("date", prepareDate(date, -10, 0));
                put("flag", flag1);
            }
        });
        insertRowsCommand.execute(getApiHelper().getConnection(), getContainerPath());

        //expect success
        InsertRowsCommand insertRowsCommand2 = new InsertRowsCommand("study", "flags");
        insertRowsCommand2.addRow(new HashMap<>()
        {
            {
                put("Id", SUBJECTS[0]);
                put("date", prepareDate(date, -9, 0));
                put("flag", flag2);
            }
        });
        insertRowsCommand2.execute(getApiHelper().getConnection(), getContainerPath());

        //ensure single active flag
        SelectRowsCommand select1 = new SelectRowsCommand("study", "flags");
        select1.addFilter(new Filter("Id", SUBJECTS[0]));
        select1.addFilter(new Filter("flag", flag1));
        SelectRowsResponse resp1 = select1.execute(getApiHelper().getConnection(), getContainerPath());
        Assert.assertEquals(1, resp1.getRowCount().intValue());
        Assert.assertNotNull(resp1.getRows().get(0).get("enddate"));

        //expect failure
        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "flags", new String[]{"Id", "date", "flag", "objectid", "_recordId"}, new Object[][]{
                {SUBJECTS[0], prepareDate(date, -5, 0), flag1, generateGUID(), "recordID"}
        }, Maps.of(
                "flag", Arrays.asList(
                        "ERROR: Cannot change condition to a lower code.  Animal is already: 202"
                )
        ));

        //test message is there is an overlapping matching flag
        getApiHelper().testValidationMessage(PasswordUtil.getUsername(), "study", "flags", new String[]{"Id", "date", "flag", "objectid", "_recordId"}, new Object[][]{
                {SUBJECTS[0], prepareDate(date, -5, 0), flag2, generateGUID(), "recordID"}
        }, Maps.of(
                "flag", Arrays.asList(
                        "INFO: There are already 1 active flag(s) of the same type spanning this date."
                )
        ), Maps.of("targetQC", null, "errorThreshold", "INFO"));
    }

    @Test
    public void testProceduresFormSection() throws Exception
    {
        _helper.goToTaskForm("Research Procedures", "Submit Final", false);

        log("testing add row");
        Ext4GridRef grid = _helper.getExt4GridForFormSection("Procedures");
        grid.clickTbarButton("Add");
        grid.waitForRowCount(1);
        grid.completeEdit();

        log("testing procedure remark");
        Ext4FieldRef procedure = grid.getActiveEditor(1, "procedureid");
        procedure.clickTrigger();
        click(Locator.tagContainingText("li", "Achilles Tendon Repair"));
        grid.completeEdit();

        final Object remark = grid.getFieldValue(1, "remark");
        waitFor(() -> remark != null && remark.toString().equals("Intubated with ___ ID cuffed ET tube, maintained on 1.5% isoflurane and 1 L/min oxygen. Prepared skin with PVI, lavaged with sterile saline. Prepared skin with PVI, aseptically draped. Incised over the caudolateral surface of the tendon, 5 cm. Identified the gastronemius, superficial digital flexor, and common tendon. Freshened tendon edges and apposed with 2-0 PDS with a far-near near-far pattern. Lavaged, closed fascia with 3-0 Monocryl SI. Freshened skin edges, closed with 3-0 Monocryl SI. Placed a padded bandage and fiberglas cast. Administered analgesics. Good recovery from anesthesia."),
                "Expected Remark not set", WAIT_FOR_JAVASCRIPT);

        _helper.discardForm();
    }

    @Test
    public void testArrivalForm() throws Exception
    {
        _helper.goToTaskForm("Arrival", "Submit Final", false);

        waitAndClick(Ext4Helper.Locators.ext4Button("Enable the form for data entry"));

        waitForElement(Ext4Helper.Locators.ext4Button("Submit Final"), WAIT_FOR_PAGE * 2);
        _ext4Helper.queryOne("button[text='Submit Final']", Ext4CmpRef.class).waitForEnabled();

        log("deleting existing records");
        getApiHelper().deleteAllRecords("study", "arrival", new Filter("Id", "2000;2001;2002;2003", Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "birth", new Filter("Id", "2000;2001;2002;2003", Filter.Operator.IN));
        getApiHelper().deleteAllRecords("study", "demographics", new Filter("Id", "2000;2001;2002;2003", Filter.Operator.IN));

        log("testing add series window");
        Ext4GridRef grid = _helper.getExt4GridForFormSection("Arrivals");
        grid.clickTbarButton("Add Series of IDs");
        waitForElement(Ext4Helper.Locators.window("Enter Series of IDs"));
        Ext4FieldRef.getForLabel(this, "Starting Number").setValue("2000");
        Ext4FieldRef.getForLabel(this, "Total IDs").setValue("3");
        waitAndClick(Ext4Helper.Locators.windowButton("Enter Series of IDs", "Submit"));
        grid.waitForRowCount(3);
        Assert.assertEquals("2000", grid.getFieldValue(1, "Id"));
        Assert.assertEquals("2001", grid.getFieldValue(2, "Id"));
        Assert.assertEquals("2002", grid.getFieldValue(3, "Id"));
        grid.clickTbarButton("Select All");
        grid.waitForSelected(3);

        grid.clickTbarButton("More Actions");
        click(Ext4Helper.Locators.menuItem("Bulk Edit"));
        waitForElement(Ext4Helper.Locators.window("Bulk Edit"));

        String source = "Boston";
        _helper.toggleBulkEditField("Source");

        Ext4ComboRef sourceField = _ext4Helper.queryOne("window field[fieldLabel=Source]", Ext4ComboRef.class);
        sourceField.waitForStoreLoad();
        sourceField.setComboByDisplayValue(source);

        String acquisitionType = "Acquired";
        _helper.toggleBulkEditField("Acquisition Type");

        Ext4ComboRef acquisitionTypeField = _ext4Helper.queryOne("window field[fieldLabel='Acquisition Type']", Ext4ComboRef.class);
        acquisitionTypeField.waitForStoreLoad();
        acquisitionTypeField.setComboByDisplayValue(acquisitionType);

        String gender = "female";
        _helper.toggleBulkEditField("Gender");
        _ext4Helper.queryOne("window field[fieldLabel=Gender]", Ext4ComboRef.class).setComboByDisplayValue(gender);

        String species = "Rhesus";
        _helper.toggleBulkEditField("Species");
        _ext4Helper.queryOne("window field[fieldLabel=Species]", Ext4ComboRef.class).setComboByDisplayValue(species);

        String geographic_origin = INDIAN;
        _helper.toggleBulkEditField("Geographic Origin");
        _ext4Helper.queryOne("window field[fieldLabel='Geographic Origin']", Ext4ComboRef.class).setValue(geographic_origin);

        String birth = _df.format(new Date());
        _helper.toggleBulkEditField("Birth");
        _ext4Helper.queryOne("window field[fieldLabel=Birth]", Ext4ComboRef.class).setValue(birth);

        _helper.toggleBulkEditField("Room");
        _ext4Helper.queryOne("window field[fieldLabel=Room]", Ext4ComboRef.class).setValue(ROOMS[0]);

        waitAndClick(Ext4Helper.Locators.window("Bulk Edit").append(Ext4Helper.Locators.ext4Button("Submit")));
        waitForElement(Ext4Helper.Locators.window("Set Values"));
        waitAndClick(Ext4Helper.Locators.window("Set Values").append(Ext4Helper.Locators.ext4Button("Yes")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Bulk Edit"));

        for (int i = 1; i <= 3; i++)
        {
            Assert.assertEquals("bos", grid.getFieldValue(i, "source"));
            Assert.assertEquals("f", grid.getFieldValue(i, "gender"));
            Assert.assertEquals(species, grid.getFieldValue(i, "species"));
            Assert.assertEquals(geographic_origin, grid.getFieldValue(i, "geographic_origin"));
            Assert.assertEquals(ROOMS[0], grid.getFieldValue(i, "initialRoom"));
        }

        _ext4Helper.queryOne("button[text='Submit Final']", Ext4CmpRef.class).waitForEnabled();

        waitAndClick(_helper.getDataEntryButton("Submit Final"));
        waitForElement(Ext4Helper.Locators.window("Finalize Birth/Arrival Form"));
        Locator finalizeOKButton = Ext4Helper.Locators.window("Finalize Birth/Arrival Form").append(Ext4Helper.Locators.ext4Button("Yes"));
        waitForElement(finalizeOKButton, WAIT_FOR_JAVASCRIPT);
        click(finalizeOKButton);

        waitAndClick(WAIT_FOR_JAVASCRIPT * 5, Ext4Helper.Locators.window("Success").append(Ext4Helper.Locators.ext4Button("No")), WAIT_FOR_PAGE);

        waitForElement(Locator.tagWithText("a", "Enter New Data"));

        _helper.goToTaskForm("Arrival", "Submit Final", false);
        waitAndClick(Ext4Helper.Locators.ext4Button("Enable the form for data entry"));

        waitForElement(Ext4Helper.Locators.ext4Button("Submit Final"), WAIT_FOR_PAGE * 2);
        _ext4Helper.queryOne("button[text='Submit Final']", Ext4CmpRef.class).waitForEnabled();

        ExecuteSqlCommand sc = new ExecuteSqlCommand("study");
        sc.setSql("SELECT max(CAST(Id as integer)) as expr FROM (SELECT Id FROM study.demographics WHERE isNumericId = true UNION ALL SELECT Id FROM study.birth WHERE isNumericId = true) t");
        SelectRowsResponse resp = sc.execute(getApiHelper().getConnection(), getContainerPath());
        Assert.assertEquals(1, resp.getRowCount().intValue());
        final Integer lastId = Integer.parseInt(resp.getRows().get(0).get("expr").toString()) + 1;

        grid = _helper.getExt4GridForFormSection("Arrivals");
        grid.clickTbarButton("Add");
        grid.waitForRowCount(1);
        final Ext4FieldRef field = grid.getActiveEditor(1, "Id");
        field.clickTrigger();
        waitFor(() -> field.getValue() != null && field.getValue().toString().equals(lastId.toString()),
                "Expected ID not set", WAIT_FOR_JAVASCRIPT);
        grid.completeEdit();

        _helper.discardForm();

        if (TestProperties.isTestRunningOnTeamCity() && getServerErrorCount() == 1)
        {
            String serverErrors = getServerErrors();
            if (serverErrors.contains("Long running request:"))
            {
                /* This test fails intermittently on TeamCity with something like:
                 ERROR dminController$LogAction 2018-04-11 10:36:11,464     http-nio-8111-exec-7 : Long running request:
                 Duration: 25.069
                 Form Type: arrival
                 TaskId: 90D60DA0-1FA1-1036-9988-033051EFCC79
                 Status: 200
                 Error Count: 3
                 Total Commands: 3
                 Validate Only: true
                 Total Rows: 3 (8.356333333333334 sec/row)
                 User: teamcity@labkey.test
                 ReferrerURL: http://localhost:8111/labkey/ONPRC_EHR_TestProject2/ehr-dataEntryForm.view?formType=arrival
                 *
                 * The error threshold is 25s and test test hovers around that mark on TeamCity
                 * Since the real-world performance of this form is nowhere near that slow, we increase the threshold
                 * for long-running requests when running on TeamCity
                 */
                Pattern errorPattern = Pattern.compile("^Duration: (?<duration>\\d+\\.?\\d*)", Pattern.MULTILINE);
                Matcher errorMatcher = errorPattern.matcher(serverErrors);
                if (errorMatcher.find())
                {
                    double duration = Double.parseDouble(errorMatcher.group("duration"));
                    if (duration < 50)
                    {
                        log("Ignoring long running request: " + errorMatcher.group());
                        resetErrors();
                    }
                    // Leave errors for standard error handling if the duration exceeds the increased threshold
                }
            }
        }
    }

    @Test
    public void testPairingObservations() throws Exception
    {
        _helper.goToTaskForm("Pairing Observations");
        ensureRoomExists(ROOMS[0]);
        ensureRoomExists(ROOMS[2]);

        //test whether pairid properly assigned, including when room/cage changed
        Ext4GridRef grid = _helper.getExt4GridForFormSection("Pairing Observations");
        _helper.addRecordToGrid(grid);
        grid.setGridCell(1, "Id", SUBJECTS[0]);
        grid.setGridCell(1, "lowestcage", "A1");
        grid.setGridCell(1, "room", ROOMS[0]);
        grid.setGridCell(1, "cage", "A1");

        _helper.addRecordToGrid(grid);
        sleep(200);
        grid.setGridCell(2, "Id", SUBJECTS[1]);
        grid.setGridCell(2, "lowestcage", "A1");
        grid.setGridCell(2, "room", ROOMS[0]);
        grid.setGridCell(2, "cage", "A1");

        Assert.assertEquals(grid.getFieldValue(1, "pairid"), grid.getFieldValue(2, "pairid"));

        //should update pairId
        grid.setGridCell(2, "room", ROOMS[2]);
        sleep(200);
        Assert.assertNotEquals("Pair ID doesn't match, 1: " + grid.getFieldValue(1, "pairid") + ", 2: " + grid.getFieldValue(2, "pairid"), grid.getFieldValue(1, "pairid"), grid.getFieldValue(2, "pairid"));

        _helper.addRecordToGrid(grid);
        sleep(200);
        grid.setGridCell(3, "Id", SUBJECTS[2]);
        grid.setGridCell(3, "lowestcage", "A2");
        grid.setGridCell(3, "room", ROOMS[0]);
        grid.setGridCell(3, "cage", "A2");
        sleep(100);
        Assert.assertNotEquals(grid.getFieldValue(1, "pairid"), grid.getFieldValue(3, "pairid"));

        grid.setGridCell(3, "lowestcage", "A1");
        sleep(100);
        Assert.assertEquals(grid.getFieldValue(1, "pairid"), grid.getFieldValue(3, "pairid"));
        sleep(200);
        _helper.discardForm();
    }

    @Test
    public void testManageTreatment() throws Exception
    {
        getApiHelper().deleteAllRecords("study", "demographics", new Filter("Id", SUBJECTS[0]));
        getApiHelper().deleteAllRecords("study", "treatment_order", new Filter("Id", SUBJECTS[0]));

        //create records
        log("Creating test subjects");
        SimplePostCommand insertCommand = getApiHelper().prepareInsertCommand("study", "demographics", "lsid", new String[]{"Id", "Species", "Birth", "Gender", "date", "calculated_status"}, new Object[][]{
                {SUBJECTS[0], "Rhesus", (new Date()).toString(), "m", new Date(), "Alive"}
        });
        getApiHelper().doSaveRows(PasswordUtil.getUsername(), insertCommand, getExtraContext());

        goToProjectHome();
        waitAndClickAndWait(Locator.linkWithText("Animal History"));

        String query = "textfield[itemId=subjArea]";
        _helper.waitForCmp(query);

        AnimalHistoryPage historyPage = new AnimalHistoryPage(getDriver());
        historyPage.searchSingleAnimal(SUBJECTS[0]);
        waitForText("Overview: " + SUBJECTS[0]);
        waitForTextToDisappear("Loading...");

        historyPage.clickCategoryTab("Clinical");
        historyPage.clickReportTab("Clinical Snapshot");

        waitForElement(Locator.tagContainingText("div", "Previous 2 Years:")); //proxy for weight load
        waitForElement(Locator.tagContainingText("b", "Current Medications / Prescribed Diets:"));

        // manage treatments
        waitAndClick(Ext4Helper.Locators.ext4Button("Actions"));
        waitAndClick(Ext4Helper.Locators.menuItem("Manage Treatments"));

        waitForElement(Ext4Helper.Locators.window("Manage Treatments: " + SUBJECTS[0]));
        waitAndClick(Ext4Helper.Locators.ext4Button("Order Treatment"));
        waitAndClick(Ext4Helper.Locators.menuItem("Clinical Treatment"));

        waitForElement(Ext4Helper.Locators.window("Treatment Orders"));
        waitForElement(Ext4Helper.Locators.window("Treatment Orders").append(Locator.tagWithText("div", SUBJECTS[0]))); //a proxy for the form initially loading

        // there is a timing issue on TeamCity related to setting the enddate field.
        // i am guessing that it has to do with the form initially validating and loading from
        // the server.  if the timing is bad, the test might attempt to set the datefield at the same time, erasing that value
        _ext4Helper.queryOne("window[title=Treatment Orders] fieldcontainer[fieldLabel='End Date']", Ext4FieldRef.class).waitForEnabled();

        final Ext4FieldRef qcField = _ext4Helper.queryOne("window[title=Treatment Orders] field[fieldLabel='Status']", Ext4FieldRef.class);
        waitFor(() -> qcField.getValue() != null, "QCState field was never set", WAIT_FOR_JAVASCRIPT);

        sleep(500);

        getFieldInWindow("Charge To", Ext4FieldRef.class).getEval("expand()");
        waitAndClick(Locator.tag("li").append(Locator.tagContainingText("span", "Other")));
        waitForElement(Ext4Helper.Locators.window("Choose Project"));
        _ext4Helper.queryOne("window[title=Choose Project] [fieldLabel='Project']", Ext4ComboRef.class).setComboByDisplayValue(PROJECT_ID);
        waitAndClick(Ext4Helper.Locators.window("Choose Project").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));

        String dateVal = _tf.format(prepareDate(DateUtils.truncate(new Date(), Calendar.DATE), 1, 20));
        log("setting end date field: " + dateVal);
        _ext4Helper.queryOne("window[title=Treatment Orders] fieldcontainer[fieldLabel='End Date']", Ext4FieldRef.class).setValue(dateVal);
        sleep(500);
        Assert.assertNotNull("Unable to set enddate field to: " + dateVal, _ext4Helper.queryOne("window[title=Treatment Orders] fieldcontainer[fieldLabel='End Date']", Ext4FieldRef.class).getDateValue());

        Ext4ComboRef treatmentField = getFieldInWindow("Treatment", Ext4ComboRef.class);
        treatmentField.getEval("expand()");
        treatmentField.waitForStoreLoad();
        treatmentField.setValue("E-YY035");
        treatmentField.getEval("collapse()");
        sleep(200);
        Ext4ComboRef combo = getFieldInWindow("Frequency", Ext4ComboRef.class);
        Assert.assertEquals("BID - AM/Night", combo.getDisplayValue());
        Assert.assertEquals("PO", getFieldInWindow("Route", Ext4FieldRef.class).getValue());
        Assert.assertEquals(32L, _ext4Helper.queryOne("window[title=Treatment Orders] [name='concentration']", Ext4FieldRef.class).getValue());
        Assert.assertEquals("mg/ml", _ext4Helper.queryOne("window[title=Treatment Orders] [name='conc_units']", Ext4FieldRef.class).getValue());
        Assert.assertEquals(8L, _ext4Helper.queryOne("window[title=Treatment Orders] [name='dosage']", Ext4FieldRef.class).getValue());
        Assert.assertEquals("mg/kg", _ext4Helper.queryOne("window[title=Treatment Orders] [name='dosage_units']", Ext4FieldRef.class).getValue());
        Assert.assertEquals("mg", _ext4Helper.queryOne("window[title=Treatment Orders] [name='amount_units']", Ext4FieldRef.class).getValue());
        Assert.assertEquals("mL", _ext4Helper.queryOne("window[title=Treatment Orders] [name='vol_units']", Ext4FieldRef.class).getValue());

        _ext4Helper.queryOne("window[title=Treatment Orders] [name='volume']", Ext4FieldRef.class).clickTrigger();
        waitForElement(Ext4Helper.Locators.window("Review Drug Amounts"));
        _ext4Helper.queryOne("field[fieldName=weight][recordIdx=0]", Ext4FieldRef.class).setValue(10);
        waitAndClick(Ext4Helper.Locators.window("Review Drug Amounts").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Review Drug Amounts"));

        Assert.assertEquals(80L, _ext4Helper.queryOne("window[title=Treatment Orders] [name='amount']", Ext4FieldRef.class).getValue());

        waitAndClick(Ext4Helper.Locators.window("Treatment Orders").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Treatment Orders"));
        waitForElement(Locator.tagContainingText("div", "2.5 mL / 80 mg"));  //proxy for record in grid
        waitAndClick(Locator.tag("img").withClass("x4-action-col-icon"));
        waitAndClick(Ext4Helper.Locators.menuItem("Edit Treatment").notHidden());
        waitForElement(Ext4Helper.Locators.window("Treatment Orders").notHidden());
        waitForElement(Ext4Helper.Locators.window("Treatment Orders").append(Locator.tagWithText("div", SUBJECTS[0])).notHidden());
        waitAndClick(Ext4Helper.Locators.window("Treatment Orders").append(Ext4Helper.Locators.ext4ButtonEnabled("Cancel")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Treatment Orders"));

        waitAndClick(Locator.tag("img").withClass("x4-action-col-icon"));
        waitAndClick(Ext4Helper.Locators.menuItem("Change End Date").notHidden());
        waitForElement(Ext4Helper.Locators.window("Change End Date"));
        waitForElement(Ext4Helper.Locators.window("Change End Date").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        Date enddate = prepareDate(new Date(), 10, 0);
        Ext4FieldRef enddateField2 = _ext4Helper.queryOne("window[title='Change End Date'] [fieldLabel='End Date']", Ext4FieldRef.class);
        enddateField2.setValue(_tf.format(enddate));
        sleep(100);
        Assert.assertNotNull("End date was not set.  Expected: " + _tf.format(enddate), enddateField2.getValue());

        waitAndClick(Ext4Helper.Locators.window("Change End Date").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Change End Date"));
        waitForElement(Locator.tagContainingText("div", _tf.format(enddate)));  //proxy for record in grid

        waitAndClick(Ext4Helper.Locators.window("Manage Treatments: " + SUBJECTS[0]).append(Ext4Helper.Locators.ext4ButtonEnabled("Close")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Manage Treatments: " + SUBJECTS[0]));

    }

    @Test
    public void testManageCases() throws Exception
    {
        getApiHelper().deleteAllRecords("study", "demographics", new Filter("Id", SUBJECTS[0]));
        getApiHelper().deleteAllRecords("study", "cases", new Filter("Id", SUBJECTS[0]));

        //create vet user
        goToEHRFolder();
        _permissionsHelper.setUserPermissions(DATA_ADMIN.getEmail(), "EHR Veterinarian");

        //create records
        log("Creating test subjects");
        SimplePostCommand insertCommand = getApiHelper().prepareInsertCommand("study", "demographics", "lsid", new String[]{"Id", "Species", "Birth", "Gender", "date", "calculated_status"}, new Object[][]{
                {SUBJECTS[0], "Rhesus", (new Date()).toString(), "m", new Date(), "Alive"}
        });
        getApiHelper().doSaveRows(PasswordUtil.getUsername(), insertCommand, getExtraContext());

        waitAndClickAndWait(Locator.linkWithText("Animal History"));

        String query = "textfield[itemId=subjArea]";
        _helper.waitForCmp(query);

        AnimalHistoryPage historyPage = new AnimalHistoryPage(getDriver());
        historyPage.searchSingleAnimal(SUBJECTS[0]);
        waitForText("Overview: " + SUBJECTS[0]);
        waitForTextToDisappear("Loading...");

        historyPage.clickCategoryTab("Clinical");
        historyPage.clickReportTab("Clinical Snapshot");

        waitForElement(Locator.tagContainingText("div", "Previous 2 Years:")); //proxy for weight load
        waitForElement(Locator.tagContainingText("b", "Current Medications / Prescribed Diets:"));

        // manage cases
        waitAndClick(Ext4Helper.Locators.ext4Button("Actions"));
        waitAndClick(Ext4Helper.Locators.menuItem("Manage Cases"));

        waitForElement(Ext4Helper.Locators.window("Manage Cases: " + SUBJECTS[0]));

        waitAndClick(Ext4Helper.Locators.ext4Button("Open Case"));
        waitAndClick(Ext4Helper.Locators.menuItem("Open Surgery Case"));

        waitForElement(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]));
        waitForElement(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]).append(Locator.tagWithText("div", "Surgery")));
        String description = "This is a surgery case";
        Ext4FieldRef.getForLabel(this, "Description/Notes").setValue(description);

        waitAndClick(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]).append(Ext4Helper.Locators.ext4ButtonEnabled("Open Case")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]));
        waitForElement(Locator.tagWithText("div", description));

        waitAndClick(Locator.tag("img").withClass("x4-action-col-icon"));
        waitAndClick(Ext4Helper.Locators.menuItem("Close With Reopen Date").notHidden());
        Ext4CmpRef.waitForComponent(this, "field[fieldLabel=Reopen Date]");
        Ext4FieldRef.getForLabel(this, "Reopen Date").setValue(_df.format(prepareDate(new Date(), 28, 0)));
        waitAndClick(Ext4Helper.Locators.window("Close With Reopen Date").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Close With Reopen Date"));
        waitForElement(Locator.tagWithText("div", _df.format(prepareDate(new Date(), 28, 0))));

        //now clinical case
        waitAndClick(Ext4Helper.Locators.ext4Button("Open Case"));
        waitAndClick(Ext4Helper.Locators.menuItem("Open Clinical Case"));

        waitForElement(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]));
        waitForElement(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]).append(Locator.tagWithText("div", "Clinical")));
        Ext4ComboRef vetField = Ext4ComboRef.getForLabel(this, "Assigned Vet");
        vetField.setComboByDisplayValue("admin");

        waitAndClick(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]).append(Ext4Helper.Locators.ext4ButtonEnabled("Open & Immediately Close")));
        sleep(1000);
        waitAndClick(Ext4Helper.Locators.menuItem("Close With Reopen Date").notHidden());
        waitForElement(Ext4Helper.Locators.window("Error"));
        waitAndClick(Ext4Helper.Locators.window("Error").append(Ext4Helper.Locators.ext4ButtonEnabled("OK")));
        waitForElementToDisappear(Ext4Helper.Locators.window("Error"));

        Ext4FieldRef problemField = Ext4FieldRef.getForLabel(this, "Problem");
        Ext4FieldRef subProblemField = Ext4FieldRef.getForLabel(this, "Subcategory");
        assertTrue(subProblemField.isDisabled());
        problemField.setValue("Behavioral");
        sleep(200);
        Assert.assertFalse(subProblemField.isDisabled());
        subProblemField.setValue("Alopecia");

        waitAndClick(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]).append(Ext4Helper.Locators.ext4ButtonEnabled("Open & Immediately Close")));
        waitAndClick(Ext4Helper.Locators.menuItem("Close With Reopen Date").notHidden());
        Ext4FieldRef.waitForField(this, "Reopen Date");
        waitAndClick(Ext4Helper.Locators.ext4ButtonEnabled("Submit"));

        waitForElementToDisappear(Ext4Helper.Locators.window("Open Case: " + SUBJECTS[0]));
        waitForElement(Locator.tagWithText("div", "Behavioral: Alopecia"));

        waitAndClick(Ext4Helper.Locators.ext4ButtonEnabled("Close"));
        waitForElementToDisappear(Ext4Helper.Locators.window("Manage Cases: " + SUBJECTS[0]));
    }

    @Test
    public void testFormTriggers()
    {
        String aliveAnimal = "99998";
        String deadAnimal = "99999"; //Mark an animal dead.

        Map<String, Map<String, String>> formsToTest = Map.of(
                "Birth", Map.of("allowDatesInDistantPast", "true", "allowFutureDates", "true", "allowDeadIds", "true", "allowAnyId", "true"),
                "Death", Map.of("allowDatesInDistantPast", "true", "allowFutureDates", "true", "allowDeadIds", "true", "allowAnyId", "true"),
                "Arrival", Map.of("allowDatesInDistantPast", "true", "allowFutureDates", "true", "allowDeadIds", "true", "allowAnyId", "true"),
                "Departure", Map.of("allowDatesInDistantPast", "true", "allowFutureDates", "true", "allowDeadIds", "true", "allowAnyId", "true"),
                "Housing Transfers", Map.of("allowDatesInDistantPast", "true", "allowFutureDates", "true", "allowDeadIds", "true", "allowAnyId", "true"));

        goToEHRFolder();
        clickAndWait(Locator.linkWithText("Enter Data / Task Review"));
        for (Map.Entry<String, Map<String, String>> form : formsToTest.entrySet())
        {
            clickAndWait(Locator.linkWithText(form.getKey()));
            enableForm();
            Ext4GridRef grid;
            if(form.getKey().equals("Housing Transfers"))
                grid = _helper.getExt4GridForFormSection(form.getKey());
            else
                grid = _helper.getExt4GridForFormSection(form.getKey() + "s");
            _helper.addRecordToGrid(grid);
            if (form.getValue().get("allowDeadIds").equals("true"))
            {
                grid.setGridCell(1, "Id", deadAnimal);
                Assert.assertFalse("Dead animal should be present", isTextPresent(""));
            }
            if (form.getValue().get("allowAnyId").equals("true"))
            {
                grid.setGridCell(1, "Id", aliveAnimal);
                //verify error message
            }
            if (form.getValue().get("allowDatesInDistantPast").equals("true"))
            {
                grid.setGridCell(1, "date", LocalDateTime.now().minusDays(90).format(_dateTimeFormatter));
                Assert.assertTrue("Missing error message", isTextPresent(""));
                grid.setGridCell(1, "date", LocalDateTime.now().minusDays(50).format(_dateTimeFormatter));
                Assert.assertFalse("Missing error message", isTextPresent(""));
            }
            if (form.getValue().get("allowFutureDates").equals("true"))
            {
                grid.setGridCell(1, "date", LocalDateTime.now().plusDays(2).format(_dateTimeFormatter));
                Assert.assertTrue("Missing error message", isTextPresent(""));
                grid.setGridCell(1, "date", LocalDateTime.now().format(_dateTimeFormatter));
                Assert.assertFalse("Missing error message", isTextPresent(""));
            }
            _helper.discardForm();
        }
    }

    private void enableForm()
    {
        if (Locator.linkWithText("Enable the form for data entry").isDisplayed(getDriver()))
        {
            Ext4Helper.Locators.ext4Button("Enable the form for data entry").findElement(getDriver()).click();
            waitForElement(Locator.linkWithText("Exit data entry"));
        }
    }
    //TODO: @Test
    public void vetReviewTest()
    {
        // mark vet review

        // add/replace SOAP
    }

    //TODO: @Test
    public void housingApiTest()
    {
        //TODO: cage size validation

        //auto-update of dividers

        //open-ended, dead ID

        //dead Id, non-open ended

        //mark requested completed

        //auto-set housingCondition, housingType on row
    }

    //TODO: @Test
    public void clinicalRoundsTest()
    {

        //TODO: test cascade update + delete.

        // test row editor
    }

    //TODO: @Test
    public void surgicalRoundsTest()
    {
        //_helper.goToTaskForm("Surgical Rounds");

        //Ext4GridRef obsGrid = _helper.getExt4GridForFormSection("Observations");
        //_helper.addRecordToGrid(obsGrid);

        //TODO: test cascade update + delete

        //TODO: test 'bulk close cases' button

        //_helper.discardForm();
    }

    //TODO: @Test
    public void pathTissuesTest()
    {
        _helper.goToTaskForm("Pathology Tissues");

        //TODO: tissue helper, also copy from previous
    }

    //TODO: @Test
    public void bulkUploadsTest()
    {
        //TODO: batch clinical entry form, bulk upload

        //TODO: aux procedure form, bulk upload

        //TODO: blood request form, excel upload

        //TODO: weight form, bulk upload
    }

    @Test
    public void testTreatmentToDrugETL() throws IOException, CommandException
    {
        LocalDateTime beginDate = LocalDateTime.now().withHour(0).withMinute(0);
        LocalDateTime endDate = LocalDateTime.now().withHour(0).withMinute(0).plusDays(2);
        String animalId = "12345";

        log("Creating the Treatment order request");
        goToProjectHome();
        clickAndWait(Locator.linkWithText("Enter Data / Task Review"));
        waitAndClickAndWait(Locator.linkWithText("Medications/Diet"));

        addTreatmentOrder(animalId, beginDate, endDate, "640991", "ACETAMINOPHEN (80mg) (E-77510)",
                "BID - AM/Night", "PO", "tablet(s)", 10, "mg");

        shortWait().until(ExpectedConditions.elementToBeClickable(Locator.tagWithText("span", "Submit Final")));
        clickButton("Submit Final", 0);
        _billingHelper.checkMessageWindow("Finalize Form", "You are about to finalize this form. Do you want to do this?", "Yes");
        waitForElement(Locator.linkWithText("Medications/Diet"));

        log("Verifying request was created");
        goToSchemaBrowser();
        DataRegionTable table = viewQueryData("study", "treatment_order");
        table.setFilter("Id", "Equals", animalId);
        checker().verifyEquals("Treatment order is not placed", 1, table.getDataRowCount());

        log("Running the treatment to drug ETL");
        goToModule("DataIntegration");
        _etlHelper.runTransformAndWait("{ONPRC_EHR}/TreatmentToDrug", BaseWebDriverTest.MAX_WAIT_SECONDS * 1000);

        log("Verifying the drug table was populated");
        goToSchemaBrowser();
        table = viewQueryData("study", "drug");
        table.setFilter("Id", "Equals", animalId);
        checker().verifyEquals("ETL did not populate the study.drug", 2, table.getDataRowCount());
    }

    @Test
    public void bloodRequestTest() throws IOException, CommandException
    {
        LocalDateTime now = LocalDateTime.now();
        String animalId = "12345";

        log("Inserting the charge unit necessary for blood draw request");
        InsertRowsCommand chargeUnitCommand = new InsertRowsCommand("onprc_billing", "chargeUnits");
        chargeUnitCommand.addRow(Map.of("chargetype", "ChargeUnit2", "servicecenter", "ServiceCenter2", "shownInBlood", true, "active", true));
        chargeUnitCommand.execute(getApiHelper().getConnection(), getContainerPath());

        log("Inserting the data in available blood volume");
        goToSchemaBrowser();
        DataRegionTable ABVTable = viewQueryData("onprc_ehr", "AvailableBloodVolume");
        ABVTable.clickInsertNewRow();
        setFormElement(Locator.name("quf_datecreated"), now.toString());
        setFormElement(Locator.name("quf_id"), animalId);
        setFormElement(Locator.name("quf_ABV"), "10");
        setFormElement(Locator.name("quf_dsrowid"), "1");
        clickButton("Submit");


        log("Creating the blood draw request");
        goToProjectHome();
        clickAndWait(Locator.linkWithText("Manage Requests"));
        waitAndClickAndWait(Locator.linkWithText("ASB SERVICES REQUEST"));
        addBloodDrawRequest(animalId, now, "795644", "Heparin", 12);

        checker().withScreenshot("Blood request").verifyTrue("Expected error is not present", isAnyTextPresent(
                "Row 1, # of Tubes: ERROR: The quantity requested, 12.0ml exceeds the available blood volume, 10.0ml for AnimalId: 12345"));

        //Updating the total volume below the the available blood volume.
        updateTotalVolume(8);

        shortWait().until(wd -> elementIfEnabled(ext4Button("Request").findElement(getDriver()))).click();
        waitForText("My Pending Requests");

        DataRegionTable table = new DataRegionTable("study|blood", getDriver());
        checker().verifyEquals("New blood draw request is not created", 1, table.getDataRowCount());

    }

    @Test
    public void clinicalHistoryXML() throws IOException, CommandException
    {
        GetCommand getCommand = new GetCommand("ehr", "getClinicalHistory") {
            @Override
            protected HttpGet createRequest(URI uri)
            {
                return new HttpGet(uri);
            }

            @Override
            protected Map<String, Object> createParameterMap()
            {
                Map<String, Object> params = super.createParameterMap();

                params.put("subjectIds", "12345");
                params.put("minDate", "2000-01-01");
                params.put("maxDate", new Date());
                params.put("respFormat", "XML");

                return params;
            }
        };

        CommandResponse response = getCommand.execute(getApiHelper().getConnection(), getContainerPath());
        String xml = response.getText();

        assertTrue("Expected XML to contain <response>", StringUtils.countMatches(xml, "<response>") == 1);
        assertTrue("Expected XML to contain <html> for 8 rows", StringUtils.countMatches(xml, "<html>") == 8);
        assertTrue("Expected XML to contain <publicData> for 8 rows", StringUtils.countMatches(xml, "<publicData>") == 8);
        assertTrue("Expected XML to contain <type>Clinical</type> for 3 clinical entries", StringUtils.countMatches(xml, "<type>Clinical</type>") == 3);
        assertTrue("Expected XML to contain <source>Housing Transfer</source> for 2 housing moves", StringUtils.countMatches(xml, "<source>Housing Transfer</source>") == 2);

    }

    private void addBloodDrawRequest(String animalId, LocalDateTime date, String project, String tube_type, Integer quantity)
    {
        Ext4GridRef bloodDraw = _helper.getExt4GridForFormSection("Blood Draws");
        _helper.addRecordToGrid(bloodDraw);
        scrollIntoView(Locator.tagWithText("span", "Blood Draws"));
        int index = bloodDraw.getRowCount();

        bloodDraw.setGridCellJS(index, "date", date.format(DateTimeFormatter.ofPattern(DATE_TIME_FORMAT_STRING)));
        bloodDraw.setGridCell(index, "Id", animalId);

        bloodDraw.setGridCell(index, "quantity", quantity.toString());
        bloodDraw.setGridCell(index, "tube_type", tube_type);
        addProjectToTheRow(bloodDraw, index, project);
    }

    private void addTreatmentOrder(String animalId, LocalDateTime beginDate, LocalDateTime endDate, String project, String treatment, String frequency, String route,
                                   String volUnits, Integer amount, String amountUnits)
    {
        Ext4GridRef treatmentOrder = _helper.getExt4GridForFormSection("Medication/Treatment Orders");
        _helper.addRecordToGrid(treatmentOrder);
        scrollIntoView(Locator.tagWithText("span", "Medication/Treatment Orders"));
        int index = treatmentOrder.getRowCount();

        treatmentOrder.setGridCell(index, "Id", animalId);
        treatmentOrder.setGridCellJS(index, "date", beginDate.toString());
        treatmentOrder.setGridCellJS(index, "enddate", endDate.toString());
        addProjectToTheRow(treatmentOrder, index, project);
        treatmentOrder.setGridCell(index, "code", treatment);
        treatmentOrder.setGridCell(index, "frequency", frequency);
        treatmentOrder.setGridCell(index, "route", route);
        treatmentOrder.setGridCell(index, "vol_units", volUnits);
        treatmentOrder.setGridCell(index, "amount", amount.toString());
        treatmentOrder.setGridCell(index, "amount_units", amountUnits);
    }

    private void updateTotalVolume(Integer quantity)
    {
        Ext4GridRef bloodDraw = _helper.getExt4GridForFormSection("Blood Draws");
        int index = bloodDraw.getRowCount();
        bloodDraw.setGridCell(index, "quantity", quantity.toString());
    }

    private void addProjectToTheRow(Ext4GridRef gridRef, int index, String project)
    {
        gridRef.clickDownArrowOnGrid(index, "project");
        waitAndClick(Locator.tag("li").append(Locator.tagContainingText("span", "Other")));
        waitForElement(Ext4Helper.Locators.window("Choose Project"));
        _ext4Helper.queryOne("window[title=Choose Project] [fieldLabel='Project']", Ext4ComboRef.class).setComboByDisplayValue(project);
        waitAndClick(Ext4Helper.Locators.window("Choose Project").append(Ext4Helper.Locators.ext4ButtonEnabled("Submit")));
    }

    //TODO: @Test
    public void treatmentScheduleTest()
    {
        // add treatments of different frequencies, including partial days.

        // make sure query works as expected

        // open task, use 'add scheduled treatments' helper
    }

    //TODO: @Test
    public void auxProceduresTest()
    {
        // test copy previous task
    }

    //TODO: @Test
    public void gridErrorsTest()
    {
        //TODO: make sure fields turn red as expected
    }

    @Override
    protected String getAnimalHistoryPath()
    {
        return ANIMAL_HISTORY_URL;
    }
}
