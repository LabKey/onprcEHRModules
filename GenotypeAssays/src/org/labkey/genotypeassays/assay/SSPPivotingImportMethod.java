package org.labkey.genotypeassays.assay;

import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.laboratory.assay.ParserErrors;
import org.labkey.api.laboratory.assay.PivotingAssayParser;
import org.labkey.api.laboratory.assay.PivotingImportMethod;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;
import org.labkey.genotypeassays.GenotypeAssaysSchema;

import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/9/12
 * Time: 7:58 AM
 */
public class SSPPivotingImportMethod extends PivotingImportMethod
{
    public SSPPivotingImportMethod(AssayImportMethod method)
    {
        super(method, "primerPair", "result", GenotypeAssaysSchema.getInstance().getTable(GenotypeAssaysSchema.TABLE_PRIMER_PAIRS), "primername");
    }

    @Override
    public String getName()
    {
        return "pivotedByAllele";
    }

    @Override
    public String getLabel()
    {
        return "Pivoted By Allele Name";
    }

    @Override
    public JSONObject getMetadata(ViewContext ctx, ExpProtocol protocol)
    {
        return _importMethod.getMetadata(ctx, protocol);
    }

    public String getTooltip()
    {
        return "Choose this option to upload data using a template with many allele typings per row";
    }

    @Override
    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new Parser(this, c, u, assayId);
    }

    private class Parser extends PivotingAssayParser
    {
        public Parser(PivotingImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        @Override
        protected List<Map<String, Object>> processRowsFromFile(List<Map<String, Object>> rows, ImportContext context) throws BatchValidationException
        {
            ListIterator<Map<String, Object>> rowsIter = rows.listIterator();
            ParserErrors errors = context.getErrors();

            SSPImportHelper helper = new SSPImportHelper(_protocol, _provider, _user, _container);
            List<Map<String, Object>> newRows = new ArrayList<>();

            while (rowsIter.hasNext())
            {
                Map<String, Object> row = new CaseInsensitiveHashMap<>(rowsIter.next());
                appendPromotedResultFields(row, context);

                helper.normalizeResultField(row, context);
                newRows.add(row);
            }

            errors.confirmNoErrors();

            return newRows;
        }
    }
}
