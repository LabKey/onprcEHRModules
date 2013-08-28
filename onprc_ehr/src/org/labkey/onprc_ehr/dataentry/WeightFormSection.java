package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class WeightFormSection extends SimpleGridPanel
{
    public WeightFormSection()
    {
        super("study", "Weight", "Weights");
        setClientStoreClass("EHR.data.WeightClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/WeightClientStore.js"));
    }
}
