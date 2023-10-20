/*
// * User: Kolli
// * Date: 4/01/2020
// * Time: 10:36 AM
 */

package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.view.template.ClientDependency;

public class IPC_ServiceRequestDetailsFormSection extends SimpleFormPanelSection
{
    public IPC_ServiceRequestDetailsFormSection(String label)
    {
        super("study", "IPC_ServiceRequestDetails", label);
        setTemplateMode(TEMPLATE_MODE.NONE);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/IPC_ServiceRequestDetails.js"));
        addConfigSource("ServiceRequestDetails");
    }
}

