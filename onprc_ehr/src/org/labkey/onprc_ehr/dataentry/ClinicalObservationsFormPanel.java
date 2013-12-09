package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 11/16/13
 * Time: 11:42 AM
 */
public class ClinicalObservationsFormPanel extends SimpleFormSection
{
    public ClinicalObservationsFormPanel()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public ClinicalObservationsFormPanel(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Observations", "Observations", "ehr-gridpanel", location);
        addClientDependency(ClientDependency.fromFilePath("ehr/data/ClinicalObservationsClientStore.js"));
        setClientStoreClass("EHR.data.ClinicalObservationsClientStore");
    }
}
