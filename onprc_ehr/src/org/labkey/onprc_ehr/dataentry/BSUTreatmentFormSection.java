package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;

import java.util.List;

/**

 */
public class BSUTreatmentFormSection extends DrugAdministrationFormSection
{
    public BSUTreatmentFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super(location);
        setLabel("Treatments Given");
        setTabName(getLabel());
        _showAddTreatments = false;
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.remove("SEDATIONHELPER");
        defaultButtons.remove("DRUGAMOUNTHELPER");

        return defaultButtons;
    }
}
