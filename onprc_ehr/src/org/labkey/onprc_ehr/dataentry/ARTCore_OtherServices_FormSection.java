package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: Kolli
 * Date: 1/13/2021
 * Time: 10:36 AM
 * ART Core Billing other service data entry form
 */
public class ARTCore_OtherServices_FormSection extends SimpleGridPanel
{
    public ARTCore_OtherServices_FormSection()
    {
        super("ARTCore_OtherServices", "Instructions", "onprc-ARTCoreOtherServices");

//        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/panel/ARTCore_OtherServices.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/ARTCore_OtherServices.js"));
    }


}