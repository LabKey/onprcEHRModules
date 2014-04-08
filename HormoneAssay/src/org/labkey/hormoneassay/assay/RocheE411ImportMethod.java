package org.labkey.hormoneassay.assay;

import au.com.bytecode.opencsv.CSVWriter;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExpExperiment;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.DefaultAssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.laboratory.assay.ParserErrors;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.Pair;
import org.labkey.api.view.ViewContext;
import org.labkey.hormoneassay.HormoneAssayManager;
import org.labkey.hormoneassay.HormoneAssaySchema;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 11/1/12
 * Time: 4:53 PM
 */
public class RocheE411ImportMethod extends DefaultImportMethod
{
    public static final String NAME = "Roche E411";
    private static final String DILUENT_FIELD = "diluent";
    private static final String RESULT_FIELD = "result";
    private static final String RAW_RESULT_FIELD = "rawResult";
    private static final String DILUTION_FACTOR_FIELD = "dilutionFactor";
    private static final String QCFLAG_FIELD = "qcflag";
    private static final String SUBJECTID_FIELD = "subjectId";

    public RocheE411ImportMethod(String providerName)
    {
        super(providerName);
    }

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public String getLabel()
    {
        return NAME;
    }

    @Override
    public String getTooltip()
    {
        return "Choose this option to upload data directly from the output of a Roche E411.  NOTE: this import method expects that you upload sample information prior to creating the experiment run.";
    }

    @Override
    public boolean hideTemplateDownload()
    {
        return true;
    }

    @Override
    public String getTemplateInstructions()
    {
        return "This import path assumes you prepared this run by creating/saving a template from this site, which defines your plate layout and sample information.  The results you enter below will be merged with that previously imported sample information using well.  When you select a saved plate template using the \'Saved Sample Information\' section above, you should see a list of the samples you uploaded.";
    }

