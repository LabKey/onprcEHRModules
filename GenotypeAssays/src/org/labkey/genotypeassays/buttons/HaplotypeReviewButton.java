package org.labkey.genotypeassays.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.data.UserDefinedButtonConfig;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.genotypeassays.GenotypeAssaysModule;

import java.util.Arrays;
import java.util.LinkedHashSet;

/**
 * User: bimber
 * Date: 7/16/2014
 * Time: 5:37 PM
 */
public class HaplotypeReviewButton extends SimpleButtonConfigFactory
{
    public HaplotypeReviewButton()
    {
        super(ModuleLoader.getInstance().getModule(GenotypeAssaysModule.class), "Haplotype Review", "GenotypeAssays.buttons.haplotypeHandler(dataRegionName);", new LinkedHashSet<>(Arrays.asList(ClientDependency.fromPath("genotypeassays/buttons.js"))));
    }

    @Override
    public UserDefinedButtonConfig createBtn(TableInfo ti)
    {
        UserDefinedButtonConfig ret = super.createBtn(ti);
        ret.setRequiresSelectionMaxCount(0);
        ret.setRequiresSelectionMaxCount(1);

        return ret;
    }
}
