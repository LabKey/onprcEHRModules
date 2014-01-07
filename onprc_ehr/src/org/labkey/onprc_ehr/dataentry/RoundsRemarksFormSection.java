package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 4/27/13
 * Time: 10:54 AM
 */
public class RoundsRemarksFormSection extends SimpleFormSection
{
    public RoundsRemarksFormSection(String label, EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Clinical Remarks", label, "ehr-roundsremarksgridpanel", location);
        addClientDependency(ClientDependency.fromFilePath("ehr/panel/ClinicalRemarkPanel.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/grid/RoundsRemarksGridPanel.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/grid/ObservationsRowEditorGridPanel.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/plugin/ClinicalRemarksRowEditor.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/data/ClinicalObservationsClientStore.js"));

        setTemplateMode(TEMPLATE_MODE.NONE);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.remove("COPYFROMSECTION");

        return defaultButtons;
    }
}
