package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

/**
 * User: bimber
 * Date: 7/30/13
 * Time: 2:05 PM
 */
public class EncounterChildFormSection extends SimpleGridPanel
{
    private boolean _allowAddDefaults;

    public EncounterChildFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults)
    {
        super(schemaName, queryName, label, EHRService.FORM_SECTION_LOCATION.Tabs);
        _allowAddDefaults = allowAddDefaults;

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/encounterButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/EncounterChild.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Surgery.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SurgeryAddRecordWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromEncountersWindow.js"));

        addConfigSource("Encounter");
        addConfigSource("EncounterChild");
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<String>();

        if (_allowAddDefaults)
            defaultButtons.add("COPYFROMENCOUNTERS");

        defaultButtons.addAll(super.getTbarButtons());
        defaultButtons.remove("ADDANIMALS");
        defaultButtons.remove("TEMPLATE");
        if (defaultButtons.contains("ADDRECORD"))
        {
            int idx = defaultButtons.indexOf("ADDRECORD");
            defaultButtons.remove("ADDRECORD");
            defaultButtons.add(idx, "SURGERYADD");
        }

        return defaultButtons;
    }
}
