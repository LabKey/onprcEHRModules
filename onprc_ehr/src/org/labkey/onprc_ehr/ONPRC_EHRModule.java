/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.buttons.ChangeQCStateButton;
import org.labkey.api.ehr.buttons.CreateTaskFromIdsButton;
import org.labkey.api.ehr.buttons.CreateTaskFromRecordsButton;
import org.labkey.api.ehr.dataentry.DefaultDataEntryFormFactory;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.resource.Resource;
import org.labkey.api.settings.AdminConsole;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.buttons.DiscardTaskButton;
import org.labkey.onprc_ehr.dataentry.*;
import org.labkey.onprc_ehr.demographics.ActiveAnimalGroupsDemographicsProvider;
import org.labkey.onprc_ehr.demographics.ActiveCasesDemographicsProvider;
import org.labkey.onprc_ehr.demographics.ActiveFlagsDemographicsProvider;
import org.labkey.onprc_ehr.demographics.CagematesDemographicsProvider;
import org.labkey.onprc_ehr.demographics.HousingDemographicsProvider;
import org.labkey.onprc_ehr.demographics.ParentsDemographicsProvider;
import org.labkey.onprc_ehr.demographics.SourceDemographicsProvider;
import org.labkey.onprc_ehr.etl.ETL;
import org.labkey.onprc_ehr.etl.ETLAuditProvider;
import org.labkey.onprc_ehr.etl.ETLAuditViewFactory;
import org.labkey.onprc_ehr.notification.BehaviorNotification;
import org.labkey.onprc_ehr.notification.BloodAlertsNotification;
import org.labkey.onprc_ehr.notification.ClinicalAlertsNotification;
import org.labkey.onprc_ehr.notification.ColonyAlertsLiteNotification;
import org.labkey.onprc_ehr.notification.ColonyAlertsNotification;
import org.labkey.onprc_ehr.notification.ColonyMgmtNotification;
import org.labkey.onprc_ehr.notification.ComplianceNotification;
import org.labkey.onprc_ehr.notification.ETLNotification;
import org.labkey.onprc_ehr.notification.RoutineClinicalTestsNotification;
import org.labkey.onprc_ehr.notification.TMBNotification;
import org.labkey.onprc_ehr.notification.TreatmentAlertsNotification;
import org.labkey.onprc_ehr.notification.UnoccupiedRoomsNotification;
import org.labkey.onprc_ehr.notification.WeightAlertsNotification;
import org.labkey.onprc_ehr.table.ONPRC_EHRCustomizer;

import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;

