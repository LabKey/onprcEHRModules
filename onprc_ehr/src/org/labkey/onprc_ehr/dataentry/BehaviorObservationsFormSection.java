package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class BehaviorObservationsFormSection extends ClinicalObservationsFormSection
{
    public BehaviorObservationsFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super(location);

        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyBehaviorExamWindow.js"));
    }
}
