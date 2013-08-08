package org.labkey.genotypeassays.assay;

import org.json.JSONObject;
import org.labkey.api.laboratory.assay.AbstractAssayDataProvider;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.api.module.Module;
import org.labkey.api.view.ViewContext;
import org.labkey.genotypeassays.GenotypeAssaysManager;
import org.labkey.genotypeassays.GenotypeAssaysModule;

import java.util.Arrays;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/9/12
 * Time: 7:44 AM
 */
public class SSPAssayDataProvider extends AbstractAssayDataProvider
{
    public SSPAssayDataProvider(Module m){
        _providerName = GenotypeAssaysManager.SSP_ASSAY_PROVIDER;
        _module = m;

        AssayImportMethod method = new SSPAssayDefaultImportMethod(_providerName);
        _importMethods.add(method);
        _importMethods.add(new SSPPivotingImportMethod(method));
    }

    @Override
    public JSONObject getTemplateMetadata(ViewContext ctx)
    {
        JSONObject meta = super.getTemplateMetadata(ctx);
        JSONObject domainMeta = meta.getJSONObject("domains");

        JSONObject resultMeta = getJsonObject(domainMeta, "Results");
        String[] hiddenResultFields = new String[]{"plate"};
        for (String field : hiddenResultFields)
        {
            JSONObject json = getJsonObject(resultMeta, field);
            json.put("hidden", true);
            resultMeta.put(field, json);
        }

        String[] requiredFields = new String[]{"well", "subjectId", "category"};
        for (String field : requiredFields)
        {
            JSONObject json = getJsonObject(resultMeta, field);
            json.put("nullable", false);
            json.put("allowBlank", false);
            resultMeta.put(field, json);
        }

        String[] globalResultFields = new String[]{"sampleType"};
        for (String field : globalResultFields)
        {
            JSONObject json = getJsonObject(resultMeta, field);
            json.put("setGlobally", true);
            resultMeta.put(field, json);
        }

        domainMeta.put("Results", resultMeta);

        meta.put("domains", domainMeta);
        meta.put("colOrder", Arrays.asList("plate", "well", "category", "subjectId"));
        //meta.put("showPlateLayout", true);

        return meta;
    }
}

