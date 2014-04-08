package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

/**

 */
public class AnimalGroupCompletedButton extends MarkCompletedButton
{
    public AnimalGroupCompletedButton(Module owner)
    {
        super(owner, "ehr", "animal_group_members", "End Group Assignments");

        setClientDependencies(ClientDependency.fromFilePath("onprc_ehr/window/MarkAnimalGroupCompletedWindow.js"));
    }

    @Override
    protected String getJsHandler(TableInfo ti)
    {
        return "ONPRC_EHR.window.MarkAnimalGroupCompletedWindow.buttonHandler(dataRegionName);";
    }
}
