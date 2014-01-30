package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;

/**
 * User: bimber
 * Date: 1/13/14
 * Time: 8:38 PM
 */
public class ClinicalEncountersFormPanelSection extends SimpleFormPanelSection
{
    public ClinicalEncountersFormPanelSection(String label)
    {
        super("study", "encounters", label);
        setTemplateMode(TEMPLATE_MODE.NONE);
    }
}
