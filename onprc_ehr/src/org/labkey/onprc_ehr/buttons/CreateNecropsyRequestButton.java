package org.labkey.onprc_ehr.buttons;

import org.labkey.api.ehr.buttons.CreateTaskFromRecordsButton;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.dataentry.PathologyTissuesFormType;

public class CreateNecropsyRequestButton extends CreateTaskFromRecordsButton
{
    public CreateNecropsyRequestButton(Module owner)
    {
        super(owner, "Create Pathology TASK From Selected", "ONPRC_EHR.window.CreateNecropsyRequestWindow.createTaskFromRecordHandler(dataRegionName, '" + PathologyTissuesFormType.NAME + "')");
        setClientDependencies(ClientDependency.supplierFromPath("onprc_ehr/window/CreateNecropsyRequestWindow.js"));
    }
}
