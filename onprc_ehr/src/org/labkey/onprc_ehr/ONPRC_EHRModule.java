/*
 * Copyright (c) 2012 LabKey Corporation
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
package org.labkey.onprc_ehr;

import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLAuditViewFactory;
import org.labkey.api.audit.AuditLogService;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.view.WebPartFactory;

import java.util.Collection;
import java.util.Collections;

/**
 * Created by IntelliJ IDEA.
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:52 PM
 */
public class ONPRC_EHRModule extends DefaultModule
{
    public static final String NAME = "ONPRC_EHR";
    public static final String CONTROLLER_NAME = "onprc_ehr";

    public String getName()
    {
        return NAME;
    }

    public double getVersion()
    {
        return 0.00;
    }

    public boolean hasScripts()
    {
        return true;
    }

    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return Collections.emptyList();
    }

    protected void init()
    {
        addController(CONTROLLER_NAME, ONPRC_EHRController.class);
    }

    @Override
    public void startup(ModuleContext moduleContext)
    {
        ETL.start();
        AuditLogService.get().addAuditViewFactory(ETLAuditViewFactory.getInstance());
    }

    @Override
    public void destroy()
    {
        ETL.stop();
        super.destroy();
    }
}
