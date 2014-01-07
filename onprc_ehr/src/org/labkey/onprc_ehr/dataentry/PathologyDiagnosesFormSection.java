package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 12/28/13
 * Time: 3:56 PM
 */
public class PathologyDiagnosesFormSection extends PathologyFormSection
{
    public PathologyDiagnosesFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label);

        setClientStoreClass("EHR.data.PathologyDiagnosesStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/PathologyDiagnosesStore.js"));
    }
}
