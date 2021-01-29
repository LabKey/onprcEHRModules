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
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.ONPRC;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;

import java.util.HashSet;
import java.util.Set;

@Category({EHR.class, ONPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 10)
public class ONPRC_BillingTest extends AbstractONPRC_EHRTest
{
    protected String PROJECT_NAME = "ONPRC_Billing_TestProject";
    private String ANIMAL_HISTORY_URL = "/ehr/" + getProjectName() + "/animalHistory.view?";

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
        ONPRC_BillingTest initTest = (ONPRC_BillingTest)getCurrentTest();
        initTest.initProject();
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
        waitForPipelineJobsToComplete(2, "Billing Run", false);

        //TODO: test results
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

    @Override
    public void validateQueries(boolean validateSubfolders)
    {
        //NOTE: unlike other EHR tests, we skip query validation during study import and perform at the end
        //On team city we kept hitting some sort of timing issue, potentially related to the timing/caching of dataset
        //columns, which resulted in certain calculated columns not being present and queries failing during study import only
        super.validateQueries(validateSubfolders);
    }

    @Override
    protected boolean skipStudyImportQueryValidation()
    {
        return true;
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
