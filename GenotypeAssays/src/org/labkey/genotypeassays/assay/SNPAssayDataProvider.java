package org.labkey.genotypeassays.assay;

import org.json.JSONObject;
import org.labkey.api.laboratory.assay.AbstractAssayDataProvider;
import org.labkey.api.module.Module;
import org.labkey.api.view.ViewContext;
import org.labkey.genotypeassays.GenotypeAssaysManager;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 4/24/13
 * Time: 4:12 PM
 */
public class SNPAssayDataProvider extends AbstractAssayDataProvider
{
    public SNPAssayDataProvider(Module m)
    {
        _providerName = GenotypeAssaysManager.SNP_ASSAY_PROVIDER;
        _module = m;

        _importMethods.add(new DefaultSnpAssayImportMethod());
        _importMethods.add(new BeadStudioImportMethod());
        _importMethods.add(new QuantStudioImportMethod());
    }

    @Override
    public JSONObject getTemplateMetadata(ViewContext ctx)
    {
        return super.getTemplateMetadata(ctx);
    }
}
