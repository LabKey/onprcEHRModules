package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 11/20/13
 * Time: 7:52 PM
 */
public class TissueDistFormSection extends SimpleGridPanel
{
    public TissueDistFormSection()
    {
        super("study", "tissueDistributions", "Tissue Distributions");
        setLocation(EHRService.FORM_SECTION_LOCATION.Tabs);
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/window/CopyTissuesWindow.js"));
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.add("COPY_TISSUES");

        return defaultButtons;
    }
}