/**
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
        return 12.352;
    }

    public boolean hasScripts()
    {
        return true;
    }

    protected void init()
    {
        addController(CONTROLLER_NAME, ONPRC_EHRController.class);
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        ETL.init(1);
        DetailsURL details = DetailsURL.fromString("/onprc_ehr/etlAdmin.view", ContainerManager.getSharedContainer());
        AdminConsole.addLink(AdminConsole.SettingsLinkType.Management, "ehr etl admin", details.getActionURL());

        AuditLogService.registerAuditType(new ETLAuditProvider());
        AuditLogService.get().addAuditViewFactory(ETLAuditViewFactory.getInstance());

        registerEHRResources();

        NotificationService ns = NotificationService.get();
        //ns.registerNotification(new AbnormalLabResultsNotification());
        ns.registerNotification(new TreatmentAlertsNotification());
        ns.registerNotification(new BloodAlertsNotification());
        ns.registerNotification(new ColonyAlertsLiteNotification());
        ns.registerNotification(new ColonyAlertsNotification());
        ns.registerNotification(new ColonyMgmtNotification());
        //ns.registerNotification(new LabResultSummaryNotification());
        ns.registerNotification(new WeightAlertsNotification());
        ns.registerNotification(new RoutineClinicalTestsNotification());
        ns.registerNotification(new ComplianceNotification());
        ns.registerNotification(new BehaviorNotification());
        ns.registerNotification(new TMBNotification());
        ns.registerNotification(new ClinicalAlertsNotification());
        ns.registerNotification(new UnoccupiedRoomsNotification());
        ns.registerNotification(new ETLNotification());
    }

    private void registerEHRResources()
    {
        EHRService.get().registerModule(this);
        EHRService.get().registerTableCustomizer(this, ONPRC_EHRCustomizer.class);

        Resource r = getModuleResource("/scripts/onprc_ehr/onprc_triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(this, r);

        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/panel/BloodSummaryPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/onprcReports.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/Utils.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/EHROverrides.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromFilePath("onprc_ehr/data/sources/ONPRCDefaults.js"), this);

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "List Single Housed Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsPaired&query.viewName=Single Housed"), "Commonly Used Queries");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "Find Animals Housed In A Given Room/Cage At A Specific Time", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), "Commonly Used Queries");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "All Living Center Animals, By Location", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=By Location&query.calculated_status~eq=Alive"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "All Center Animals (including dead and shipped)", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Unassigned Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Assignment Info&query.Id/activeAssignments/numResearchAssignments~eq=0&query.Id/activeAssignments/numProvisionalAssignments~eq=0"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Assigned Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Demographics&query.viewName=Assignment Info&query.Id/activeAssignments/numResearchAssignments~gt=0"), "Browse Animals");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Pregnancy/Repro Animal Search", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&queryName=Demographics&query.viewName=Repro Info"), "Browse Animals");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Population Summary By Species, Gender and Age", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=colonyPopulationByAge"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Find Animals Housed At The Center Over A Date Range", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), "Other Searches");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.protocol, "View All Active Protocols", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=Protocol&query.viewName=Active Protocols"), "Quick Links");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.protocol, "View All Protocols With Active Assignments", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=Protocol&query.viewName=Protocols With Active Assignments"), "Quick Links");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.project, "View Active Projects", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=Project&query.enddate~isblank"), "Quick Links");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Services Needed For Processing", this, DetailsURL.fromString("/onprc_ehr/groupProcessing.view"), "Colony Services");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Date of Last Physical Exam", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsPE&query.isRestricted~isblank"), "Routine Clinical Tasks");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Date of Last TB Test", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsMostRecentTBDate&query.calculated_status~eq=Alive"), "Routine Clinical Tasks");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "View Summary of Clinical Tasks", this, DetailsURL.fromString("/ldk/runNotification.view?key=org.labkey.onprc_ehr.notification.RoutineClinicalTestsNotification"), "Routine Clinical Tasks");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Pairing Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=pairingSummary"), "Behavior");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Pathogen Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=pathogenSummary"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Medical Cull List", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=medicalCullList"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Morbidity and Mortality By Breeding Group", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=animalGroupCategoryProblemSummary"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Morbidity and Mortality Raw Data", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=morbidityAndMortalityData"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Weight Loss Report", this, DetailsURL.fromString("/ldk/runNotification.view?key=org.labkey.onprc_ehr.notification.WeightAlertsNotification"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Clinical Alerts Report", this, DetailsURL.fromString("/ldk/runNotification.view?key=org.labkey.onprc_ehr.notification.ClinicalAlertsNotification"), "Clinical");

        try
        {
            EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Colony Census Excel Workbook", this, new URLHelper(AppProps.getInstance().getContextPath() + "/onprc_ehr/reports/Colony Census.xlsm"), "Colony Management");
        }
        catch (URISyntaxException e)
        {
            //ignore
        }

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Listing of Cages", this, DetailsURL.fromString("/query/executeQuery.view?executeQuery.view?schemaName=ehr_lookups&query.queryName=cage"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Cites Report", this, DetailsURL.fromString("/onprc_ehr/citesReport.view"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Consortium Statistics", this, DetailsURL.fromString("/onprc_ehr/consortiumReport.view"), "Colony Management");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Room Utilization By Investigator", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr_lookups&query.queryName=roomsByInvestigator"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Room Utilization By Project", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr_lookups&query.queryName=roomsByProject"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Birth Rate Summary, By Species", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=birthRateBySpecies"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Birth Rate Summary, By Group", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=animalGroupBirthRateSummary"), "Colony Management");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Animals Not On Termnal Projects", this, DetailsURL.fromString("/ehr/populationSummary.view?query.Id/demographics/calculated_status~eq=Alive&query.Id/terminal/status~eq=N"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Serology Testing Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=serologyTestSchedule&query.Id/demographics/calculated_status~eq=Alive"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Flag Usage Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=flagUsageSummary"), "Colony Management");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Matings 30-36 Days Ago", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=Matings&query.viewName=30-36 Days Ago"), "Reproductive Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Offspring Over 250 Days, Still In Cage With Dam", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=offspringWithMother&query.viewName=Offspring Over 250 Days"), "Reproductive Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Pregnant Animals", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=pregnantAnimals"), "Reproductive Management");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "View Tissue Distribution Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=tissueDistributionSummary"), "Pathology");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "SNOMED Search", this, DetailsURL.fromString("/onprc_ehr/snomedSearch.view"), "Pathology");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "View Tissue Distribution Summary, By Recipient", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=tissueDistributionSummaryByRecipient"), "Pathology");

        EHRService.get().registerActionOverride("projectDetails", this, "views/projectDetails.html");
        EHRService.get().registerActionOverride("protocolDetails", this, "views/protocolDetails.html");
        EHRService.get().registerActionOverride("procedureDetails", this, "views/procedureDetails.html");
        EHRService.get().registerActionOverride("animalGroupDetails", this, "views/animalGroupDetails.html");
        EHRService.get().registerActionOverride("cageDetails", this, "views/cageDetails.html");
        EHRService.get().registerActionOverride("animalSearch", this, "views/animalSearch.html");
        EHRService.get().registerActionOverride("animalHistory", this, "views/animalHistory.html");

        //data entry
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(WeightFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ClinicalRoundsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SurgicalRoundsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BehaviorRoundsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(TreatmentsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory.TaskFactory(this, "Clinical", "tb", "TB Tests", Collections.<FormSection>singletonList(new SimpleGridPanel("study", "tb", "TB Tests"))));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PairingFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ProcessingFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SurgeryFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SingleSurgeryFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(NecropsyFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BiopsyFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PathologyTissuesFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ClinicalReportFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ClinicalRemarkFormType.class, this));

        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BloodDrawFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AuxProcedureFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BloodDrawRequestFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkRequestFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory.RequestFactory(this, "Requests", "Surgery Request", "Procedure Requests", Collections.<FormSection>singletonList(new SurgeryRequestFormSection())));

        //demographics
        EHRService.get().registerDemographicsProvider(new ActiveCasesDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CagematesDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new HousingDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ParentsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new SourceDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveFlagsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new TBDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveAnimalGroupsDemographicsProvider());

        //buttons
        EHRService.get().registerMoreActionsButton(new DiscardTaskButton(this), "ehr", "my_tasks");
        EHRService.get().registerMoreActionsButton(new DiscardTaskButton(this), "ehr", "tasks");

        EHRService.get().registerMoreActionsButton(new CreateTaskFromIdsButton(this, "Schedule Blood Draw For Selected", "Blood Draws", BloodDrawFormType.NAME, new String[]{"Blood Draws"}), "study", "demographics");
        EHRService.get().registerMoreActionsButton(new CreateTaskFromIdsButton(this, "Schedule Weight For Selected", "Weight", "weight", new String[]{"Weight"}), "study", "demographics");
        EHRService.get().registerMoreActionsButton(new CreateTaskFromIdsButton(this, "Schedule Weight For Selected", "Weight", "weight", new String[]{"Weight"}), "study", "weight");

        EHRService.get().registerMoreActionsButton(new CreateTaskFromRecordsButton(this, "Create Task From Selected", "Blood Draws", BloodDrawFormType.NAME), "study", "blood");
        EHRService.get().registerMoreActionsButton(new CreateTaskFromRecordsButton(this, "Create Task From Selected", "Labwork", LabworkFormType.NAME), "study", "clinpathRuns");
        EHRService.get().registerMoreActionsButton(new CreateTaskFromRecordsButton(this, "Create Task From Selected", "Surgeries", SurgeryFormType.NAME), "study", "surgery");

        EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this, "ONPRC_EHR.window.ChangeBloodStatusWindow", Collections.singleton(ClientDependency.fromFilePath("onprc_ehr/window/ChangeBloodStatusWindow.js"))), "study", "blood");
        EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this, "ONPRC_EHR.window.ChangeLabworkStatusWindow", Collections.singleton(ClientDependency.fromFilePath("onprc_ehr/window/ChangeLabworkStatusWindow.js"))), "study", "clinpathRuns");
        //EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this, "ONPRC_EHR.window.ChangeEncounterStatusWindow", Collections.singleton(ClientDependency.fromFilePath("onprc_ehr/window/ChangeEncounterStatusWindow.js"))), "study", "encounters");
        EHRService.get().registerTbarButton(new ChangeQCStateButton(this, "Mark Delivered", "ONPRC_EHR.window.MarkLabworkDeliveredWindow", Collections.singleton(ClientDependency.fromFilePath("onprc_ehr/window/MarkLabworkDeliveredWindow.js"))), "study", "clinpathRuns");
    }

    @Override
    public void destroy()
    {
        ETL.stop();
        super.destroy();
    }

    @Override
    @NotNull
    public Collection<String> getSchemaNames()
    {
        return Arrays.asList(ONPRC_EHRSchema.SCHEMA_NAME);
    }
}

