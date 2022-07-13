package org.labkey.onprc_ehr.dataentry;

import java.util.List;

public class EpocPanelForm extends ClinpathRunsFormSection
{
    public EpocPanelForm()
    {
        super(false);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "EPOC_IMPORT");

        return defaultButtons;
    }
}
