package org.labkey.genotypeassays.assay;

import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.laboratory.NavItem;
import org.labkey.api.laboratory.SimpleSettingsItem;
import org.labkey.api.laboratory.assay.AbstractAssayDataProvider;
import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;
import org.labkey.genotypeassays.GenotypeAssaysManager;
import org.labkey.genotypeassays.GenotypeAssaysModule;

import java.util.ArrayList;
import java.util.List;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/9/12
 * Time: 7:44 AM
 */
public class GenotypeAssayDataProvider extends AbstractAssayDataProvider
{
    public GenotypeAssayDataProvider(Module m)
    {
        _providerName = GenotypeAssaysManager.GENOTYPE_ASSAY_PROVIDER;
        _module = m;

        _importMethods.add(new DefaultGenotypeAssaysImportMethod());
        _importMethods.add(new UCDavisSTRImportMethod());
    }

    @Override
    public JSONObject getTemplateMetadata(ViewContext ctx)
    {
        return super.getTemplateMetadata(ctx);
    }

    @Override
    public List<NavItem> getSettingsItems(Container c, User u)
    {
        List<NavItem> items = new ArrayList<NavItem>();
        String categoryName = "Genotype Assays";
        if (ContainerManager.getSharedContainer().equals(c))
        {
            items.add(new SimpleSettingsItem(this, GenotypeAssaysModule.SCHEMA_NAME, "assaytypes", categoryName, "Assay Types"));
            items.add(new SimpleSettingsItem(this, GenotypeAssaysModule.SCHEMA_NAME, "primer_pairs", categoryName, "SSP Primer Pairs"));
            items.add(new SimpleSettingsItem(this, GenotypeAssaysModule.SCHEMA_NAME, "ssp_result_types", categoryName, "SSP Result Types"));
        }

        return items;
    }
}
