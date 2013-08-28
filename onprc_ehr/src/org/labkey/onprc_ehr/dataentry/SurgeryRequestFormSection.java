package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class SurgeryRequestFormSection extends SimpleGridPanel
{
    public SurgeryRequestFormSection()
    {
        super("study", "Clinical Encounters", "Surgery Request");
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Surgery Request.js"));
        addConfigSource("Surgery Request");
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.add("GUESSPROJECT");

        return defaultButtons;
    }
}
