package org.labkey.onprc_ehr.dataentry;

import org.labkey.onprc_ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.view.template.ClientDependency;


//CreatedL 4-22-2024  r. Blasa noverride ehr version of the same.
public class ExtendedAnimalDetailsFormSection extends NonStoreFormSection
{
    public ExtendedAnimalDetailsFormSection()
    {
//        super();
//
//        setXtype("onprc_ehr-animaldetailsextendedpanel");


            super("AnimalDetails", "Animal Details", "onprc_ehr-animaldetailsextendedpanel");

            addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/panel/AnimalDetailsCasePanel.js"));
            addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/panel/AnimalDetailsExtendedPanel.js"));





        }

}
