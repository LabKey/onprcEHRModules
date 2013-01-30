/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.query.QueryService;
import org.labkey.api.resource.Resource;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLAuditViewFactory;
import org.labkey.onprc_ehr.notification.AdminAlertsNotification;
import org.labkey.onprc_ehr.notification.BloodAdminAlertsNotification;
import org.labkey.onprc_ehr.notification.BloodAlertsNotification;
import org.labkey.onprc_ehr.notification.ColonyAlertsLiteNotification;
import org.labkey.onprc_ehr.notification.ColonyAlertsNotification;
import org.labkey.onprc_ehr.notification.ColonyMgmtNotification;
import org.labkey.onprc_ehr.notification.LabResultSummaryNotification;
import org.labkey.onprc_ehr.notification.LabTestScheduleNotifications;
import org.labkey.onprc_ehr.notification.TreatmentAlerts;
import org.labkey.onprc_ehr.security.ONPRCBillingAdminRole;
import org.labkey.onprc_ehr.table.ONPRC_EHRCustomizer;

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
        return 12.311;
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
        ETL.init(1);
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
                        if (ONPRC_EHRSchema.BILLING_SCHEMA_NAME.equals(schemaName))
                        {
                            return new ONPRC_EHRBillingUserSchema(schema.getUser(), schema.getContainer());
                        }
                        else
                        {
                            return QueryService.get().createSimpleUserSchema(schemaName, null, schema.getUser(), schema.getContainer(), dbschema);
                        }
                    }
                    return null;
                }
            });
        }

        RoleManager.registerRole(new ONPRCBillingAdminRole());

        EHRService.get().registerModule(this);
        EHRService.get().registerTableCustomizer(this, ONPRC_EHRCustomizer.class);

        Resource r = getModuleResource("/scripts/onprc_ehr/onprc_triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(this, r);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/onprcReports.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/Utils.js"), this);

        NotificationService ns = NotificationService.get();
        //ns.registerNotification(new AbnormalLabResultsNotification());
        ns.registerNotification(new AdminAlertsNotification());
        ns.registerNotification(new BloodAdminAlertsNotification());
        ns.registerNotification(new BloodAlertsNotification());
        ns.registerNotification(new ColonyAlertsLiteNotification());
        ns.registerNotification(new ColonyAlertsNotification());
        ns.registerNotification(new ColonyMgmtNotification());
        ns.registerNotification(new LabTestScheduleNotifications());
        ns.registerNotification(new LabResultSummaryNotification());
        //ns.registerNotification(new TreatmentAlerts());
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
        return PageFlowUtil.set(ONPRC_EHRSchema.SCHEMA_NAME, ONPRC_EHRSchema.BILLING_SCHEMA_NAME);
    }

    @Override
    @NotNull
    public Set<DbSchema> getSchemasToTest()
    {
        return PageFlowUtil.set(ONPRC_EHRSchema.getInstance().getSchema(), DbSchema.get(ONPRC_EHRSchema.BILLING_SCHEMA_NAME));
    }

}
