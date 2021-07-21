package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;

/**
 * User: Kolli
 * Date: 7/7/19
 * Time: 10:36 AM
 */
public class PMIC_PETFormSection extends SimpleGridPanel
{
    public PMIC_PETFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }


    public PMIC_PETFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "PMIC_PETImagingData", "PET", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/PMIC_PET.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/form/field/PMIC_DoseCalcField.js"));
        addConfigSource("PET");
//        _showLocation = true;
    }

}