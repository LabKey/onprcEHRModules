package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;

/**
 * User: bimber
 * Date: 4/27/13
 * Time: 10:54 AM
 */
public class SimpleGridPanel extends SimpleFormSection
{
    public SimpleGridPanel(String schemaName, String queryName, String label)
    {
        this(schemaName, queryName, label, EHRService.FORM_SECTION_LOCATION.Body);
    }

    public SimpleGridPanel(String schemaName, String queryName, String label, EHRService.FORM_SECTION_LOCATION location)
    {
        super(schemaName, queryName, label, "ehr-gridpanel", location);
    }
}
