package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class SurgicalRoundsRemarksFormSection extends ClinicalRemarksFormSection
{
    public SurgicalRoundsRemarksFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public SurgicalRoundsRemarksFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("Remarks", location);
        setConfigSources(Collections.singletonList("Task"));

        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddClinicalCasesWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddSurgicalCasesWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "ADDSURGICALCASES");

        return defaultButtons;
    }
}
