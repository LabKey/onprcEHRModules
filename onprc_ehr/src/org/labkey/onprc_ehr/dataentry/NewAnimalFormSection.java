package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class NewAnimalFormSection extends SimpleGridPanel
{
    public NewAnimalFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label);

        addClientDependency(ClientDependency.fromFilePath("ehr/window/AnimalIdSeriesWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/AnimalIdGeneratorField.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaults = super.getTbarButtons();

        int idx = defaults.indexOf("SELECTALL");
        assert idx > -1;
        defaults.add("ANIMAL_ID_SERIES");

        return defaults;
    }
}
