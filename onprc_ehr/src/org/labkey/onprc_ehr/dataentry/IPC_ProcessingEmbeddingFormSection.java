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
public class IPC_ProcessingEmbeddingFormSection extends SimpleGridPanel
{
    public IPC_ProcessingEmbeddingFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public IPC_ProcessingEmbeddingFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "IPC_ProcessingEmbedding", "Tissue Processing / Embedding", location);
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/IPC_ProcessingEmbedding.js"));

        addConfigSource("ProcessingEmbedding");

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/IPC_Child.js"));
        addConfigSource("IPC_Child");

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