package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

/**

 */
public class MiscChargesByAccountFormSection extends MiscChargesFormSection
{
    public MiscChargesByAccountFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super(location);

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/BillingByAccount.js"));
        addConfigSource("BillingByAccount");
    }
}
