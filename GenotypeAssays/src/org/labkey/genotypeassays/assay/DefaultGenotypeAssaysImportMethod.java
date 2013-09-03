package org.labkey.genotypeassays.assay;

import org.labkey.api.data.Container;
import org.labkey.api.gwt.client.util.StringUtils;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.api.laboratory.assay.DefaultAssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.genotypeassays.GenotypeAssaysManager;

import java.util.List;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 3/7/13
 * Time: 7:08 PM
 */
public class DefaultGenotypeAssaysImportMethod extends DefaultAssayImportMethod
{
    public DefaultGenotypeAssaysImportMethod()
    {
        super(GenotypeAssaysManager.GENOTYPE_ASSAY_PROVIDER);
    }

    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new DefaultGenotypeAssayParser(this, c, u, assayId);
    }

    public class DefaultGenotypeAssayParser extends DefaultAssayParser
    {
        public DefaultGenotypeAssayParser(AssayImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        @Override
        protected List<Map<String, Object>> processRows(List<Map<String, Object>> rows, ImportContext context) throws BatchValidationException
        {
            List<Map<String, Object>> newRows = super.processRows(rows, context);
            for (Map<String, Object> row : newRows)
            {
                if (row.get(RESULT_FIELD) == null || StringUtils.trimToNull(row.get(RESULT_FIELD).toString()) == null)
                {
                    row.put("statusflag", "No Data");
                }
            }

            return rows;
        }
    }
}
