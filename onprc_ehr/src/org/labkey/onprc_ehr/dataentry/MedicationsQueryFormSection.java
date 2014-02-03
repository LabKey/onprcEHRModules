package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SingleQueryFormSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 2/1/14
 * Time: 1:28 PM
 */
public class MedicationsQueryFormSection extends SingleQueryFormSection
{
    public MedicationsQueryFormSection(String schema, String query, String label)
    {
        super(schema, query, label);

        addConfigSource("SingleQuery");

        setClientStoreClass("EHR.data.DrugAdministrationRunsClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SedationWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddScheduledTreatmentsWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/SingleQuery.js"));
    }
}
