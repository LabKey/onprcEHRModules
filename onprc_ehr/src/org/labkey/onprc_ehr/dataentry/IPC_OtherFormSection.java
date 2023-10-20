package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.view.template.ClientDependency;
import java.util.List;

/**
 * User: Kolli
 * Date: 4/01/2020
 * Time: 10:36 AM
 */
public class IPC_OtherFormSection extends SimpleGridPanel
{
    public IPC_OtherFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public IPC_OtherFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "IPC_Other", "Other", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/IPC_Other.js"));
        addConfigSource("IPC_Other");

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/IPC_CopyFromSectionWindow.js"));
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();

        if (defaultButtons.contains("COPYFROMSECTION"))
        {
            int idx = defaultButtons.indexOf("COPYFROMSECTION");
            defaultButtons.remove("COPYFROMSECTION");
            defaultButtons.add(idx, "IPC_COPYFROMSECTION");
        }

        return defaultButtons;
    }

}