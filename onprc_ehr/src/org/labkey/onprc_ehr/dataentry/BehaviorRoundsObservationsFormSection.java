package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class BehaviorRoundsObservationsFormSection extends ClinicalObservationsFormSection
{
    public BehaviorRoundsObservationsFormSection()
    {
        super(EHRService.FORM_SECTION_LOCATION.Tabs);

        _showLocation = true;

        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddClinicalCasesWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddSurgicalCasesWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddBehaviorCasesWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "ADDBEHAVIORCASES");

        return defaultButtons;
    }
}
