package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.module.Module;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.template.ClientDependency;

/**

 */
public class AssignmentCompletedButton extends MarkCompletedButton
{
    public AssignmentCompletedButton(Module owner)
    {
        super(owner, "study", "assignment", "End Assignments");

        setClientDependencies(ClientDependency.fromFilePath("onprc_ehr/window/MarkAssignmentCompletedWindow.js"));
    }

    @Override
    protected String getJsHandler(TableInfo ti)
    {
        return "ONPRC_EHR.window.MarkAssignmentCompletedWindow.buttonHandler(dataRegionName);";
    }
}
