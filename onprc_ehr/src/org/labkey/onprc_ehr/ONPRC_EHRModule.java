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

import org.jetbrains.annotations.NotNull;
import org.labkey.api.audit.AuditLogService;
import org.labkey.api.data.DbSchema;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.query.QueryService;
import org.labkey.api.resource.Resource;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.WebPartFactory;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLAuditViewFactory;

import java.util.Collection;
import java.util.Collections;
import java.util.Set;

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
        return 12.21;
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
    public void doStartup(ModuleContext moduleContext)
    {
        ETL.init(5000);
        AuditLogService.get().addAuditViewFactory(ETLAuditViewFactory.getInstance());

        for (final String schemaName : getSchemaNames())
        {
            final DbSchema dbschema = DbSchema.get(schemaName);

            DefaultSchema.registerProvider(schemaName, new DefaultSchema.SchemaProvider()
            {
                public QuerySchema getSchema(final DefaultSchema schema)
                {
                    if (schema.getContainer().getActiveModules().contains(ONPRC_EHRModule.this))
                    {
                        return QueryService.get().createSimpleUserSchema(schemaName, null, schema.getUser(), schema.getContainer(), dbschema);
                    }
                    return null;
                }
            });
        }

        EHRService.get().registerModule(this);

        Resource r = getModuleResource("/scripts/onprc_ehr/triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(r);
    }

    @Override
    public void destroy()
    {
        ETL.stop();
        super.destroy();
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        return PageFlowUtil.set(ONPRC_EHRSchema.SCHEMA_NAME);
    }

    @Override
    @NotNull
    public Set<DbSchema> getSchemasToTest()
    {
        return PageFlowUtil.set(ONPRC_EHRSchema.getInstance().getSchema());
    }

}