    @Override
    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new Parser(this, c, u, assayId);
    }

    @Override
    public String getExampleDataUrl(ViewContext ctx)
    {
        return AppProps.getInstance().getContextPath() + "/hormoneassay/SampleData/RocheE411.txt";
    }

    @Override
    public JSONObject getMetadata(ViewContext ctx, ExpProtocol protocol)
    {
        JSONObject meta = super.getMetadata(ctx, protocol);

        JSONObject runMeta = getJsonObject(meta, "Run");
        JSONObject json = getJsonObject(runMeta, "instrument");
        json.put("defaultValue", "Roche E411");
        runMeta.put("instrument", json);

        json = getJsonObject(runMeta, "method");
        json.put("defaultValue", "Electrochemiluminescence");
        runMeta.put("method", json);

        meta.put("Run", runMeta);

        JSONObject resultMeta = getJsonObject(meta, "Results");
        json = getJsonObject(resultMeta, "sampleType");
        json.put("defaultValue", "Serum");
        json.put("setGlobally", false);
        resultMeta.put("sampleType", json);
        meta.put("Results", resultMeta);

        return meta;
    }

    @Override
    public boolean supportsRunTemplates()
    {
        return true;
    }

    private class Parser extends HormoneAssayParser
    {
        private Map<Integer, Map<String, Object>> _testsById = null;
        private Map<String, Map<String, Object>> _testsByName = null;
        private static final String SAMPLE_IDENTIFIER = "SampleIdentifier";
        private Map<String, List<Map<String, Object>>> _blankMap;

        public Parser(AssayImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        @Override
        public Pair<ExpExperiment, ExpRun> saveBatch(JSONObject json, File file, String fileName, ViewContext ctx) throws BatchValidationException
        {
            Integer templateId = json.getInt("TemplateId");

            Pair<ExpExperiment, ExpRun> result = super.saveBatch(json, file, fileName, ctx);

            saveTemplate(ctx, templateId, result.second.getRowId());
            return result;
        }

        /**
         * We read the entire raw file, transforming into 1 row per sample/test combination
         * We return a TSV string, which is later fed into a TabLoader.  This is done so we let that code handle type conversion
         */
        @Override
        protected String readRawFile(ImportContext context) throws BatchValidationException
        {
            ParserErrors errors = context.getErrors();

            Map<Integer, Integer> testColumnMap = new HashMap<>();

            Map<String, Integer> headerMap = new HashMap<>();
            headerMap.put("well", 3);
            headerMap.put(SAMPLE_IDENTIFIER, 6);
            headerMap.put("RunDate", 7);
            headerMap.put("PreDilution", 16); //dilution performed by user

            try (StringWriter sw = new StringWriter(); CSVWriter out = new CSVWriter(sw, '\t'))
            {
                //append header:
                List<String> headerRow = new ArrayList<>();
                headerRow.add("originalRowIdx");
                for (String field : headerMap.keySet())
                {
                    headerRow.add(field);
                }

                headerRow.add("testId");
                headerRow.add("testName");
                headerRow.add("result");
                headerRow.add("units");
                headerRow.add("qcflag");
                headerRow.add("dilution");
                headerRow.add("category");
                out.writeNext(headerRow.toArray(new String[headerRow.size()]));

                int idx = 0;
                for (List<String> cells : getFileLines(context.getFile()))
                {
                    idx++;

                    String line = StringUtils.trimToNull(StringUtils.join(cells, "\n"));
                    if (StringUtils.isEmpty(line))
                        continue;

                    //process testIDs and header
                    if (idx == 1)
                    {
                        int cellIdx = 20; //starting with the 20th cell
                        for (String cell : cells)
                        {
                            if (!StringUtils.isEmpty(cell))
                            {
                                try
                                {
                                    testColumnMap.put(cellIdx, Integer.parseInt(cell));
                                }
                                catch (NumberFormatException e)
                                {
                                    errors.addError("Not a valid integer: " + cell);
                                }
                            }

                            cellIdx++;
                        }
                    }
                    else if (idx == 2)
                    {
                        //this is the header row
                        continue;
                    }

                    //then test results
                    else
                    {
                        //find the type of sample
                        String category = "";
                        Integer type = Integer.parseInt(cells.get(0));
                        if (type == 3)
                        {
                            category = "Pos Control";
                        }

                        //this row could contain many test results
                        for (Integer start : testColumnMap.keySet())
                        {
                            if (start >= cells.size())
                                continue;

                            if (StringUtils.isEmpty(cells.get(start)))
                                continue;

                            //append fields shared across all tests
                            List<String> toAdd = new ArrayList<>();
                            toAdd.add(String.valueOf(idx));

                            for (String field : headerMap.keySet())
                            {
                                toAdd.add(cells.get(headerMap.get(field)));
                            }

                            //then the fields specific ot this test
                            Integer testId = testColumnMap.get(start);
                            toAdd.add(testId.toString());
                            toAdd.add(resolveTestId(testId));

                            //result
                            int cellIdx = start;
                            toAdd.add(cells.get(cellIdx));

                            //units
                            cellIdx = start + 1;
                            if (cells.size() > cellIdx)
                                toAdd.add(cells.get(cellIdx));

                            //d_alm (qcflag)
                            cellIdx = start + 2;
                            if (cells.size() > cellIdx)
                                toAdd.add(cells.get(cellIdx));

                            //dilution
                            cellIdx = start + 4;
                            if (cells.size() > cellIdx)
                                toAdd.add(cells.get(cellIdx));

                            //category
                            toAdd.add(category);

                            out.writeNext(toAdd.toArray(new String[toAdd.size()]));
                        }
                    }
                }

                return sw.toString();
            }
            catch (IOException e)
            {
                context.getErrors().addError(e.getMessage());
                throw context.getErrors().getErrors();
            }
        }

        private String resolveTestId(int testId)
        {
            if (_testsById == null)
                cacheRocheTests();

            Map<String, Object> row = _testsById.get(testId);
            if (row == null)
                return null;

            return (String)row.get("test");
        }

        private void cacheRocheTests()
        {
            TableInfo ti = HormoneAssaySchema.getInstance().getSchema().getTable(HormoneAssaySchema.TABLE_ROCHETESTS);
            TableSelector ts = new TableSelector(ti);
            Map<String, Object>[] rows = ts.getMapArray();
            _testsById = new HashMap<Integer, Map<String, Object>>();
            _testsByName = new HashMap<String, Map<String, Object>>();

            for (Map<String, Object> map : rows)
            {
                Integer key = (Integer)map.get("testkey");
                if (key != null)
                {
                    _testsById.put(key, map);
                }

                String test = (String)map.get("test");
                if (test != null)
                {
                    _testsByName.put(test, map);
                }
            }
        }

        @Override
        protected List<Map<String, Object>> processRows(List<Map<String, Object>> rows, ImportContext context) throws BatchValidationException
        {
            _blankMap = new HashMap<>();

            List<Map<String, Object>> newRows = new ArrayList<Map<String, Object>>();
            ParserErrors errors = context.getErrors();

            String keyProperty = "well";
            Map<String, Map<String, Object>> templateRows = getTemplateRowMap(context, keyProperty);

            ListIterator<Map<String, Object>> rowsIter = rows.listIterator();
            int rowIdx = 0;
            boolean diluentCalcNeeded = false;
            while (rowsIter.hasNext())
            {
                try
                {
                    rowIdx++;

                    Map<String, Object> row = rowsIter.next();
                    Map<String, Object> map = new CaseInsensitiveHashMap<Object>(row);
                    appendPromotedResultFields(map, context);

                    if (!map.containsKey(keyProperty) || map.get(keyProperty) == null)
                    {
                        errors.addError("Missing sample name for row: " + getRowIdx(map, rowIdx));
                        continue;
                    }

                    //associate/merge sample information with the incoming results
                    if (map.containsKey("category") && !StringUtils.isEmpty((String)map.get("category")))
                    {
                        String id = (String)map.get(SAMPLE_IDENTIFIER);

                        map.put(SUBJECTID_FIELD, id);
                        map.put("sampleType", "None");
                    }
                    else
                    {
                        if (!mergeTemplateRow(keyProperty, templateRows, map, context))
                            continue;
                    }

                    //check for blank
                    if (map.get(CATEGORY_FIELD).equals(SAMPLE_CATEGORY.Blank.name()))
                    {
                        if (map.get(DILUENT_FIELD) == null)
                        {
                            errors.addError("Row " + getRowIdx(map, rowIdx) + ": blank is missing a diluent");
                            continue;
                        }

                        List<Map<String, Object>> list = _blankMap.get(map.get(DILUENT_FIELD));
                        if (list == null)
                            list = new ArrayList<Map<String, Object>>();

                        list.add(map);
                        _blankMap.put((String)map.get(DILUENT_FIELD), list);
                    }
                    else
                    {
                        if (map.get(DILUENT_FIELD) != null)
                            diluentCalcNeeded = true;
                    }

                    if (org.labkey.api.gwt.client.util.StringUtils.isEmpty((String) map.get(CATEGORY_FIELD)))
                    {
                        map.put(CATEGORY_FIELD, SAMPLE_CATEGORY.Unknown.name());
                    }

                    newRows.add(map);
                }
                catch (IllegalArgumentException e)
                {
                    errors.addError(e.getMessage());
                }
            }

            errors.confirmNoErrors();

            ensureTemplateRowsHaveResults(templateRows, context);

            if (diluentCalcNeeded)
                subtractBlanks(newRows, context);

            return newRows;
        }

        private void subtractBlanks(List<Map<String, Object>> rows, ImportContext context)
        {
            Map<String, Double> blanks = new HashMap<String, Double>();

            for (String diluent : _blankMap.keySet())
            {
                List<Map<String, Object>> blankList = _blankMap.get(diluent);
                Double total = 0.0;
                for (Map<String, Object> blankRow : blankList)
                {
                    total += (Double)blankRow.get(RESULT_FIELD);
                }
                Double avg = (total / blankList.size());
                blanks.put(diluent, avg);
            }

            int rowIdx = 0;
            for (Map<String, Object> row : rows)
            {
                rowIdx++;

                if (row.get(DILUENT_FIELD) == null)
                    continue;

                if (SAMPLE_CATEGORY.Blank.name().equals(row.get(CATEGORY_FIELD)))
                    continue;

                String diluent = (String)row.get(DILUENT_FIELD);
                Double blank = blanks.get(diluent);
                if (blank == null)
                {
                    context.getErrors().addError("Row " + getRowIdx(row, rowIdx) + ": unable to find a blank for diluent: " + diluent);
                    continue;
                }

                //TODO: should this also match on test id?
                Double result = (Double)row.get(RESULT_FIELD);
                row.put(RAW_RESULT_FIELD, result);

                if (blank > result)
                {
                    if (row.get(QCFLAG_FIELD) == null)
                        row.put(QCFLAG_FIELD, "Blank greater than result");
                    else
                        row.put(QCFLAG_FIELD, row.get(QCFLAG_FIELD) + ", Blank greater than result");
                }

                result = result - blank;
                row.put(RESULT_FIELD, result);
            }
        }
    }
}