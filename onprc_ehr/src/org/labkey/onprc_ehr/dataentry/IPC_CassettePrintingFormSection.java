package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleGridPanel;
import org.labkey.api.view.template.ClientDependency;
import java.util.List;


/**
 * User: Kollil
 * Date: 4/01/2020
 * Time: 10:36 AM
 */
public class IPC_CassettePrintingFormSection extends SimpleGridPanel
{
    public IPC_CassettePrintingFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public IPC_CassettePrintingFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "IPC_CassettePrinting", "Cassette Printing", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/IPC_CassettePrinting.js"));

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/IPC_Child.js"));
        addConfigSource("IPC_Child");

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/IPC_CopyFromSectionWindow.js"));

        addConfigSource("CassettePrinting");
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

