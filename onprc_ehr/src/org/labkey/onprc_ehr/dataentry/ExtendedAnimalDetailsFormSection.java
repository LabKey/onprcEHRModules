package org.labkey.onprc_ehr.dataentry;

import org.labkey.onprc_ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.view.template.ClientDependency;


//CreatedL 4-18-2024  r. Blasa noverride ehr version of the same.
public class ExtendedAnimalDetailsFormSection extends AnimalDetailsFormSection
{
    public ExtendedAnimalDetailsFormSection()
    {
        super();

        setXtype("onprc_ehr-animaldetailsextendedpanel");
    }
}
