package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.RequestFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class BloodDrawRequestFormType extends RequestForm
{
    public BloodDrawRequestFormType(Module owner)
    {
        super(owner, "Blood Draw Request", "Blood Draw Requests", "Requests", Arrays.<FormSection>asList(
                new RequestFormSection(),
                new BloodDrawFormSection(false)
        ));
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = super.getButtonConfigs();
        defaultButtons.add("APPROVE");

        return defaultButtons;
    }
}
