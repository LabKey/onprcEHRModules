package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class WeightTreatmentsFormSection extends SimpleFormSection
{
    public WeightTreatmentsFormSection()
    {
        super("study", "Drug Administration", "Sedation/Medication", "ehr-gridpanel");
        setConfigSources(Arrays.asList("Task", "Weight"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromSectionWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SedationWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Weight.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "COPYSEDATIONFROMWEIGHTS");

        return defaultButtons;
    }
}
