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
import org.labkey.remoteapi.query.UpdateRowsCommand;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.ONPRC;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.PortalHelper;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;
import org.labkey.test.util.ext4cmp.Ext4GridRef;

import javax.annotation.Nullable;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import static org.labkey.test.util.Ext4Helper.TextMatchTechnique.CONTAINS;

@Category({EHR.class, ONPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 20)
public class ONPRC_BillingTest extends AbstractONPRC_EHRTest
{
    protected static String PROJECT_NAME = "ONPRC_Billing_TestProject";
    private static final String BILLING_FOLDER_PATH = "/" + PROJECT_NAME + "/" + BILLING_FOLDER;
    private static final String EHR_FOLDER_PATH = "/" + PROJECT_NAME + "/" + FOLDER_NAME;
    private static int counter = 1;
    private static int jobCounter = 1;
    private final String ANIMAL_HISTORY_URL = "/ehr/" + getProjectName() + "/animalHistory.view?";
    protected DateTimeFormatter _dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @BeforeClass
    @LogMethod
    public static void setupProject() throws Exception
    {
        ONPRC_BillingTest initTest = (ONPRC_BillingTest) getCurrentTest();
        initTest.doSetUp();
    }

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

    private void doSetUp() throws Exception
    {
        initProject();
        goToProjectHome();
        createTestSubjects();
        createBirthRecords();

        _containerHelper.createSubfolder(getProjectName(), getProjectName(), BILLING_FOLDER, "Collaboration", null);
        clickFolder(BILLING_FOLDER);
        _containerHelper.enableModules(Arrays.asList("ONPRC_EHR", "EHR_Billing", "ONPRC_Billing", "ONPRC_BillingPublic"));

        PortalHelper _portalHelper = new PortalHelper(getDriver());
        _portalHelper.addWebPart("ONPRC Finance");
        _portalHelper.moveWebPart("Finance", PortalHelper.Direction.UP);
    }

    @Test
    public void testNotifications()
    {
        setupNotificationService();

        //run finance notifications
        Set<String> notifications = new HashSet<>();
        notifications.add("DCM Finance Notification");
        notifications.add("Finance Notification");

        beginAt(WebTestHelper.getBaseURL() + "/ldk/" + getContainerPath() + "/notificationAdmin.view");
        int count = Locator.tagContainingText("a", "Run Report In Browser").findElements(getDriver()).size();
        for (int i = 0; i < count; i++)
        {
            Locator link = Locator.tagContainingText("a", "Run Report In Browser").index(i);
            Locator label = Locator.tag("div").withClass("ldk-notificationlabel").index(i);
            waitForElement(label);
            String notificationName = label.findElement(getDriver()).getText();
            Assert.assertNotNull(notificationName);
            if (notifications.contains(notificationName))
            {
                log("running notification: " + notificationName);
                waitAndClick(WAIT_FOR_JAVASCRIPT, link, WAIT_FOR_PAGE * 3);
                waitForText("The notification email was last sent on:");
                assertTextNotPresent("not configured");

                //avoid unnecessary reloading
                beginAt(WebTestHelper.getBaseURL() + "/ldk/" + getContainerPath() + "/notificationAdmin.view");
            }
        }
    }

    @Test
    public void testBillingPipeline()
    {
        beginAt(WebTestHelper.getBaseURL() + "/onprc_billing/" + getContainerPath() + "/financeManagement.view");
        waitAndClickAndWait(Locator.linkContainingText("Perform Billing Run"));
        Ext4FieldRef.waitForField(this, "Start Date");
        Ext4FieldRef.getForLabel(this, "Start Date").setValue("1/1/10");
        Ext4FieldRef.getForLabel(this, "End Date").setValue("1/31/10");
        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Ext4Helper.Locators.window("Success"));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("OK"));
        waitAndClickAndWait(Locator.linkWithText("All"));
        waitForPipelineJobsToComplete(++jobCounter, "Billing Run", false);

        //TODO: test results
    }

    @Test
    public void testDiscrepancyReport() throws IOException, CommandException
    {
        String animalId1 = "12345";
        String animalId2 = "23456";
        goToProjectHome(PROJECT_NAME);
        updateBirthDate(animalId1);
        updateBirthDate(animalId2);
        String chargeUnit = insertBillingAndHousingTables();
        insertBloodDraws(animalId1);
        insertDrugRecord(animalId1);
        setupNotificationService();

        navigateToFolder(getProjectName(), BILLING_FOLDER);
        waitAndClickAndWait(Locator.linkWithText("Enter New Charges"));
        Map<String, String> miscChargesValue = new LinkedHashMap<>();
        miscChargesValue.put("Id", animalId1);
        miscChargesValue.put("date", LocalDateTime.now().minusYears(2).format(_dateTimeFormatter));
        miscChargesValue.put("project", PROJECT_ID);
        miscChargesValue.put("debitedaccount", "A11");
        miscChargesValue.put("chargetype", chargeUnit);
        miscChargesValue.put("chargeId", "Vaccine supplies");
        miscChargesValue.put("quantity", "10");
        enterChargesInGrid(1, miscChargesValue);
        submitForm();

        performBillingRun(LocalDateTime.now().minusYears(12).format(_dateTimeFormatter), LocalDateTime.now().minusYears(11).format(_dateTimeFormatter));
        navigateToFolder(getProjectName(), BILLING_FOLDER);
        waitAndClickAndWait(Locator.linkWithText("Billing Period Summary / Discrepancy Report"));
        String expectedContent = "Category # Items Amount\n" +
                "Lease Fees 6.0 $0.00\n" +
                "Other Charges 40.0 $0.00\n" +
                "Per Diems 2002.0 $0.00\n" +
                "Procedure Charges 4.0 $0.00\n" +
                "SLA Per Diems 0.0 $0.00";
        Assert.assertEquals("Incorrect information in the charge summary table", expectedContent, Locator.tag("table").findElements(getDriver()).get(0).getText());
    }

    private void updateBirthDate(String animalId) throws IOException, CommandException
    {
        log("Updating birth date for animal " + animalId);

        SelectRowsCommand demoSelect = new SelectRowsCommand("study", "demographics");
        demoSelect.addFilter(new Filter("participantid", animalId));
        demoSelect.setColumns(Arrays.asList("participantid", "lsid", "birth"));
        SelectRowsResponse demoResp = demoSelect.execute(getApiHelper().getConnection(), getContainerPath());
        final String demoLsid = (String) demoResp.getRows().get(0).get("lsid");

        UpdateRowsCommand demoUpdateCmd = new UpdateRowsCommand("study", "demographics");
        demoUpdateCmd.addRow(new HashMap<String, Object>()
        {
            {
                put("lsid", demoLsid);
                put("birth", LocalDate.parse("2005-05-05"));
            }
        });
        demoUpdateCmd.execute(getApiHelper().getConnection(), getContainerPath());
    }

    private int insertHousingType() throws IOException, CommandException
    {
        log("Inserting Housing Type");
        InsertRowsCommand housingTypeCmd = new InsertRowsCommand("ehr_lookups", "housingTypes");
        housingTypeCmd.addRow(Map.of("value", "housingType1", "title", "Housing Type 1"));
        CommandResponse housingTypeResp = housingTypeCmd.execute(getApiHelper().getConnection(), getContainerPath());
        return getCommandResponseRowId(housingTypeResp, 0);
    }

    private int insertHousingDefinition() throws IOException, CommandException
    {
        log("Inserting Housing Type");
        InsertRowsCommand housingDefCmd = new InsertRowsCommand("ehr_lookups", "housingDefinition");
        housingDefCmd.addRow(Map.of("value", "Room with multiple cages"));
        CommandResponse housingTypeResp = housingDefCmd.execute(getApiHelper().getConnection(), getContainerPath());
        return getCommandResponseRowId(housingTypeResp, 0);
    }

    @Override
    protected boolean doSetUserPasswords()
    {
        return true;
    }

    private void insertDrugRecord(String animalId) throws IOException, CommandException
    {
        String chargeType = insertChargeUnits();
        log("Inserting the medicationFeeDefinition necessary for drug request");
        InsertRowsCommand cmd = new InsertRowsCommand("onprc_billing", "medicationFeeDefinition");
        cmd.addRow(Map.of("chargeId", 12, "code", "TETANUS", "route", "IT", "active", true,
                "startDate", LocalDateTime.now().minusYears(2), "endDate", LocalDateTime.now().plusYears(2)));
        CommandResponse response = cmd.execute(getApiHelper().getConnection(), getContainerPath());

        log("Inserting rows in study.drug");
        cmd = new InsertRowsCommand("study", "drug");
        cmd.addRow(Map.of("Id", animalId, "date", LocalDateTime.now().minusYears(10), "project", "795644", "chargetype", chargeType, "code", "D-01830", "Billable", "yes"));
        cmd.addRow(Map.of("Id", animalId, "date", LocalDateTime.now(), "project", "795644", "chargetype", chargeType, "code", "D-01830", "Billable", "yes"));
        cmd.execute(getApiHelper().getConnection(), getContainerPath());
    }

    private void insertBloodDraws(String animalId) throws IOException, CommandException
    {
        String charge = insertChargeUnits();
        log("Inserting rows in blood draw");
        InsertRowsCommand bloodCommand = new InsertRowsCommand("study", "blood");
        bloodCommand.addRow(Map.of("Id", animalId, "date", LocalDateTime.now().minusYears(10), "project", "795644", "chargetype", charge, "tube_vol", "12"));
        bloodCommand.addRow(Map.of("Id", animalId, "date", LocalDateTime.now(), "project", "795644", "chargetype", charge, "tube_vol", "1"));
        bloodCommand.execute(getApiHelper().getConnection(), getContainerPath());
    }

    private String insertChargeUnits() throws IOException, CommandException
    {
        log("Inserting the charge unit");
        String charge = "ChargeUnit " + counter;
        InsertRowsCommand chargeUnitCommand = new InsertRowsCommand("onprc_billing", "chargeUnits");
        chargeUnitCommand.addRow(Map.of("chargetype", charge, "servicecenter", "ServiceCenter" + counter, "shownInBlood", true,
                "shownInMedications", true, "shownInProcedures", true, "shownInLabwork", true, "active", true));
        counter++;
        chargeUnitCommand.execute(getApiHelper().getConnection(), getContainerPath());
        return charge;
    }

    private void insertHousing(int housingTypeId, int housingConditionId) throws IOException, CommandException
    {
        log("Inserting rows in housing");
        InsertRowsCommand housingCommand = new InsertRowsCommand("study", "housing");
        housingCommand.addRow(Map.of("Id", "12345", "date", "2011-04-15", "enddate", "2011-04-30", "project", "795644", "room", "Room 123", "housingType", housingTypeId, "housingCondition", housingConditionId));
        housingCommand.addRow(Map.of("Id", "23456", "date", "2011-05-01", "enddate", "2012-05-03", "project", "795644", "room", "Room 123", "housingType", housingTypeId, "housingCondition", housingConditionId));
        housingCommand.execute(getApiHelper().getConnection(), getContainerPath());
    }

    private String insertBillingAndHousingTables() throws IOException, CommandException
    {
        InsertRowsCommand fiscalAuthorities = new InsertRowsCommand("onprc_billing", "fiscalAuthorities");
        fiscalAuthorities.addRow(Map.of("firstName", "Sheldon", "lastName", "Cooper", "faid", "F1", "active", true));
        fiscalAuthorities.addRow(Map.of("firstName", "Mary", "lastName", "Cooper", "faid", "F2", "active", true));
        CommandResponse fiscalAuthoritiesResponse = fiscalAuthorities.execute(getApiHelper().getConnection(), getContainerPath());

        InsertRowsCommand aliases = new InsertRowsCommand("onprc_billing", "aliases");
        aliases.addRow(Map.of("alias", "A11", "category", "GL", "fiscalAuthority", getCommandResponseRowId(fiscalAuthoritiesResponse, 0), "aliasEnabled", "Y"));
        aliases.addRow(Map.of("alias", "A21", "category", "Non-Syncing", "fiscalAuthority", getCommandResponseRowId(fiscalAuthoritiesResponse, 0), "aliasEnabled", "Y"));
        aliases.addRow(Map.of("alias", "A31", "category", "OGA", "fiscalAuthority", getCommandResponseRowId(fiscalAuthoritiesResponse, 1), "aliasEnabled", "Y"));
        aliases.addRow(Map.of("alias", "A41", "category", "Other", "fiscalAuthority", getCommandResponseRowId(fiscalAuthoritiesResponse, 1), "aliasEnabled", "Y"));
        CommandResponse aliasesResponse = aliases.execute(getApiHelper().getConnection(), getContainerPath());

        log("Inserting chargeable item");
        InsertRowsCommand chargeableItem = new InsertRowsCommand("onprc_billing", "chargeableItems");
        chargeableItem.addRow(Map.of("name", "Vaccine supplies", "category", "Misc. Fees", "canRaiseFA", true, "active", true, "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeableItem.addRow(Map.of("name", "Glove", "category", "Surgery", "canRaiseFA", true, "active", true, "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeableItem.addRow(Map.of("name", "Blood Draw", "category", "Clinical Procedure", "active", true, "canRaiseFA", true, "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeableItem.addRow(Map.of("name", "Microscope", "category", "Pathology", "canRaiseFA", true, "active", true, "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeableItem.addRow(Map.of("name", "Per Diem", "category", "Animal Per Diem", "canRaiseFA", true, "active", true, "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        CommandResponse chargeableItemResponse = chargeableItem.execute(getApiHelper().getConnection(), getContainerPath());

        int housingTypeId = insertHousingType();
        int housingDefinitionId = insertHousingDefinition();
        log("Inserting per diem fee definition");
        InsertRowsCommand perDiemFeeDef = new InsertRowsCommand("onprc_billing", "perDiemFeeDefinition");
        perDiemFeeDef.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 4), "tier", "Tier 2", "housingType", housingTypeId, "housingDefinition", housingDefinitionId, "active", true, "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        perDiemFeeDef.execute(getApiHelper().getConnection(), getContainerPath());

        log("Inserting room with housing type and condition");
        InsertRowsCommand roomCmd = new InsertRowsCommand("ehr_lookups", "rooms");
        roomCmd.addRow(Map.of("room", "Room 123", "housingType", housingTypeId, "housingCondition", housingDefinitionId));
        roomCmd.execute(getApiHelper().getConnection(), getContainerPath());

        InsertRowsCommand chargeRate = new InsertRowsCommand("onprc_billing", "chargeRates");
        chargeRate.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 0), "unitCost", "10", "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeRate.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 1), "unitCost", "56.98", "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeRate.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 2), "unitCost", "15.00", "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeRate.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 3), "unitCost", "100", "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeRate.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 4), "unitCost", "20.5", "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(20)));
        chargeRate.execute(getApiHelper().getConnection(), getContainerPath());

        insertHousing(housingTypeId, housingDefinitionId);

        InsertRowsCommand creditAccount = new InsertRowsCommand("onprc_billing", "creditAccount");
        creditAccount.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 0), "account", getCommandResponseRowId(aliasesResponse, 0),
                "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(10)));
        creditAccount.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 1), "account", getCommandResponseRowId(aliasesResponse, 1),
                "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(10)));
        creditAccount.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 2), "account", getCommandResponseRowId(aliasesResponse, 2),
                "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(10)));
        creditAccount.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 3), "account", getCommandResponseRowId(aliasesResponse, 3),
                "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(10)));
        creditAccount.addRow(Map.of("chargeId", getCommandResponseRowId(chargeableItemResponse, 4), "account", getCommandResponseRowId(aliasesResponse, 3),
                "startDate", LocalDateTime.now().minusYears(20), "endDate", LocalDateTime.now().plusYears(10)));
        creditAccount.execute(getApiHelper().getConnection(), getContainerPath());

        String chargeUnit = insertChargeUnits();
        InsertRowsCommand chargeUnitAccounts = new InsertRowsCommand("onprc_billing", "chargeUnitAccounts");
        chargeUnitAccounts.addRow(Map.of("chargetype", chargeUnit, "account", getCommandResponseRowId(aliasesResponse, 0),
                "startDate", LocalDateTime.now().minusYears(40), "endDate", LocalDateTime.now().plusYears(10)));
        chargeUnitAccounts.addRow(Map.of("chargetype", chargeUnit, "account", getCommandResponseRowId(aliasesResponse, 1),
                "startDate", LocalDateTime.now().minusYears(40), "endDate", LocalDateTime.now().plusYears(10)));
        chargeUnitAccounts.addRow(Map.of("chargetype", chargeUnit, "account", getCommandResponseRowId(aliasesResponse, 2),
                "startDate", LocalDateTime.now().minusYears(40), "endDate", LocalDateTime.now().plusYears(10)));
        chargeUnitAccounts.addRow(Map.of("chargetype", chargeUnit, "account", getCommandResponseRowId(aliasesResponse, 3),
                "startDate", LocalDateTime.now().minusYears(40), "endDate", LocalDateTime.now().plusYears(10)));
        chargeUnitAccounts.execute(getApiHelper().getConnection(), getContainerPath());

        return chargeUnit;
    }

    private void enterChargesInGrid(int rowIndex, Map<String, String> items)
    {
        Ext4GridRef miscChargesGrid = _helper.getExt4GridForFormSection("Misc. Charges");
        _helper.addRecordToGrid(miscChargesGrid);

        for (Map.Entry<String, String> pair : items.entrySet())
        {
            String colName = pair.getKey();
            String colValue = pair.getValue();
            if (colName.equals("Id") || colName.equals("date") || colName.equals("quantity"))
                miscChargesGrid.setGridCell(rowIndex, colName, colValue);
            else if (colName.equals("chargetype") || colName.equals("chargeId"))
                addComboBoxRecord(rowIndex, colName, colValue, miscChargesGrid, CONTAINS);
            else if (colName.equals("project"))
                addProjectToTheRow(miscChargesGrid, rowIndex, colValue);
        }
    }

    private void addComboBoxRecord(int rowIndex, String colName, String comboBoxSelectionValue, Ext4GridRef miscChargesGrid,
                                   @Nullable Ext4Helper.TextMatchTechnique matchTechnique)
    {
        Locator comboCol = miscChargesGrid.getCell(rowIndex, colName);
        click(comboCol);
        sleep(2000);
        Locator.XPathLocator comboColLocator = Ext4Helper.Locators.formItemWithInputNamed(colName);

        if (matchTechnique != null)
            _ext4Helper.selectComboBoxItem(comboColLocator, matchTechnique, comboBoxSelectionValue);
        else
            _ext4Helper.selectComboBoxItem(comboColLocator, comboBoxSelectionValue);

    }

    private void submitForm()
    {
        sleep(2000);
        clickButton("Submit", 0);
        _extHelper.waitForExtDialog("Finalize Form");
        click(Ext4Helper.Locators.ext4Button("Yes"));
        waitForTextToDisappear("Saving Changes", 5000);
    }

    private Integer getCommandResponseRowId(CommandResponse response, int row)
    {
        return (Integer) ((Map<?, ?>) ((ArrayList<?>) response.getParsedData().get("rows")).get(row)).get("rowid");
    }

    private void performBillingRun(String startDate, String endDate)
    {
        waitAndClickAndWait(Locator.linkContainingText("Perform Billing Run"));
        Ext4FieldRef.waitForField(this, "Start Date");
        Ext4FieldRef.getForLabel(this, "Start Date").setValue(startDate);
        Ext4FieldRef.getForLabel(this, "End Date").setValue(endDate);
        waitAndClick(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Ext4Helper.Locators.window("Success"));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("OK"));
        waitAndClickAndWait(Locator.linkWithText("All"));
        waitForPipelineJobsToComplete(++jobCounter, "Billing Run", false);
    }

    //TODO: @Test
    public void reverseChargesWindowTest()
    {

    }

    //TODO: @Test
    public void encountersTest()
    {
        //TODO: check whether assistingstaff required
    }

    //TODO: @Test
    public void miscChargesFormTest()
    {

    }

    /*
        Test coverage for https://www.labkey.org/ONPRC/Support%20Tickets/issues-details.view?issueId=41146
     */

    @Test
    public void testProtocolProjectCreation() throws InterruptedException
    {
        String protocolTitle = "Test Protocol";
        String projectName = "Test Project";
        navigateToFolder(PROJECT_NAME, BILLING_FOLDER);

        clickAndWait(Locator.linkWithText("IACUC Protocols"));
        DataRegionTable protocolTable = new DataRegionTable("query", getDriver());
        protocolTable.clickHeaderMenu("More Actions", true, "Edit Records");
        protocolTable.clickImportBulkData();

        // HACK
        Thread.sleep(2500);
        setFormElement(Locator.textarea("title"), protocolTitle);
        Thread.sleep(2500);
        clickButton("Submit");

        assertTextPresent(protocolTitle);
        protocolTable.setFilter("title", "Equals", protocolTitle);
        String protocolId = protocolTable.getDataAsText(0, "protocol");

        checker().verifyEquals("Adding new protocol was not successful", 1, protocolTable.getDataRowCount());

        navigateToFolder(PROJECT_NAME, BILLING_FOLDER);
        clickAndWait(Locator.linkWithText("ONPRC Projects"));

        DataRegionTable projectTable = new DataRegionTable("query", getDriver());
        projectTable.doAndWaitForUpdate(() -> projectTable.clickHeaderMenu("More Actions", false, "Edit Records"));
        projectTable.clickImportBulkData();

        setFormElement(Locator.name("name"), projectName);
        setFormElement(Locator.name("protocol"), protocolId);
        // Wait for client-side validation to catch up. No good way to check prior to the click, aside from clicking
        // the button and having it pop up a warning dialog
        Thread.sleep(2500);

        clickButton("Submit");
        projectTable.setFilter("name", "Equals", projectName);
        checker().verifyEquals("Adding new project was not successful", 1, projectTable.getDataRowCount());
    }

    @Override
    protected void populateInitialData()
    {
        super.populateInitialData();

        //the linked schema is created at this point since this method runs after other setup is complete
        //NOTE: or perhaps not, let's move this later in the process (see initProject() above)
        //SchemaHelper schemaHelper = new SchemaHelper(this);
        //schemaHelper.createLinkedSchema(this.getProjectName(), null, "onprc_billing_public", "/" + this.getContainerPath(), "onprc_billing_public", null, null, null);

        //TODO: import other reference tables
    }

    @Override
    protected String getAnimalHistoryPath()
    {
        return ANIMAL_HISTORY_URL;
    }
}
