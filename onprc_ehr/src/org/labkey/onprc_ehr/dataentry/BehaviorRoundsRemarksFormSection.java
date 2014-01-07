package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class BehaviorRoundsRemarksFormSection extends RoundsRemarksFormSection
{
    public BehaviorRoundsRemarksFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public BehaviorRoundsRemarksFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("Remarks", location);
        setConfigSources(Collections.singletonList("Task"));

        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddClinicalCasesWindow.js"));
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
