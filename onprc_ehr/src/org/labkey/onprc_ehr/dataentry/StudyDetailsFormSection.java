package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: Kolli
 * Date: 02/20/2020
 */
public class StudyDetailsFormSection extends SimpleGridPanel
{
    public StudyDetailsFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public StudyDetailsFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "StudyDetails", "Study Details", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/StudyDetailsProperties.js"));
        addConfigSource("StudyDetails");
        _showLocation = true;
    }
}