package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class CageObservationFormType extends TaskForm
{
    public CageObservationFormType(Module owner)
    {
        super(owner, "Cage Observation", "Cage Observation", "BSU", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new SimpleGridPanel("ehr", "cage_observations", "Cages"),
            new SimpleGridPanel("study", "Clinical Observations", "Observations")
        ));
    }
}
