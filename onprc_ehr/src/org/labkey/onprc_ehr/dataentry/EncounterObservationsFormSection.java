package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 12/2/13
 * Time: 1:12 PM
 */
public class EncounterObservationsFormSection extends EncounterChildFormSection
{
    public EncounterObservationsFormSection()
    {
        super("study", "Clinical Observations", "Observations", false);

        addClientDependency(ClientDependency.fromFilePath("ehr/data/ClinicalObservationsClientStore.js"));
        setClientStoreClass("EHR.data.ClinicalObservationsClientStore");
    }
}
