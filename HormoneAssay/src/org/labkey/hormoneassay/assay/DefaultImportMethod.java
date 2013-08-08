package org.labkey.hormoneassay.assay;

import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.gwt.client.util.StringUtils;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.api.laboratory.assay.DefaultAssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 11/1/12
 * Time: 4:51 PM
 */
public class DefaultImportMethod extends DefaultAssayImportMethod
{
    public static final String CATEGORY_FIELD = "category";

    public DefaultImportMethod(String providerName)
    {
        super(providerName);
    }

    @Override
    public JSONObject getMetadata(ViewContext ctx, ExpProtocol protocol)
    {
        JSONObject meta = super.getMetadata(ctx, protocol);

        JSONObject resultMeta = getJsonObject(meta, "Results");
        String[] globalResultFields = new String[]{"sampleType"};
        for (String field : globalResultFields)
        {
            JSONObject json = getJsonObject(resultMeta, field);
            json.put("setGlobally", true);
            resultMeta.put(field, json);
        }
        meta.put("Results", resultMeta);

        return meta;
    }

    @Override
    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new HormoneAssayParser(this, c, u, assayId);
    }

    protected class HormoneAssayParser extends DefaultAssayParser
    {
        public HormoneAssayParser(AssayImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        @Override
        protected List<Map<String, Object>> processRows(List<Map<String, Object>> rows, ImportContext context) throws BatchValidationException
        {
            rows = super.processRows(rows, context);
            return handleRows(rows);
        }
    }

    public static List<Map<String, Object>> handleRows(List<Map<String, Object>> rows)
    {
        List<Map<String, Object>> newRows = new ArrayList<Map<String, Object>>();
        for (Map<String, Object> row : rows)
        {
            Map<String, Object> map = new CaseInsensitiveHashMap<Object>(row);
            if (StringUtils.isEmpty((String)map.get(CATEGORY_FIELD)))
            {
                map.put(CATEGORY_FIELD, SAMPLE_CATEGORY.Unknown.name());
            }
            newRows.add(map);
        }

        return newRows;
    }
}
