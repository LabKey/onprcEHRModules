package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class AnesthesiaFormSection extends SimpleGridPanel
{
    public AnesthesiaFormSection()
    {
        super("study", "anesthesia", "Anesthesia");

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/window/AnesthesiaRowWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add(0, "ADD_ANESTHESIA");

        return defaultButtons;
    }
}
