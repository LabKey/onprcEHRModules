package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;

/**
 * User: Kolli
 * Date: 7/7/19
 * Time: 10:36 AM
 */
public class PMIC_DEXAFormSection extends SimpleGridPanel
{
    public PMIC_DEXAFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public PMIC_DEXAFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "PMIC_DEXAImagingData", "DEXA", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PMIC_DEXA.js"));
        addConfigSource("DEXA");
//        _showLocation = true;
    }
}