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
public class BloodTreatmentsFormSection extends SimpleFormSection
{
    public BloodTreatmentsFormSection()
    {
        super("study", "Drug Administration", "Medications/Diet", "ehr-gridpanel");
        setConfigSources(Collections.singletonList("Task"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SedationWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "COPYSEDATIONFROMBLOOD");

        return defaultButtons;
    }
}
