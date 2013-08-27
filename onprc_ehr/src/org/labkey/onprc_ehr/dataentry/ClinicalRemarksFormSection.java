package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 4/27/13
 * Time: 10:54 AM
 */
public class ClinicalRemarksFormSection extends SimpleFormSection
{
    public ClinicalRemarksFormSection()
    {
        super("study", "Clinical Remarks", "Remarks", "ehr-clinicalremarkpanel", EHRService.FORM_SECTION_LOCATION.Body);
        addClientDependency(ClientDependency.fromFilePath("ehr/panel/ClinicalRemarkPanel.js"));
    }
}
