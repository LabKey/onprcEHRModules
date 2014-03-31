package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class HousingFormSection extends SimpleGridPanel
{
    public HousingFormSection(String schema, String query, String label)
    {
        super(schema, query, label);

        addClientDependency(ClientDependency.fromFilePath("ehr/window/RoomTransferWindow.js"));
        setClientStoreClass("EHR.data.HousingClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/HousingClientStore.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/buttons/housingButtons.js"));
        setTemplateMode(TEMPLATE_MODE.NONE);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> ret = super.getTbarButtons();
        ret.remove("COPYFROMSECTION");

        ret.add("ROOM_TRANSFER");
        ret.add("ROOM_LAYOUT");

        return ret;
    }

}
