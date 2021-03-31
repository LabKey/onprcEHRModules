package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;

/**
 * User: Kolli
 * Date: 7/7/19
 * Time: 10:36 AM
 */
public class PMIC_CTFormSection extends SimpleGridPanel
{
    public PMIC_CTFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public PMIC_CTFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "PMIC_CTImagingData", "CT", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PMIC_CT.js"));
        addConfigSource("CT");
//        _showLocation = true;
    }
}