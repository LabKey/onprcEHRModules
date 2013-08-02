package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class ChargesFormSection extends SimpleFormSection
{
    public ChargesFormSection()
    {
        super("onprc_billing", "miscCharges", "Misc. Charges", "ehr-gridpanel");
        setConfigSources(Collections.singletonList("Task"));
    }
}
