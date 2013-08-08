package org.labkey.hormoneassay.assay;

import org.apache.log4j.Level;
import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.gwt.client.util.StringUtils;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.laboratory.assay.PivotingAssayParser;
import org.labkey.api.laboratory.assay.PivotingImportMethod;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;
import org.labkey.hormoneassay.HormoneAssaySchema;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 3/8/13
 * Time: 3:17 PM
 */
public class PivotedImportMethod extends PivotingImportMethod
{
    public PivotedImportMethod(AssayImportMethod method)
    {
        super(method, "testname", "result", HormoneAssaySchema.getInstance().getSchema().getTable(HormoneAssaySchema.TABLE_ASSAYTESTS), "test");
    }

    @Override
    public String getName()
    {
        return "pivotedByTest";
    }

    @Override
    public String getLabel()
    {
        return "Pivoted By Test";
    }

    @Override
    public JSONObject getMetadata(ViewContext ctx, ExpProtocol protocol)
    {
        return _importMethod.getMetadata(ctx, protocol);
    }

    public String getTooltip()
    {
        return "Choose this option to upload data using a template with many test results per row";
    }

    @Override
    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new Parser(this, c, u, assayId);
    }

    private class Parser extends PivotingAssayParser
    {
        private final Pattern _testAndUnits = Pattern.compile("(.*)(\\(.*\\))");
        private Map<String, String> _allowableResults = null;

        public Parser(PivotingImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        @Override
        protected String handleUnknownColumn(String col, Map<String, String> allowable, ImportContext context)
        {
            String guessed = guessTest(col);
            if (guessed != null)
            {
                return guessed;
            }
            else
            {
                //TODO: allow a flag that lets us assume unknown columns hold results
                context.getErrors().addError("Unknown column: " + col, Level.WARN);
            }

            return null;
        }

        public String guessTest(String testId)
        {
            Map<String, String> allowableResults = getResultValues();
            if (allowableResults.containsKey(testId))
                return allowableResults.get(testId);

            if (allowableResults.containsKey(testId))
            {
                return allowableResults.get(testId);
            }
            else
            {
                //this suggests the head also contains units
                if (_testAndUnits.matcher(testId).matches())
                {
                    Matcher matcher = _testAndUnits.matcher(testId);
                    matcher.find();
                    String guess = matcher.group(1);
                    guess = StringUtils.trimToNull(guess);
                    if (guess != null && allowableResults.containsKey(guess))
                        return allowableResults.get(guess);
                }

                return null;
            }
        }

        private Map<String, String> getResultValues()
        {
            if (_allowableResults != null)
                return _allowableResults;

            String NAME_FIELD = "test";

            TableInfo ti = HormoneAssaySchema.getInstance().getSchema().getTable(HormoneAssaySchema.TABLE_ASSAYTESTS);
            TableSelector ts = new TableSelector(ti);
            Map<String, Object>[] rows = ts.getMapArray();
            Map<String, String> ret = new CaseInsensitiveHashMap();
            for (Map<String, Object> row : rows)
            {
                ret.put((String)row.get(NAME_FIELD), (String)row.get(NAME_FIELD));

                if (row.get("code") != null)
                {
                    String[] tokens = ((String)row.get("code")).split(",");
                    for (String token : tokens)
                    {
                        token = StringUtils.trimToNull(token);
                        if (token != null)
                            ret.put(token, (String)row.get(NAME_FIELD));
                    }
                }
            }
            return _allowableResults = ret;
        }

        @Override
        protected List<Map<String, Object>> processRows(List<Map<String, Object>> rows, ImportContext context) throws BatchValidationException
        {
            rows = super.processRows(rows, context);
            return DefaultImportMethod.handleRows(rows);
        }
    }
}
