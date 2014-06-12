package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

/**

 */
public class AssignmentReleaseConditionButton extends MarkCompletedButton
{
    public AssignmentReleaseConditionButton(Module owner)
    {
        super(owner, "study", "assignment", "Set Release Condition");

        setClientDependencies(ClientDependency.fromFilePath("onprc_ehr/window/AssignmentReleaseConditionWindow.js"));
    }

    @Override
    protected String getJsHandler(TableInfo ti)
    {
        return "ONPRC_EHR.window.AssignmentReleaseConditionWindow.buttonHandler(dataRegionName);";
    }
}
