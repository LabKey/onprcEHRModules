package org.labkey.onprc_ehr.dataentry;

import java.util.List;

/**
 * User: bimber
 * Date: 11/20/13
 * Time: 7:52 PM
 */
public class NecropsyFormSection extends EncounterChildFormSection
{
    public NecropsyFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label, false);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        //defaultButtons.add("TEMPLATE");

        return defaultButtons;
    }
}
