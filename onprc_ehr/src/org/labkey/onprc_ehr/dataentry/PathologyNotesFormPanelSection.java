package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 1/17/14
 * Time: 3:48 PM
 */
public class PathologyNotesFormPanelSection extends SimpleFormPanelSection
{
    public PathologyNotesFormPanelSection()
    {
        super("ehr", "encounter_summaries", "Notes", false);

        addClientDependency(ClientDependency.fromFilePath("ehr/buttons/encounterButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/EncounterChild.js"));
        setLocation(EHRService.FORM_SECTION_LOCATION.Tabs);

        addConfigSource("Encounter");
        addConfigSource("EncounterChild");
    }
}
