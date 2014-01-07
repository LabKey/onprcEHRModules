package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 11/16/13
 * Time: 11:42 AM
 */
public class ClinicalObservationsFormSection extends SimpleFormSection
{
    public ClinicalObservationsFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Observations", "Observations", "ehr-clinicalobservationgridpanel", location);
        addClientDependency(ClientDependency.fromFilePath("ehr/data/ClinicalObservationsClientStore.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/grid/ClinicalObservationGridPanel.js"));

        setClientStoreClass("EHR.data.ClinicalObservationsClientStore");
    }
}
