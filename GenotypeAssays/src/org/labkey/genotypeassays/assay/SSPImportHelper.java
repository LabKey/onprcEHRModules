package org.labkey.genotypeassays.assay;

import org.apache.commons.lang3.StringUtils;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;
import org.labkey.api.data.ForeignKey;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.security.User;
import org.labkey.api.study.assay.AssayProtocolSchema;
import org.labkey.api.study.assay.AssayProvider;

import java.util.Collections;
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
    private ExpProtocol _protocol;
    private AssayProvider _provider;
    private User _u;
    private Container _c;

    public SSPImportHelper(ExpProtocol protocol, AssayProvider provider, User u, Container c)
    {
        _protocol = protocol;
        _provider = provider;
        _u = u;
        _c = c;
    }

    public void normalizeResultField(Map<String, Object> row, ImportContext context)
    {
        if (!row.containsKey("result"))
            return;

        String result = StringUtils.trimToNull((String)row.get("result"));
        if (result == null)
            return;

        Map<String, String> allowableResults = getResultValues();
        if (!allowableResults.isEmpty())
        {
            String normalized = allowableResults.get(row.get("result"));
            if (normalized != null)
                row.put("result", normalized);
            else
                context.getErrors().addError("Unknown value for result: " + row.get("result") + " for primer: " + row.get("primerPair"));
        }
    }

    private TableInfo getResultLookupTable()
    {
        AssayProtocolSchema schema = _provider.createProtocolSchema(_u, _c, _protocol, null);
        TableInfo assayTable = schema.createDataTable();

        ForeignKey fk = assayTable.getUserSchema().getTable("data").getColumn("result").getFk();
        if (fk != null)
        {
            return fk.getLookupTableInfo();
        }

        return null;
    }

    private Map<String, String> getResultValues()
    {
        if (_allowableResults != null)
            return _allowableResults;

        TableInfo ti = getResultLookupTable();
        if (ti == null)
        {
            _allowableResults = Collections.emptyMap();
            return _allowableResults;
        }

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
