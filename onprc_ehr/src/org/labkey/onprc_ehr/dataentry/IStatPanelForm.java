package org.labkey.onprc_ehr.dataentry;

import java.util.List;

/**

 */
public class IStatPanelForm extends ClinpathRunsFormSection
{
    public IStatPanelForm()
    {
        super(false);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "ISTAT_IMPORT");

        return defaultButtons;
    }
}
