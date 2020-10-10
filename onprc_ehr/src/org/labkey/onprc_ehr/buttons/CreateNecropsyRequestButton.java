package org.labkey.onprc_ehr.buttons;

import org.labkey.api.ehr.buttons.CreateTaskFromRecordsButton;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.dataentry.NecropsyFormType;

public class CreateNecropsyRequestButton extends CreateTaskFromRecordsButton
{
    public CreateNecropsyRequestButton(Module owner)
    {
        super(owner, "Create Necropsy Request From Selected", "ONPRC_EHR.window.CreateNecropsyRequestWindow.createTaskFromRecordHandler(dataRegionName, '" + NecropsyFormType.NAME + "')");
        setClientDependencies(ClientDependency.supplierFromPath("onprc_ehr/window/CreateNecropsyRequestWindow.js"));
    }
}
