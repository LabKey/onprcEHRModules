/*
 * Copyright (c) 2012-2015 LabKey Corporation
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
package org.labkey.test.tests.external.labModules;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.query.Filter;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.SaveRowsResponse;
import org.labkey.remoteapi.query.SelectRowsCommand;
import org.labkey.remoteapi.query.SelectRowsResponse;
import org.labkey.test.Locator;
import org.labkey.test.TestFileUtils;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.External;
import org.labkey.test.categories.LabModule;
import org.labkey.test.categories.ONPRC;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.SimpleHttpResponse;
import org.labkey.test.util.ext4cmp.Ext4CmpRef;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;
import org.labkey.test.util.ext4cmp.Ext4FileFieldRef;
import org.labkey.test.util.ext4cmp.Ext4GridRef;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

@Category({External.class, ONPRC.class, LabModule.class})
public class HormoneAssayTest extends AbstractLabModuleAssayTest
{
    private static final String ASSAY_NAME = "HormoneAssay Test";
    private static final String[][] TEMPLATE_DATA = new String[][]{
        {"Well", "Category", "Subject Id", "Sample Date", "Diluent", "Dilution Factor", "Sample Type"},
        {"104", "Blank", "DU", "", "DU", "1", "Serum"},
        {"105", "Blank", "MD1", "", "MD1", "1", "Serum"},
        {"106", "Blank", "MA", "", "MA", "1", "Serum"},
        {"107", "Unknown", "Subject4", "2012-01-05", "DU", "2", "Serum"},
        {"108", "Unknown", "Subject5", "2012-01-06", "MD1", "4", "Serum"},
        {"109", "Unknown", "Subject6", "2012-01-07", "MA", "10", "Serum"},
        {"110", "Unknown", "Subject7", "2012-01-08", "DU", "5", "Serum"},
        {"111", "Unknown", "Subject8", "2012-01-09", "MD1", "2", "Serum"},
        {"112", "Unknown", "Subject9", "2012-01-10", "MA", "2", "Serum"},
        {"113", "Unknown", "Subject10", "2012-01-11", "", "", "Serum"},
        {"114", "Unknown", "Subject11", "2012-01-12", "", "", "Serum"},
        {"115", "Unknown", "Subject12", "2012-01-13", "", "", "Serum"},
        {"116", "Unknown", "Subject13", "2012-01-14", "", "", "Serum"},
        {"117", "Unknown", "Subject14", "2012-01-15", "", "", "Serum"},
        {"118", "Unknown", "Subject15", "2012-01-16", "", "", "Serum"},
        {"119", "Unknown", "Subject16", "2012-01-17", "", "", "Serum"},
        {"120", "Unknown", "Subject17", "2012-01-18", "", "", "Serum"},
        {"121", "Unknown", "Subject18", "2012-01-19", "", "", "Serum"},
        {"122", "Unknown", "Subject19", "2012-01-20", "", "", "Serum"},
        {"123", "Unknown", "Subject20", "2012-01-21", "", "", "Serum"},
        {"124", "Unknown", "Subject21", "2012-01-22", "", "", "Serum"},
        {"125", "Unknown", "Subject22", "2012-01-23", "", "", "Serum"},
        {"126", "Unknown", "Subject23", "2012-01-24", "", "", "Serum"},
        {"127", "Unknown", "Subject24", "2012-01-25", "", "", "Serum"},
        {"128", "Unknown", "Subject25", "2012-01-26", "", "", "Serum"},
        {"129", "Unknown", "Subject26", "2012-01-27", "", "", "Serum"},
        {"130", "Unknown", "Subject27", "2012-01-28", "", "", "Serum"},
        {"131", "Unknown", "Subject28", "2012-01-29", "", "", "Serum"},
        {"132", "Unknown", "Subject29", "2012-01-30", "", "", "Serum"},
        {"133", "Unknown", "Subject30", "2012-01-31", "", "", "Serum"},
        {"134", "Unknown", "Subject31", "2012-02-01", "", "", "Serum"},
        {"135", "Unknown", "Subject32", "2012-02-02", "", "", "Serum"},
        {"136", "Unknown", "Subject33", "2012-02-03", "", "", "Serum"},
        {"137", "Unknown", "Subject34", "2012-02-04", "", "", "Serum"},
        {"138", "Unknown", "Subject35", "2012-02-05", "", "", "Serum"},
        {"139", "Unknown", "Subject36", "2012-02-06", "", "", "Serum"},
        {"140", "Unknown", "Subject37", "2012-02-07", "", "", "Serum"},
        {"141", "Unknown", "Subject38", "2012-02-08", "", "", "Serum"},
        {"142", "Unknown", "Subject39", "2012-02-09", "", "", "Serum"},
        {"143", "Unknown", "Subject40", "2012-02-10", "", "", "Serum"},
        {"144", "Unknown", "Subject41", "2012-02-11", "", "", "Serum"},
        {"145", "Unknown", "Subject42", "2012-02-12", "", "", "Serum"},
        {"146", "Unknown", "Subject43", "2012-02-13", "", "", "Serum"},
        {"301", "Unknown", "Subject44", "2012-02-14", "", "", "Serum"},
        {"302", "Unknown", "Subject45", "2012-02-15", "", "", "Serum"},
        {"303", "Unknown", "Subject46", "2012-02-16", "", "", "Serum"},
        {"304", "Unknown", "Subject47", "2012-02-17", "", "", "Serum"},
        {"305", "Unknown", "Subject48", "2012-02-18", "", "", "Serum"},
        {"306", "Unknown", "Subject49", "2012-02-19", "", "", "Serum"},
        {"307", "Unknown", "Subject50", "2012-02-20", "", "", "Serum"},
        {"308", "Unknown", "Subject51", "2012-02-21", "", "", "Serum"},
        {"309", "Unknown", "Subject52", "2012-02-22", "", "", "Serum"},
        {"310", "Unknown", "Subject53", "2012-02-23", "", "", "Serum"},
        {"311", "Unknown", "Subject54", "2012-02-24", "", "", "Serum"},
        {"312", "Unknown", "Subject55", "2012-02-25", "", "", "Serum"},
        {"313", "Unknown", "Subject56", "2012-02-26", "", "", "Serum"},
        {"314", "Unknown", "Subject57", "2012-02-27", "", "", "Serum"},
        {"315", "Unknown", "Subject58", "2012-02-28", "", "", "Serum"},
        {"316", "Unknown", "Subject59", "2012-02-29", "", "", "Serum"},
        {"317", "Unknown", "Subject60", "2012-03-01", "", "", "Serum"},
        {"318", "Unknown", "Subject61", "2012-03-02", "", "", "Serum"},
        {"401", "Unknown", "Subject62", "2012-03-03", "", "", "Serum"},
        {"402", "Unknown", "Subject63", "2012-03-04", "", "", "Serum"},
        {"403", "Unknown", "Subject64", "2012-03-05", "", "", "Serum"},
        {"404", "Unknown", "Subject65", "2012-03-06", "", "", "Serum"},
        {"405", "Unknown", "Subject66", "2012-03-07", "", "", "Serum"},
        {"406", "Unknown", "Subject67", "2012-03-08", "", "", "Serum"},
        {"407", "Unknown", "Subject68", "2012-03-09", "", "", "Serum"},
        {"408", "Unknown", "Subject69", "2012-03-10", "", "", "Serum"},
        {"409", "Unknown", "Subject70", "2012-03-11", "", "", "Serum"},
        {"410", "Unknown", "Subject71", "2012-03-12", "", "", "Serum"},
        {"411", "Unknown", "Subject72", "2012-03-13", "", "", "Serum"},
        {"412", "Unknown", "Subject73", "2012-03-14", "", "", "Serum"},
        {"413", "Unknown", "Subject74", "2012-03-15", "", "", "Serum"},
        {"414", "Unknown", "Subject75", "2012-03-16", "", "", "Serum"},
        {"415", "Unknown", "Subject76", "2012-03-17", "", "", "Serum"},
        {"416", "Unknown", "Subject77", "2012-03-18", "", "", "Serum"},
        {"417", "Unknown", "Subject78", "2012-03-19", "", "", "Serum"},
        {"418", "Unknown", "Subject79", "2012-03-20", "", "", "Serum"},
        {"601", "Unknown", "Subject80", "2012-03-21", "", "", "Serum"},
        {"602", "Unknown", "Subject81", "2012-03-22", "", "", "Serum"},
        {"603", "Unknown", "Subject82", "2012-03-23", "", "", "Serum"},
        {"604", "Unknown", "Subject83", "2012-03-24", "", "", "Serum"},
        {"701", "Unknown", "Subject84", "2012-03-25", "", "", "Serum"},
        {"702", "Unknown", "Subject85", "2012-03-26", "", "", "Serum"},
        {"703", "Unknown", "Subject86", "2012-03-27", "", "", "Serum"},
        {"704", "Unknown", "Subject87", "2012-03-28", "", "", "Serum"},
        {"801", "Unknown", "Subject88", "2012-03-29", "", "", "Serum"},
        {"802", "Unknown", "Subject89", "2012-03-30", "", "", "Serum"},
        {"803", "Unknown", "Subject90", "2012-03-31", "", "", "Serum"},
        {"804", "Unknown", "Subject91", "2012-04-01", "", "", "Serum"},
        {"901", "Unknown", "Subject92", "2012-04-02", "", "", "Serum"},
        {"902", "Unknown", "Subject93", "2012-04-03", "", "", "Serum"},
        {"903", "Unknown", "Subject94", "2012-04-04", "", "", "Serum"},
        {"904", "Unknown", "Subject95", "2012-04-05", "", "", "Serum"}
    };

    private String[][] PIVOT_DATA = new String[][]{
            {"Subject Id", "Sample Date", "E2 (pg/ml)", "P4 (ng/ml)"},
            {"9835", "2012-03-17", "24.82", "<0.01"},
            {"9785", "2012-03-17", "48.51", "2.72"},
            {"3011", "2012-03-17", "70.94", "0.28"},
            {"3011", "2012-03-17", "98.54", "0.07"},
            {"1983", "2012-03-18", "22.89", "2.13"},
            {"2978", "2012-03-18", "59.54", "4.83"},
            {"3011", "2012-03-18", "70.29", "0.27"},
            {"3011", "2012-03-18", "73", "0.05"},
            {"1983", "2012-03-19", "22", "3.38"},
            {"2978", "2012-03-19", "58", "4.7"},
            {"3011", "2012-03-19", "57.74", "0.26"},
            {"3011", "2012-03-19", "84", "0.14"}
    };

    public HormoneAssayTest()
    {
        PROJECT_NAME = "EC_AssayVerifyProject" + TRICKY_CHARACTERS_FOR_PROJECT_NAMES;
    }

    @Test
    public void testSteps() throws Exception
    {
        setUpTest();
        pivotedImportTestFromExcel();

        createPlateTemplate();
        importResults();

        pivotedImportTest();
    }

    private void pivotedImportTestFromExcel() throws Exception
    {
        log("Verifying Hormone Assay Import Using Pivoted Input");
        _helper.goToAssayResultImport(ASSAY_NAME, true);

        //a proxy for page loading
        _helper.waitForField("Sample Type", WAIT_FOR_JAVASCRIPT * 2);

        //switch import method
        Ext4FieldRef field = Ext4FieldRef.getForBoxLabel(this, "Pivoted By Test");
        field.setChecked(true);

        _helper.waitForField("Sample Type"); //form is re-rendered when import method changed
        Ext4FieldRef.getForLabel(this, "Run Description").setValue("Description");

        Ext4FieldRef.getForLabel(this, "Sample Type").setValue("Serum");

        waitAndClick(Ext4Helper.Locators.radiobutton(this, "File Upload"));
        Ext4CmpRef.waitForComponent(this, "filefield");
        Ext4FileFieldRef ff = Ext4FileFieldRef.create(this);
        File sampleExcel = TestFileUtils.getSampleData("HormoneAssay/HormoneAssayPivotData.xlsx");
        ff.setToFile(sampleExcel);

        Ext4CmpRef button = _ext4Helper.queryOne("button[text=\"Upload\"]", Ext4CmpRef.class);
        button.waitForEnabled();

        waitAndClick(Ext4Helper.Locators.ext4Button("Upload"));
        waitForElement(Ext4Helper.Locators.window("Success"));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("OK"));
        waitForText("Import Samples");

        Map<String, String[]> expected = new LinkedHashMap<>();
        expected.put("TestId_Estradiol_38", new String[]{"TestId", "2014-03-18", "Estradiol", "38", "", "Unknown", "", "", ""});
        expected.put("TestId_Progesterone_<0.03", new String[]{"TestId", "2014-03-18", "Progesterone", "<0.03", "", "Unknown", "", "", ""});

        verifyResults(2, expected);
    }

    private void pivotedImportTest() throws Exception
    {
        log("Verifying Hormone Assay Import Using Pivoted Input");
        _helper.goToAssayResultImport(ASSAY_NAME, true);

        //a proxy for page loading
        _helper.waitForField("Sample Type", WAIT_FOR_JAVASCRIPT * 2);

        //switch import method
        Ext4FieldRef field = Ext4FieldRef.getForBoxLabel(this, "Pivoted By Test");
        field.setChecked(true);

        _helper.waitForField("Sample Type"); //form is re-rendered when import method changed
        Ext4FieldRef.getForLabel(this, "Run Description").setValue("Description");

        Ext4FieldRef.getForLabel(this, "Sample Type").setValue("Serum");

        Ext4FieldRef textarea = _ext4Helper.queryOne("#fileContent", Ext4FieldRef.class);
        StringBuilder sb = new StringBuilder();
        for (String[] row : PIVOT_DATA)
        {
            sb.append(StringUtils.join(row, "\t")).append(System.getProperty("line.separator"));
        }
        String text = sb.toString();

        log("Trying to save invalid data");
        String originalTest = "P4";
        String errorText = text.replaceAll(originalTest, "FakeTest");
        textarea.setValue(errorText);

        Ext4CmpRef button = _ext4Helper.queryOne("button[text=\"Upload\"]", Ext4CmpRef.class);
        button.waitForEnabled();

        waitAndClick(Ext4Helper.Locators.ext4Button("Upload"));
        waitForElement(Ext4Helper.Locators.window("Upload Failed"), WAIT_FOR_JAVASCRIPT * 2);
        waitAndClick(Ext4Helper.Locators.ext4Button("OK"));
        assertTextPresent("There were errors in the upload");
        waitForText("Unknown column: FakeTest (ng/ml)");

        log("Saving valid data");
        textarea.setValue(text);
        waitAndClick(Ext4Helper.Locators.ext4Button("Upload"));
        waitForElement(Ext4Helper.Locators.window("Success"));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("OK"));
        waitForText("Import Samples");

        Map<String, String[]> expected = new LinkedHashMap<>();
        expected.put("9835_Estradiol_24.82", new String[]{"9835", "2012-03-17", "Estradiol", "24.82", "", "Unknown", "", "", ""});
        expected.put("9785_Estradiol_48.51", new String[]{"9785", "2012-03-17", "Estradiol", "48.51", "", "Unknown", "", "", ""});
        expected.put("3011_Estradiol_70.94", new String[]{"3011", "2012-03-17", "Estradiol", "70.94", "", "Unknown", "", "", ""});
        expected.put("3011_Estradiol_98.54", new String[]{"3011", "2012-03-17", "Estradiol", "98.54", "", "Unknown", "", "", ""});
        expected.put("1983_Estradiol_22.89", new String[]{"1983", "2012-03-18", "Estradiol", "22.89", "", "Unknown", "", "", ""});
        expected.put("2978_Estradiol_59.54", new String[]{"2978", "2012-03-18", "Estradiol", "59.54", "", "Unknown", "", "", ""});
        expected.put("3011_Estradiol_70.29", new String[]{"3011", "2012-03-18", "Estradiol", "70.29", "", "Unknown", "", "", ""});
        expected.put("3011_Estradiol_73", new String[]{"3011", "2012-03-18", "Estradiol", "73", "", "Unknown", "", "", ""});
        expected.put("1983_Estradiol_22", new String[]{"1983", "2012-03-19", "Estradiol", "22", "", "Unknown", "", "", ""});
        expected.put("2978_Estradiol_58", new String[]{"2978", "2012-03-19", "Estradiol", "58", "", "Unknown", "", "", ""});
        expected.put("3011_Estradiol_57.74", new String[]{"3011", "2012-03-19", "Estradiol", "57.74", "", "Unknown", "", "", ""});
        expected.put("3011_Estradiol_84", new String[]{"3011", "2012-03-19", "Estradiol", "84", "", "Unknown", "", "", ""});

        expected.put("9835_Progesterone_<0.01", new String[]{"9835", "2012-03-17", "Progesterone", "<0.01", "", "Unknown", "", "", ""});
        expected.put("9785_Progesterone_2.72", new String[]{"9785", "2012-03-17", "Progesterone", "2.72", "", "Unknown", "", "", ""});
        expected.put("3011_Progesterone_0.28", new String[]{"3011", "2012-03-17", "Progesterone", "0.28", "", "Unknown", "", "", ""});
        expected.put("3011_Progesterone_0.07", new String[]{"3011", "2012-03-17", "Progesterone", "0.07", "", "Unknown", "", "", ""});
        expected.put("1983_Progesterone_2.13", new String[]{"1983", "2012-03-18", "Progesterone", "2.13", "", "Unknown", "", "", ""});
        expected.put("2978_Progesterone_4.83", new String[]{"2978", "2012-03-18", "Progesterone", "4.83", "", "Unknown", "", "", ""});
        expected.put("3011_Progesterone_0.27", new String[]{"3011", "2012-03-18", "Progesterone", "0.27", "", "Unknown", "", "", ""});
        expected.put("3011_Progesterone_0.05", new String[]{"3011", "2012-03-18", "Progesterone", "0.05", "", "Unknown", "", "", ""});
        expected.put("1983_Progesterone_3.38", new String[]{"1983", "2012-03-19", "Progesterone", "3.38", "", "Unknown", "", "", ""});
        expected.put("2978_Progesterone_4.7", new String[]{"2978", "2012-03-19", "Progesterone", "4.7", "", "Unknown", "", "", ""});
        expected.put("3011_Progesterone_0.26", new String[]{"3011", "2012-03-19", "Progesterone", "0.26", "", "Unknown", "", "", ""});
        expected.put("3011_Progesterone_0.14", new String[]{"3011", "2012-03-19", "Progesterone", "0.14", "", "Unknown", "", "", ""});

        verifyResults(24, expected);
    }

    private void createPlateTemplate() throws ParseException
    {
        _helper.goToLabHome();
        _helper.clickNavPanelItem(ASSAY_NAME + ":", IMPORT_DATA_TEXT);
        waitAndClick(Ext4Helper.Locators.menuItem("Prepare Run"));
        waitForElement(Ext4Helper.Locators.window(IMPORT_DATA_TEXT));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("Submit"));

        List<String> expectedCols = new ArrayList<>();
        expectedCols.add("well");
        expectedCols.add("category");
        expectedCols.add("subjectId");
        expectedCols.add("date");
        expectedCols.add("sampleType");
        expectedCols.add("dilutionFactor");
        expectedCols.add("diluent");
        expectedCols.add("comment");
        expectedCols.add("sampleId");

        waitForElement(Locator.xpath("//span[contains(text(), 'Freezer Id') and contains(@class, 'x4-column-header-text')]")); //ensure grid loaded

        String[][] templateData = TEMPLATE_DATA.clone();
        String category = "FakeCategory";
        templateData[1][1] = category;

        _helper.addRecordsToAssayTemplate(templateData, expectedCols);

        waitForText("904");  //this is the last sample

        waitAndClick(Ext4Helper.Locators.ext4ButtonEnabled("Save and Close"));

        waitForElement(Ext4Helper.Locators.window("Error"));
        assertElementPresent(Locator.xpath("//div[contains(text(), 'Unknown value for field category: " + category + "')]"));
        click(Ext4Helper.Locators.ext4Button("OK"));

        Ext4GridRef grid = _ext4Helper.queryOne("grid", Ext4GridRef.class);
        grid.setGridCellJS(1, "category", "Blank");
        templateData[1][1] = "Blank"; //restore original value to array

        //validate values
        int i = 0;
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        for (String[] arr : TEMPLATE_DATA)
        {
            if (i > 0)
            {
                Object well = grid.getFieldValue(i, "well");
                Object categoryVal = grid.getFieldValue(i, "category");
                Object subjectId = grid.getFieldValue(i, "subjectId");
                Date sampleDate = grid.getDateFieldValue(i, "date");
                if (sampleDate != null)
                    sampleDate = DateUtils.truncate(sampleDate, Calendar.DATE);

                Object sampleType = grid.getFieldValue(i, "sampleType");
                Object diluent = grid.getFieldValue(i, "diluent");

                assertEquals("Incorrect well", StringUtils.trimToNull(arr[0]), well);
                assertEquals("Incorrect sample category", StringUtils.trimToNull(arr[1]), categoryVal);
                assertEquals("Incorrect subjectId", StringUtils.trimToNull(arr[2]), subjectId);
                if (sampleDate == null || StringUtils.trimToNull(arr[3]) == null)
                {
                    assertEquals("Incorrect sampleDate", StringUtils.trimToNull(arr[3]), sampleDate);
                }
                else
                {
                    Date expected = dateFormat.parse(StringUtils.trimToNull(arr[3]));
                    expected = DateUtils.truncate(expected, Calendar.DATE);
                    assertEquals("Incorrect sampleDate", expected, sampleDate);
                }

                //assertEquals("Incorrect peptide", StringUtils.trimToNull(arr[4]), peptide);
            }

            i++;
        }

        waitAndClick(Ext4Helper.Locators.ext4Button("Save and Close"));
        waitForText("Save Complete");
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("OK"));
        waitForText("View and Edit Workbooks");
    }

    private void importResults() throws Exception
    {
        log("Verifying Roche E411 Import");
        _helper.goToLabHome();
        _helper.clickNavPanelItem(ASSAY_NAME + ":", IMPORT_DATA_TEXT);
        waitAndClickAndWait(Ext4Helper.Locators.menuItem("View Planned Runs"));

        log("Entering results for saved run");
        DataRegionTable templates = new DataRegionTable("query", this);
        clickAndWait(Locator.linkWithText("Enter Results").findElement(templates.findCell(0, 0)));

        //use the same data included with this assay
        Locator btn = Locator.linkContainingText("Download Example Data");
        waitForElement(btn);

        assertEquals("Incorrect value for field", "Roche E411", Ext4FieldRef.getForLabel(this, "Instrument").getValue());
        assertEquals("Incorrect value for field", "Electrochemiluminescence", Ext4FieldRef.getForLabel(this, "Method").getValue());

        SimpleHttpResponse httpResponse = WebTestHelper.getHttpResponse(WebTestHelper.getBaseURL() + "/hormoneassay/SampleData/RocheE411.txt");
        String exampleData = httpResponse.getResponseBody();
        //waitAndClick(btn); //NOTE: get example data by HTTP request, so we dont have to parse out the HTML added by browser

        Ext4FieldRef textarea = _ext4Helper.queryOne("#fileContent", Ext4FieldRef.class);

        log("Trying to save data");
        textarea.setValue(exampleData);

        Ext4CmpRef button = _ext4Helper.queryOne("#upload", Ext4CmpRef.class);
        button.waitForEnabled();

        waitAndClick(Ext4Helper.Locators.ext4Button("Upload"));
        waitForElement(Ext4Helper.Locators.window("Success"));
        waitAndClickAndWait(Ext4Helper.Locators.ext4Button("OK"));
        waitForText("Import Samples");

        Map<String, String[]> expected = new LinkedHashMap<>();
        expected.put("DU_DHEAS_0.11", new String[]{"DU", "", "DHEAS", "0.11", "ug/ml", "Blank", "DU", "1", ""});
        expected.put("MA_Progesterone_1.56", new String[]{"MA", "", "Progesterone", "1.56", "ng/ml", "Blank", "MA", "1", ""});
        expected.put("MA_Estradiol_15.35", new String[]{"MA", "", "Estradiol", "15.35", "pg/ml", "Blank", "MA", "1", ""});
        expected.put("MD1_DHEAS_0.08", new String[]{"MD1", "", "DHEAS", "0.08", "ug/ml", "Blank", "MD1", "1", ""});
        expected.put("PC U1 00153149_Free T4_1.2", new String[]{"PC U1 00153149", "", "Free T4", "1.2", "ng/dl", "Pos Control", "", "", ""});
        expected.put("PC U1 00153149_Cortisol_13.11", new String[]{"PC U1 00153149", "", "Cortisol", "13.11", "ug/dl", "Pos Control", "", "", ""});
        expected.put("PC U1 00153149_Total T3_1.55", new String[]{"PC U1 00153149", "", "Total T3", "1.55", "ng/ml", "Pos Control", "", "", ""});
        expected.put("PC U1 00153149_Free T3_3.79", new String[]{"PC U1 00153149", "", "Free T3", "3.79", "pg/ml", "Pos Control", "", "", ""});
        expected.put("PC U1 00153149_Progesterone_8.88", new String[]{"PC U1 00153149", "", "Progesterone", "8.88", "ng/ml", "Pos Control", "", "", ""});
        expected.put("PC U1 00153149_Total T4_8.07", new String[]{"PC U1 00153149", "", "Total T4", "8.07", "ug/dl", "Pos Control", "", "", ""});
        expected.put("PC U1 00153149_Estradiol_101.8", new String[]{"PC U1 00153149", "", "Estradiol", "101.8", "pg/ml", "Pos Control", "", "", ""});
        expected.put("PC U1 00153149_Progesterone_8.95", new String[]{"PC U1 00153149", "", "Progesterone", "8.95", "ng/ml", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Free T4_2.77", new String[]{"PC U2 00153152", "", "Free T4", "2.77", "ng/dl", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Cortisol_30.73", new String[]{"PC U2 00153152", "", "Cortisol", "30.73", "ug/dl", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Total T3_3.28", new String[]{"PC U2 00153152", "", "Total T3", "3.28", "ng/ml", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Free T3_14.5", new String[]{"PC U2 00153152", "", "Free T3", "14.5", "pg/ml", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Progesterone_20.29", new String[]{"PC U2 00153152", "", "Progesterone", "20.29", "ng/ml", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Total T4_11.59", new String[]{"PC U2 00153152", "", "Total T4", "11.59", "ug/dl", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Estradiol_466.6", new String[]{"PC U2 00153152", "", "Estradiol", "466.6", "pg/ml", "Pos Control", "", "", ""});
        expected.put("PC U2 00153152_Progesterone_19.57", new String[]{"PC U2 00153152", "", "Progesterone", "19.57", "ng/ml", "Pos Control", "", "", ""});
        expected.put("Subject4_Progesterone_0", new String[]{"Subject4", "2012-01-05", "Progesterone", "0", "ng/ml", "Unknown", "DU", "2", ""});
        expected.put("Subject4_Estradiol_189.59", new String[]{"Subject4", "2012-01-05", "Estradiol", "189.59", "pg/ml", "Unknown", "DU", "2", ""});
        expected.put("Subject5_Progesterone_-0.05", new String[]{"Subject5", "2012-01-06", "Progesterone", "-0.05", "ng/ml", "Unknown", "MD1", "4", "<Test, Blank greater than result"});
        expected.put("Subject5_Estradiol_4.92", new String[]{"Subject5", "2012-01-06", "Estradiol", "4.92", "pg/ml", "Unknown", "MD1", "4", "<Test"});
        expected.put("Subject6_Progesterone_-8.37", new String[]{"Subject6", "2012-01-07", "Progesterone", "-8.37", "ng/ml", "Unknown", "MA", "10", "Blank greater than result"});
        expected.put("Subject6_Estradiol_-3.46", new String[]{"Subject6", "2012-01-07", "Estradiol", "-3.46", "pg/ml", "Unknown", "MA", "10", "<Test, Blank greater than result"});
        expected.put("Subject7_Progesterone_5.37", new String[]{"Subject7", "2012-01-08", "Progesterone", "5.37", "ng/ml", "Unknown", "DU", "5", ""});
        expected.put("Subject7_Estradiol_39.34", new String[]{"Subject7", "2012-01-08", "Estradiol", "39.34", "pg/ml", "Unknown", "DU", "5", ""});
        expected.put("Subject8_Progesterone_-0.01", new String[]{"Subject8", "2012-01-09", "Progesterone", "-0.01", "ng/ml", "Unknown", "MD1", "2", "Blank greater than result"});
        expected.put("Subject8_Estradiol_24.78", new String[]{"Subject8", "2012-01-09", "Estradiol", "24.78", "pg/ml", "Unknown", "MD1", "2", ""});
        expected.put("Subject9_Progesterone_-8.32", new String[]{"Subject9", "2012-01-10", "Progesterone", "-8.32", "ng/ml", "Unknown", "MA", "2", "Blank greater than result"});
        expected.put("Subject9_Estradiol_0.29", new String[]{"Subject9", "2012-01-10", "Estradiol", "0.29", "pg/ml", "Unknown", "MA", "2", ""});
        expected.put("Subject10_Progesterone_0.16", new String[]{"Subject10", "2012-01-11", "Progesterone", "0.16", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject10_Estradiol_12.39", new String[]{"Subject10", "2012-01-11", "Estradiol", "12.39", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject11_Progesterone_0.23", new String[]{"Subject11", "2012-01-12", "Progesterone", "0.23", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject11_Estradiol_19.58", new String[]{"Subject11", "2012-01-12", "Estradiol", "19.58", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject12_Progesterone_0.38", new String[]{"Subject12", "2012-01-13", "Progesterone", "0.38", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject12_Estradiol_21.65", new String[]{"Subject12", "2012-01-13", "Estradiol", "21.65", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject13_Progesterone_0.19", new String[]{"Subject13", "2012-01-14", "Progesterone", "0.19", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject13_Estradiol_44.98", new String[]{"Subject13", "2012-01-14", "Estradiol", "44.98", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject14_Progesterone_0.27", new String[]{"Subject14", "2012-01-15", "Progesterone", "0.27", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject14_Estradiol_87.17", new String[]{"Subject14", "2012-01-15", "Estradiol", "87.17", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject15_Progesterone_0.3", new String[]{"Subject15", "2012-01-16", "Progesterone", "0.3", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject15_Estradiol_155.9", new String[]{"Subject15", "2012-01-16", "Estradiol", "155.9", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject16_Progesterone_0.74", new String[]{"Subject16", "2012-01-17", "Progesterone", "0.74", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject16_Estradiol_24.82", new String[]{"Subject16", "2012-01-17", "Estradiol", "24.82", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject17_Progesterone_2.72", new String[]{"Subject17", "2012-01-18", "Progesterone", "2.72", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject17_Estradiol_48.51", new String[]{"Subject17", "2012-01-18", "Estradiol", "48.51", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject18_Progesterone_0.28", new String[]{"Subject18", "2012-01-19", "Progesterone", "0.28", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject18_Estradiol_70.94", new String[]{"Subject18", "2012-01-19", "Estradiol", "70.94", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject19_Progesterone_0.07", new String[]{"Subject19", "2012-01-20", "Progesterone", "0.07", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject19_Estradiol_98.54", new String[]{"Subject19", "2012-01-20", "Estradiol", "98.54", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject20_Progesterone_2.13", new String[]{"Subject20", "2012-01-21", "Progesterone", "2.13", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject20_Estradiol_22.89", new String[]{"Subject20", "2012-01-21", "Estradiol", "22.89", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject21_Progesterone_4.83", new String[]{"Subject21", "2012-01-22", "Progesterone", "4.83", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject21_Estradiol_59.54", new String[]{"Subject21", "2012-01-22", "Estradiol", "59.54", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject22_Progesterone_0.27", new String[]{"Subject22", "2012-01-23", "Progesterone", "0.27", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject22_Estradiol_70.29", new String[]{"Subject22", "2012-01-23", "Estradiol", "70.29", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject23_Progesterone_0.06", new String[]{"Subject23", "2012-01-24", "Progesterone", "0.06", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject23_Estradiol_73.34", new String[]{"Subject23", "2012-01-24", "Estradiol", "73.34", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject24_Progesterone_3.38", new String[]{"Subject24", "2012-01-25", "Progesterone", "3.38", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject24_Estradiol_21.57", new String[]{"Subject24", "2012-01-25", "Estradiol", "21.57", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject25_Progesterone_4.7", new String[]{"Subject25", "2012-01-26", "Progesterone", "4.7", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject25_Estradiol_58.43", new String[]{"Subject25", "2012-01-26", "Estradiol", "58.43", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject26_Progesterone_0.26", new String[]{"Subject26", "2012-01-27", "Progesterone", "0.26", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject26_Estradiol_57.74", new String[]{"Subject26", "2012-01-27", "Estradiol", "57.74", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject27_Progesterone_0.08", new String[]{"Subject27", "2012-01-28", "Progesterone", "0.08", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject27_Estradiol_84.3", new String[]{"Subject27", "2012-01-28", "Estradiol", "84.3", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject28_Progesterone_7.6", new String[]{"Subject28", "2012-01-29", "Progesterone", "7.6", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject28_Estradiol_2706", new String[]{"Subject28", "2012-01-29", "Estradiol", "2706", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject29_Progesterone_0.06", new String[]{"Subject29", "2012-01-30", "Progesterone", "0.06", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject29_Estradiol_48.59", new String[]{"Subject29", "2012-01-30", "Estradiol", "48.59", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject30_Estradiol_70.84", new String[]{"Subject30", "2012-01-31", "Estradiol", "70.84", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject31_Progesterone_0.06", new String[]{"Subject31", "2012-02-01", "Progesterone", "0.06", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject31_Estradiol_51.86", new String[]{"Subject31", "2012-02-01", "Estradiol", "51.86", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject32_Progesterone_0.07", new String[]{"Subject32", "2012-02-02", "Progesterone", "0.07", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject32_Estradiol_43.86", new String[]{"Subject32", "2012-02-02", "Estradiol", "43.86", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject33_Estradiol_77.97", new String[]{"Subject33", "2012-02-03", "Estradiol", "77.97", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject34_Progesterone_0.3", new String[]{"Subject34", "2012-02-04", "Progesterone", "0.3", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject34_Estradiol_2949", new String[]{"Subject34", "2012-02-04", "Estradiol", "2949", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject35_Progesterone_0.05", new String[]{"Subject35", "2012-02-05", "Progesterone", "0.05", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject35_Estradiol_89.47", new String[]{"Subject35", "2012-02-05", "Estradiol", "89.47", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject36_Estradiol_127.7", new String[]{"Subject36", "2012-02-06", "Estradiol", "127.7", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject37_Progesterone_0.16", new String[]{"Subject37", "2012-02-07", "Progesterone", "0.16", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject37_Estradiol_128", new String[]{"Subject37", "2012-02-07", "Estradiol", "128", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject38_Progesterone_1", new String[]{"Subject38", "2012-02-08", "Progesterone", "1", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject38_Estradiol_1549", new String[]{"Subject38", "2012-02-08", "Estradiol", "1549", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject39_Progesterone_0.05", new String[]{"Subject39", "2012-02-09", "Progesterone", "0.05", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject39_Estradiol_72.49", new String[]{"Subject39", "2012-02-09", "Estradiol", "72.49", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject40_Estradiol_328.1", new String[]{"Subject40", "2012-02-10", "Estradiol", "328.1", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject41_Progesterone_0.06", new String[]{"Subject41", "2012-02-11", "Progesterone", "0.06", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject41_Estradiol_124.8", new String[]{"Subject41", "2012-02-11", "Estradiol", "124.8", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject42_Progesterone_0.13", new String[]{"Subject42", "2012-02-12", "Progesterone", "0.13", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject42_Estradiol_145.8", new String[]{"Subject42", "2012-02-12", "Estradiol", "145.8", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject43_Progesterone_0.21", new String[]{"Subject43", "2012-02-13", "Progesterone", "0.21", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject43_Estradiol_155.1", new String[]{"Subject43", "2012-02-13", "Estradiol", "155.1", "pg/ml", "Unknown", "", "1", ""});
        expected.put("Subject44_Progesterone_0.31", new String[]{"Subject44", "2012-02-14", "Progesterone", "0.31", "ng/ml", "Unknown", "", "1", ""});
        expected.put("Subject44_LH_3.66", new String[]{"Subject44", "2012-02-14", "LH", "3.66", "mIU/ml", "Unknown", "", "1", ""});
        expected.put("Subject44_FSH_7.06", new String[]{"Subject44", "2012-02-14", "FSH", "7.06", "mIU/ml", "Unknown", "", "1", ""});
        expected.put("Subject44_SHBG_2.75", new String[]{"Subject44", "2012-02-14", "SHBG", "2.75", "ug/ml", "Unknown", "", "1", ""});

        int totalRows = 100;
        verifyResults(totalRows, expected);

        log("verifying run plan marked as complete");
        _helper.goToLabHome();
        _helper.clickNavPanelItem(ASSAY_NAME + ":", IMPORT_DATA_TEXT);
        waitAndClickAndWait(Ext4Helper.Locators.menuItem("View Planned Runs"));
        DataRegionTable dr2 = new DataRegionTable("query", this);
        assertEquals("Run plan not marked completed", 0, dr2.getDataRowCount());
    }

    private void verifyResults(int totalRows, Map<String, String[]> expected) throws Exception
    {
        log("Verifying results");
        _helper.clickNavPanelItemAndWait(ASSAY_NAME + " Runs:", 1);
        waitAndClickAndWait(Locator.linkContainingText("view results"));

        DataRegionTable results = new DataRegionTable("Data", this);

        assertEquals("Incorrect row count", totalRows, results.getDataRowCount());
        waitForText("Estradiol");

        //recreate the DR to see if this removes intermittent test failures
        results = new DataRegionTable(results.getDataRegionName(), this);

        int i = 0;
        while (i < totalRows)
        {
            String subjectId = StringUtils.trimToEmpty(results.getDataAsText(i, "Subject Id"));
            String dateText = StringUtils.trimToNull(results.getDataAsText(i, "Sample Date"));
            String date = dateText == null ? null : _dateFormat.format(_dateTimeFormat.parse(dateText));
            String testName = StringUtils.trimToEmpty(results.getDataAsText(i, "Test Name"));
            String result = StringUtils.trimToEmpty(results.getDataAsText(i, "Result"));
            String units = StringUtils.trimToEmpty(results.getDataAsText(i, "Units"));
            String diluent = StringUtils.trimToEmpty(results.getDataAsText(i, "Diluent"));
            String df = StringUtils.trimToEmpty(results.getDataAsText(i, "Dilution Factor"));
            String category = StringUtils.trimToEmpty(results.getDataAsText(i, "Sample Category"));
            String qc = StringUtils.trimToEmpty(results.getDataAsText(i, "QC Flags"));
            String key = subjectId + "_" + testName + "_" + result;

            String[] expectedVals = expected.get(key);
            assertNotNull("Unable to find expected values for key: " + key, expectedVals);

            assertEquals("Incorrect subjectId for: " + key, expectedVals[0], subjectId);
            if (!"".equals(expectedVals[1]))
                assertEquals("Incorrect date for: " + key, expectedVals[1], date);
            assertEquals("Incorrect testId for: " + key, expectedVals[2], testName);
            if (!expectedVals[3].equals(result))
            {
                Double expectedResult = Double.parseDouble(expectedVals[3]);
                Double observedResult = Double.parseDouble(result);
                assertEquals("Incorrect result for: " + key, expectedResult, observedResult);
            }
            assertEquals("Incorrect units for: " + key, expectedVals[4], units);
            assertEquals("Incorrect category for: " + key, expectedVals[5], category);

            if (!"".equals(expectedVals[6]))
                assertEquals("Incorrect diluent for: " + key, expectedVals[6], diluent);

            if (!"".equals(expectedVals[7]) && !expectedVals[7].equals(df))
            {
                Double expectedDf = Double.parseDouble(expectedVals[7]);
                Double observedDf = Double.parseDouble(df);
                assertEquals("Incorrect dilution factor for: " + key, expectedDf, observedDf);
            }

            assertEquals("Incorrect QC flag for: " + key, expectedVals[8], qc);

            i++;
        }
    }

    @Override           
    protected void setUpTest() throws Exception
    {
        super.setUpTest();

        ensureTestRecords();

    }

    private void ensureTestRecords() throws CommandException, IOException
    {
        log("Inserting testname records");

        Connection cn = createDefaultConnection(false);
        Map<String, String[]> tests = new HashMap<>();

        tests.put("Estradiol", new String[]{"E2", "pg/ml"});
        tests.put("Progesterone", new String[]{"P4", "ng/ml"});
        for (String test : tests.keySet())
        {
            SelectRowsCommand sr = new SelectRowsCommand("hormoneassay", "assay_tests");
            sr.addFilter("test", test, Filter.Operator.EQUAL);
            SelectRowsResponse resp = sr.execute(cn, getProjectName());

            //only insert row if it does not already exist
            if (resp.getRowCount().intValue() == 0)
            {
                InsertRowsCommand insertCmd = new InsertRowsCommand("hormoneassay", "assay_tests");
                Map<String, Object> row = new HashMap<>();
                row.put("test", test);
                row.put("code", tests.get(test)[0]);
                row.put("units", tests.get(test)[1]);
                insertCmd.addRow(row);
                SaveRowsResponse saveResp = insertCmd.execute(cn, getProjectName());
                assertEquals("Incorrect row count", 1, saveResp.getRowsAffected().intValue());
            }
        }
    }

    @Override
    protected List<Pair<String, String>> getAssaysToCreate()
    {
        List<Pair<String, String>> assays = new ArrayList<>();
        assays.add(Pair.of("Hormone Assay", ASSAY_NAME));

        return assays;
    }

    @Override
    protected List<String> getEnabledModules()
    {
        List<String> modules = new ArrayList<>();
        modules.add("HormoneAssay");
        return modules;
    }
}
