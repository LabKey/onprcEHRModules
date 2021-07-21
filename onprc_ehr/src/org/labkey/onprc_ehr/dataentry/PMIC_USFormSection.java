package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;

/**
 * User: Kolli
 * Date: 7/7/19
 * Time: 10:36 AM
 */
public class PMIC_USFormSection extends SimpleGridPanel
{
    public PMIC_USFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public PMIC_USFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "PMIC_USImagingData", "Ultrasound", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PMIC_US.js"));
        addConfigSource("US");
//        _showLocation = true;
    }
}