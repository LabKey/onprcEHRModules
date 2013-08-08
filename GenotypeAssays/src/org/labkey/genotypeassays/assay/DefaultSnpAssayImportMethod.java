package org.labkey.genotypeassays.assay;

import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
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
}
