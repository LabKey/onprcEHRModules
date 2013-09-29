package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class PairingFormSection extends SimpleFormSection
{
    public PairingFormSection()
    {
        super("study", "pairings", "Pairing Observations", "ehr-gridpanel");
        setConfigSources(Collections.singletonList("Task"));
        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/LowestCageField.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/data/PairingClientStore.js"));
        setClientStoreClass("EHR.data.PairingClientStore");
    }
}
