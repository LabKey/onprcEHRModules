package org.labkey.genotypeassays.assay;

import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.genotypeassays.GenotypeAssaysManager;

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
}
