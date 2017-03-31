package org.labkey.genotypeassays.assay;

import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.api.laboratory.assay.DefaultAssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.laboratory.assay.ParserErrors;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/9/12
 * Time: 7:47 AM
 */
public class SSPAssayDefaultImportMethod extends DefaultAssayImportMethod
{
    public SSPAssayDefaultImportMethod(String providerName)
    {
        super(providerName);
    }

    @Override
    public JSONObject getMetadata(ViewContext ctx, ExpProtocol protocol)
    {
        JSONObject meta = super.getMetadata(ctx, protocol);

        JSONObject resultsMeta = getJsonObject(meta, "Results");

        JSONObject sampleType = getJsonObject(resultsMeta, "sampleType");
        sampleType.put("setGlobally", true);
        sampleType.put("defaultValue", "gDNA");
        resultsMeta.put("sampleType", sampleType);

        meta.put("Results", resultsMeta);

        return meta;
    }

    @Override
    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new Parser(this, c, u, assayId);
    }

    private class Parser extends DefaultAssayParser
    {
        public Parser(AssayImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        @Override
        protected List<Map<String, Object>> processRowsFromFile(List<Map<String, Object>> rows, ImportContext context) throws BatchValidationException
        {
            ListIterator<Map<String, Object>> rowsIter = rows.listIterator();
            ParserErrors errors = context.getErrors();
            SSPImportHelper helper = new SSPImportHelper(_protocol, _provider, _user, _container);
            List<Map<String, Object>> newRows = new ArrayList<Map<String, Object>>();

            while (rowsIter.hasNext())
            {
                Map<String, Object> row = new CaseInsensitiveHashMap(rowsIter.next());
                appendPromotedResultFields(row, context);

                helper.normalizeResultField(row, context);
                newRows.add(row);
            }

            errors.confirmNoErrors();

            return newRows;
        }
    }
}
