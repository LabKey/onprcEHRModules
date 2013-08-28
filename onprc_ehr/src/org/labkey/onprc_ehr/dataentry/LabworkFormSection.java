package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

/**
 * User: bimber
 * Date: 7/30/13
 * Time: 2:05 PM
 */
public class LabworkFormSection extends SimpleGridPanel
{
    public LabworkFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label, EHRService.FORM_SECTION_LOCATION.Tabs);
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/labworkButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/LabworkChild.js"));
        addConfigSource("LabworkChild");
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("COPYFROMCLINPATHRUNS");
        defaultButtons.addAll(super.getTbarButtons());
        defaultButtons.remove("ADDANIMALS");
        defaultButtons.remove("TEMPLATE");
        if (defaultButtons.contains("ADDRECORD"))
        {
            int idx = defaultButtons.indexOf("ADDRECORD");
            defaultButtons.remove("ADDRECORD");
            defaultButtons.add(idx, "LABWORKADD");
        }

        return defaultButtons;
    }
}
