package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class ProcessingFormType extends TaskForm
{
    public static final String NAME = "Processing";

    public ProcessingFormType(Module owner)
    {
        super(owner, NAME, "Processing", "Processing", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new BloodDrawFormSection(false),
                new TreatmentsTaskFormSection(false),
                new WeightFormSection()
        ));

        ClientDependency cd = ClientDependency.fromFilePath("onprc_ehr/data/sources/Processing.js");
        for (FormSection s: this.getFormSections())
        {
            s.addConfigSource("Processing");
            s.addClientDependency(cd);
        }


    }
}
