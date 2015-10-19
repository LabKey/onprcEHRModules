package org.labkey.hormoneassay;

import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.NavItem;
import org.labkey.api.laboratory.SimpleSettingsItem;
import org.labkey.api.laboratory.assay.AbstractAssayDataProvider;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;
import org.labkey.hormoneassay.assay.DefaultImportMethod;
import org.labkey.hormoneassay.assay.PivotedImportMethod;
import org.labkey.hormoneassay.assay.RocheE411ImportMethod;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 11/1/12
 * Time: 4:27 PM
 */
public class HormoneAssayDataProvider extends AbstractAssayDataProvider
{
    public HormoneAssayDataProvider(Module m)
    {
        _providerName = HormoneAssayManager.ASSAY_PROVIDER_NAME;
        _module = m;

        AssayImportMethod method = new DefaultImportMethod(_providerName);
        _importMethods.add(method);
        _importMethods.add(new PivotedImportMethod(method));
        _importMethods.add(new RocheE411ImportMethod(_providerName));
    }

    @Override
    public List<NavItem> getSettingsItems(Container c, User u)
    {
        List<NavItem> items = new ArrayList<NavItem>();
        String categoryName = "Hormone Assay";
        if (ContainerManager.getSharedContainer().equals(c))
        {
            items.add(new SimpleSettingsItem(this, HormoneAssaySchema.NAME, "instruments", categoryName, "Instruments"));
            items.add(new SimpleSettingsItem(this, HormoneAssaySchema.NAME, "RocheE411_Tests", categoryName, "Roche E411 Tests"));
            items.add(new SimpleSettingsItem(this, HormoneAssaySchema.NAME, "assay_tests", categoryName, "Tests"));
            items.add(new SimpleSettingsItem(this, HormoneAssaySchema.NAME, "diluents", categoryName, "Diluents"));
        }

        return items;
    }

    @Override
    public JSONObject getTemplateMetadata(ViewContext ctx)
    {
        JSONObject meta = super.getTemplateMetadata(ctx);
        JSONObject domainMeta = meta.getJSONObject("domains");

        JSONObject resultMeta = getJsonObject(domainMeta, "Results");
        String[] hiddenResultFields = new String[]{"plate", "units", "qcflag"};
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

        JSONObject json = getJsonObject(resultMeta, "testName");
        json.put("nullable", true);
        json.put("allowBlank", true);
        json.put("required", false);
        json.put("hidden", true);
        resultMeta.put("testName", json);

        json = getJsonObject(resultMeta, "sampleType");
        json.put("defaultValue", "Serum");
        resultMeta.put("sampleType", json);

        domainMeta.put("Results", resultMeta);

        meta.put("domains", domainMeta);
        meta.put("hideDownloadBtn", true);
        meta.put("colOrder", Arrays.asList("plate", "well", "category", "subjectId", "testName"));

        return meta;
    }
}
