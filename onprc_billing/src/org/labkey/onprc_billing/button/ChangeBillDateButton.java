/*
 * Copyright (c) 2014-2026 LabKey Corporation
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
package org.labkey.onprc_billing.button;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_billing.ONPRC_BillingModule;
import org.labkey.onprc_billing.security.ONPRCBillingAdminPermission;

/**

 */
public class ChangeBillDateButton extends SimpleButtonConfigFactory
{
    public ChangeBillDateButton(Module owner)
    {
        super(owner, "Change Billing Date", "ONPRC_Billing.window.ChangeBillDateWindow.buttonHandler(dataRegionName);");

        setClientDependencies(ClientDependency.supplierFromPath("onprc_billing/window/ChangeBillDateWindow.js"), ClientDependency.supplierFromModuleName(ONPRC_BillingModule.NAME));
    }

    @Override
    public boolean isAvailable(TableInfo ti)
    {
        if (!super.isAvailable(ti))
            return false;

        return ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), ONPRCBillingAdminPermission.class);
    }
}
