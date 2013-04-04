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
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbSchema;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.query.QueryService;
import org.labkey.api.resource.Resource;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLAuditViewFactory;
import org.labkey.onprc_ehr.notification.BloodAdminAlertsNotification;
import org.labkey.onprc_ehr.notification.BloodAlertsNotification;
import org.labkey.onprc_ehr.notification.ColonyAlertsLiteNotification;
import org.labkey.onprc_ehr.notification.ColonyAlertsNotification;
import org.labkey.onprc_ehr.notification.ColonyMgmtNotification;
import org.labkey.onprc_ehr.notification.ETLNotification;
import org.labkey.onprc_ehr.notification.LabResultSummaryNotification;
import org.labkey.onprc_ehr.notification.LabTestScheduleNotifications;
import org.labkey.onprc_ehr.notification.WeightAlertsNotification;
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
public class ONPRC_EHRModule extends ExtendedSimpleModule
{
    public static final String NAME = "ONPRC_EHR";
    public static final String CONTROLLER_NAME = "onprc_ehr";

    public String getName()
    {
        return NAME;
    }

    public double getVersion()
    {
        return 12.312;
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
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        ETL.init(1);
        AuditLogService.get().addAuditViewFactory(ETLAuditViewFactory.getInstance());

        RoleManager.registerRole(new ONPRCBillingAdminRole());

        registerEHRResources();

        NotificationService ns = NotificationService.get();
        //ns.registerNotification(new AbnormalLabResultsNotification());
        //ns.registerNotification(new BloodAdminAlertsNotification());
        ns.registerNotification(new BloodAlertsNotification());
        ns.registerNotification(new ColonyAlertsLiteNotification());
        ns.registerNotification(new ColonyAlertsNotification());
        ns.registerNotification(new ColonyMgmtNotification());
        ns.registerNotification(new LabTestScheduleNotifications());
        ns.registerNotification(new LabResultSummaryNotification());
        ns.registerNotification(new WeightAlertsNotification());
        //ns.registerNotification(new TreatmentAlerts());

        ns.registerNotification(new ETLNotification());
    }

    private void registerEHRResources()
    {
        EHRService.get().registerModule(this);
        EHRService.get().registerTableCustomizer(this, ONPRC_EHRCustomizer.class);

        Resource r = getModuleResource("/scripts/onprc_ehr/onprc_triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(this, r);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/onprcReports.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/Utils.js"), this);

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "List Single Housed Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsPaired&query.viewName=Single Housed"), null);
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "View Pairing Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=housingPairs&query.viewName=Cages With Animals"), null);
        //EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "View Roommate History for Animals", this, DetailsURL.fromString("/ehr/animalHistory.view#inputType:singleSubject&activeReport:roommateHistory"), null);
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "Find Animals Housed In A Given Room/Cage At A Specific Time", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), null);

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "All Living Center Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Alive%2C at Center"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "All Center Animals (including dead and shipped)", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Unassigned Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=No Active Assignments"), "Browse Animals");
        //EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Unweighed In Past 45 Days", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Unweighed%20Over%2045%20Days"), "Browse Animals");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Population Summary By Species, Gender and Age", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=colonyPopulationByAge"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Find Animals Housed At The Center Over A Date Range", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), "Other Searches");
    }

    @Override
    protected void registerSchemas()
    {
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
}
