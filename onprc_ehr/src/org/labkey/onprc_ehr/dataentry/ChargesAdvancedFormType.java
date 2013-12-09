package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.data.Container;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.security.User;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 11/12/13
 * Time: 5:25 PM
 */
public class ChargesAdvancedFormType extends TaskForm
{
    public static final String NAME = "ChargesAdvanced";

    public ChargesAdvancedFormType(Module owner)
    {
        super(owner, NAME, "Charges", "Billing", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new ChargesInstructionFormSection(),
                new ChargesFormSection()
        ));

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ChargesAdvanced.js"));
        for (FormSection s : getFormSections())
        {
            s.addConfigSource("ChargesAdvanced");
        }
    }

    @Override
    public boolean isVisible(Container c, User u)
    {
        return false;
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("SUBMIT");

        return defaultButtons;
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        return Collections.emptyList();
    }
}
