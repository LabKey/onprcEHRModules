package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**

 */
public class MiscChargesFormSection extends SimpleGridPanel
{
    public MiscChargesFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("onprc_billing", "miscCharges", "Misc. Charges");
        setClientStoreClass("EHR.data.MiscChargesClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/MiscChargesClientStore.js"));
        setLocation(location);
    }
}
