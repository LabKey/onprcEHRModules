package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class TissueDistributionFormType extends TaskForm
{
    public static final String NAME = "Tissue Distributions";

    public TissueDistributionFormType(Module owner)
    {
        super(owner, NAME, "Tissue Distributions", "Pathology", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new SimpleGridPanel("study", "tissueDistributions", "Tissue Distributions"))
        );
    }
}
