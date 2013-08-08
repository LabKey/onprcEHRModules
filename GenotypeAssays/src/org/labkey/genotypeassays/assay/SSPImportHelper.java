package org.labkey.genotypeassays.assay;

import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.gwt.client.util.StringUtils;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.ValidationException;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.genotypeassays.GenotypeAssaysSchema;

import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/10/12
 * Time: 7:50 PM
 */
public class SSPImportHelper
{
    private Map<String, String> _allowableResults = null;

    public SSPImportHelper()
    {

    }

    public void normalizeResultField(Map<String, Object> row, ImportContext context)
    {
        if (!row.containsKey("result"))
            return;

        String result = StringUtils.trimToNull((String)row.get("result"));
        if (result == null)
            return;

        Map<String, String> allowableResults = getResultValues();
        String normalized = allowableResults.get(row.get("result"));
        if (normalized != null)
            row.put("result", normalized);
        else
            context.getErrors().addError("Unknown value for result: " + row.get("result") + " for primer: " + row.get("primerPair"));
    }

    private Map<String, String> getResultValues()
    {
        if (_allowableResults != null)
            return _allowableResults;

        TableInfo ti = GenotypeAssaysSchema.getInstance().getTable(GenotypeAssaysSchema.TABLE_SSP_RESULT_TYPES);
        TableSelector ts = new TableSelector(ti);
        Map<String, Object>[] rows = ts.getMapArray();
        Map<String, String> ret = new CaseInsensitiveHashMap();
        for (Map<String, Object> row : rows)
        {
            ret.put((String)row.get("result"), (String)row.get("result"));
            if (row.get("meaning") != null)
                ret.put((String)row.get("meaning"), (String)row.get("result"));
            if (row.get("importAliases") != null)
            {
                String[] tokens = ((String)row.get("importAliases")).split(",");
                for (String token : tokens)
                {
                    token = StringUtils.trimToNull(token);
                    if (token != null)
                        ret.put(token, (String)row.get("result"));
                }
            }
        }
        return _allowableResults = ret;
    }
}
