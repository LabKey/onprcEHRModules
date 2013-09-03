package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.RequestFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class LabworkRequestFormType extends RequestForm
{
    public LabworkRequestFormType(Module owner)
    {
        super(owner, LabworkFormType.NAME + " Request", LabworkFormType.NAME + " Requests", "Requests", Arrays.<FormSection>asList(
                new RequestFormSection(),
                new ClinpathRunsFormSection(true)
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
