package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 1/17/14
 * Time: 3:48 PM
 */
public class GrossFindingsFormPanelSection extends SimpleFormPanelSection
{
    public GrossFindingsFormPanelSection()
    {
        super("ehr", "encounter_summaries", "Gross Findings");
        setTemplateMode(TEMPLATE_MODE.NONE);

        addClientDependency(ClientDependency.fromFilePath("ehr/buttons/encounterButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/EncounterChild.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/EncounterAddRecordWindow.js"));

        addConfigSource("Encounter");
        addConfigSource("EncounterChild");
    }
}
