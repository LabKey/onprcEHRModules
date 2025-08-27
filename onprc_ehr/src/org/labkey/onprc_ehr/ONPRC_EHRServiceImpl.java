package org.labkey.onprc_ehr;

import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.onprc_ehr.ONPRC_EHRService;
import org.labkey.onprc_ehr.dataentry.AnimalDetailsFormSection;


public class ONPRC_EHRServiceImpl implements ONPRC_EHRService
{
    @Override
    public FormSection getAnimalDetailsFormSection()
    {
        return new AnimalDetailsFormSection();
    }
}
