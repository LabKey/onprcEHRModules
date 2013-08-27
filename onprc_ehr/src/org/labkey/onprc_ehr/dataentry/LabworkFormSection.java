package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;

import java.util.ArrayList;
import java.util.List;

/**
 * User: bimber
 * Date: 7/30/13
 * Time: 2:05 PM
 */
public class LabworkFormSection extends SimpleGridPanel
{
    public LabworkFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label, EHRService.FORM_SECTION_LOCATION.Tabs);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("COPYFROMCLINPATHRUNS");
        defaultButtons.addAll(super.getTbarButtons());

        return defaultButtons;
    }
}
