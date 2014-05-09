package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.ehr.security.EHRRequestAdminPermission;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.Module;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.LinkedHashSet;

/**

 */
public class BulkEditRequestsButton extends SimpleButtonConfigFactory
{
    private String _formType;

    public BulkEditRequestsButton(Module owner, String formType)
    {
        super(owner, "Bulk Edit Requests", "ONPRC_EHR.Buttons.bulkEditRequestHandler();");

        setClientDependencies(PageFlowUtil.set(ClientDependency.fromFilePath("onprc_ehr/buttons/bulkEditRequestButtons.js")));
        _formType = formType;
    }

    @Override
    protected String getJsHandler(TableInfo ti)
    {
        boolean hasPermission = EHRService.get().hasPermission(ti, EHRRequestAdminPermission.class);

        return "ONPRC_EHR.Buttons.bulkEditRequestHandler(dataRegionName, " + PageFlowUtil.jsString(_formType) + ", " + hasPermission + ");";
    }
}
