package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class AssignmentFormSection extends SimpleGridPanel
{
    public AssignmentFormSection()
    {
        super("study", "assignment", "Assignments");

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/window/AssignmentDefaultsWindow.js"));

        setClientStoreClass("EHR.data.AssignmentClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/AssignmentClientStore.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();

        int idx = defaultButtons.indexOf("DELETERECORD");
        assert idx > -1;
        defaultButtons.add(idx+1, "SET_ASSIGNMENT_DEFAULTS");

        return defaultButtons;
    }
}
