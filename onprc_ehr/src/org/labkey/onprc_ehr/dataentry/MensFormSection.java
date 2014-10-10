package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by bimber on 10/8/2014.
 */
public class MensFormSection extends ClinicalObservationsFormSection
{
    public MensFormSection()
    {
        super();

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/window/AddFemaleAnimalsWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<>(super.getTbarButtons());

        int idx = defaultButtons.indexOf("ADDANIMALS");
        if (idx > -1)
        {
            defaultButtons.remove(idx);
            defaultButtons.add(idx, "ADD_FEMALE_ANIMALS");
        }

        return defaultButtons;
    }

}
