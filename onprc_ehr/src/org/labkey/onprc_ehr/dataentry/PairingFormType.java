package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 9/5/13
 * Time: 12:43 PM
 */
public class PairingFormType extends TaskForm
{
    public static final String NAME = "Pairing Observations";

    public PairingFormType(Module owner)
    {
        super(owner, NAME, "Pairing Observations", "BSU", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleGridPanel("study", "pairings", "Pairing Observations")
        ));
    }
}
