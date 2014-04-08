package org.labkey.genotypeassays.assay;

import org.json.JSONObject;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.api.view.ViewContext;
import org.labkey.genotypeassays.GenotypeAssaysManager;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 4/24/13
 * Time: 4:14 PM
 */
public class DefaultSnpAssayImportMethod extends DefaultAssayImportMethod
{
    public DefaultSnpAssayImportMethod()
    {
        super(GenotypeAssaysManager.SNP_ASSAY_PROVIDER);
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
}
