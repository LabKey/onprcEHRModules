/*
 * Copyright (c) 2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.security.EHRRequestAdminPermission;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.Module;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.template.ClientDependency;

/**

 */
public class BulkEditRequestsButton extends SimpleButtonConfigFactory
{
    private String _formType;

    public BulkEditRequestsButton(Module owner, String formType)
    {
        super(owner, "Bulk Edit Requests", "ONPRC_EHR.Buttons.bulkEditRequestHandler();");

        setClientDependencies(PageFlowUtil.set(ClientDependency.fromPath("onprc_ehr/buttons/bulkEditRequestButtons.js")));
        _formType = formType;
    }

    @Override
    protected String getJsHandler(TableInfo ti)
    {
        boolean hasPermission = EHRService.get().hasPermission(ti, EHRRequestAdminPermission.class);

        return "ONPRC_EHR.Buttons.bulkEditRequestHandler(dataRegionName, " + PageFlowUtil.jsString(_formType) + ", " + hasPermission + ");";
    }
}
