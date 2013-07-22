package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class TreatmentsTaskFormSection extends SimpleFormSection
{
    public TreatmentsTaskFormSection()
    {
        super("study", "Drug Administration", "Medications/Diet", "ehr-gridpanel");
        setConfigSources(Collections.singletonList("Task"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddScheduledTreatmentsWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("ADDTREATMENTS");
        defaultButtons.add("ADDRECORD");
        defaultButtons.add("DELETERECORD");
        defaultButtons.add("ADDANIMALS");
        return defaultButtons;
    }
}
