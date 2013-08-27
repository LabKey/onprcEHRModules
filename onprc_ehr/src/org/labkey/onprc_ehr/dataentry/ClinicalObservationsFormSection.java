package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 4/27/13
 * Time: 10:54 AM
 */
public class ClinicalObservationsFormSection extends SimpleFormSection
{
    public ClinicalObservationsFormSection()
    {
        super("study", "Clinical Observations", "Observations", "ehr-observationspanel", EHRService.FORM_SECTION_LOCATION.Tabs);
        addClientDependency(ClientDependency.fromFilePath("ehr/panel/ObservationsPanel.js"));
    }
}
