//package org.labkey.onprc_ehr.dataentry;
//
//import org.labkey.api.ehr.EHRService;
//import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
//import org.labkey.api.view.template.ClientDependency;
//
///**
// * User: Kolli
// * Date: 4/01/2020
// * Time: 10:36 AM
// */
//public class IPC_AnimalDetailsFormSection extends SimpleGridPanel
//{
//    public IPC_AnimalDetailsFormSection()
//    {
//        this(EHRService.FORM_SECTION_LOCATION.Body);
//    }
//
//    public IPC_AnimalDetailsFormSection(EHRService.FORM_SECTION_LOCATION location)
//    {
//        super("study", "IPC_AnimalDetails", "Service Request Details", location);
//        addClientDependency(ClientDependency.fromPath("onprc_ehr/model/sources/IPC_AnimalDetails.js"));
//        addConfigSource("AnimalDetails");
//    }
//}

package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: Kolli
 * Date: 4/01/2020
 * Time: 10:36 AM
 */
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

