/*
 * Copyright (c) 2012-2017 LabKey Corporation
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
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.buttons.ChangeQCStateButton;
import org.labkey.api.ehr.buttons.CreateTaskFromIdsButton;
import org.labkey.api.ehr.buttons.CreateTaskFromRecordsButton;
import org.labkey.api.ehr.buttons.EHRShowEditUIButton;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.ehr.buttons.ReassignRequestButton;
import org.labkey.api.ehr.dataentry.DefaultDataEntryFormFactory;
import org.labkey.api.ehr.dataentry.SingleQueryFormProvider;
import org.labkey.api.ehr.demographics.ActiveFlagsDemographicsProvider;
import org.labkey.api.ehr.security.EHRDataAdminPermission;
import org.labkey.api.ehr.security.EHRProjectEditPermission;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.buttons.ShowEditUIButton;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.AdminLinkManager;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.resource.Resource;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.URLHelper;
import org.labkey.api.util.UnexpectedException;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.buttons.AnimalGroupCompletedButton;
import org.labkey.onprc_ehr.buttons.AssignmentCompletedButton;
import org.labkey.onprc_ehr.buttons.AssignmentReleaseConditionButton;
import org.labkey.onprc_ehr.buttons.BulkEditRequestsButton;
import org.labkey.onprc_ehr.buttons.ChangeProjectedReleaseDateButton;
import org.labkey.onprc_ehr.buttons.CreateProjectButton;
import org.labkey.onprc_ehr.buttons.DiscardTaskButton;
import org.labkey.onprc_ehr.buttons.HousingTransferButton;
import org.labkey.onprc_ehr.buttons.ManageFlagsButton;
import org.labkey.onprc_ehr.buttons.ProtocolEditButton;
import org.labkey.onprc_ehr.buttons.VetReviewButton;
import org.labkey.onprc_ehr.buttons.VetReviewRecordButton;
import org.labkey.onprc_ehr.dataentry.*;
import org.labkey.onprc_ehr.demographics.ActiveAnimalGroupsDemographicsProvider;
import org.labkey.onprc_ehr.demographics.ActiveCasesDemographicsProvider;
import org.labkey.onprc_ehr.demographics.AssignedVetDemographicsProvider;
import org.labkey.onprc_ehr.demographics.CagematesDemographicsProvider;
import org.labkey.onprc_ehr.demographics.HousingDemographicsProvider;
import org.labkey.onprc_ehr.demographics.ParentsDemographicsProvider;
import org.labkey.onprc_ehr.demographics.PregnancyConfirmDemographicsProvider;
import org.labkey.onprc_ehr.demographics.CagemateInfantDemographicsProvider;
import org.labkey.onprc_ehr.demographics.FosterChildDemographicsProvider;
import org.labkey.onprc_ehr.demographics.SourceDemographicsProvider;
import org.labkey.onprc_ehr.demographics.TBDemographicsProvider;
import org.labkey.onprc_ehr.history.DefaultAnimalGroupsDataSource;
import org.labkey.onprc_ehr.history.DefaultAnimalGroupsEndDataSource;
import org.labkey.onprc_ehr.history.DefaultAnimalRecordFlagDataSource;
import org.labkey.onprc_ehr.history.DefaultNHPTrainingDataSource;
import org.labkey.onprc_ehr.history.DefaultSnomedDataSource;
import org.labkey.onprc_ehr.history.ONPRCUrinalysisLabworkType;
import org.labkey.onprc_ehr.notification.*;
import org.labkey.onprc_ehr.security.ONPRC_EHRCMUAdministrationPermission;
import org.labkey.onprc_ehr.security.ONPRC_EHRCustomerEditPermission;
import org.labkey.onprc_ehr.security.ONPRC_EHRCustomerEditRole;
import org.labkey.onprc_ehr.security.ONPRC_EHRTransferRequestRole;
import org.labkey.onprc_ehr.security.ONPRC_EHRCMUAdministrationRole;


import org.labkey.onprc_ehr.table.ONPRC_EHRCustomizer;

import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;

/**
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:52 P
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
        return 18.10;
    }

    public boolean hasScripts()
    {
        return true;
    }

    protected void init()
    {
        addController(CONTROLLER_NAME, ONPRC_EHRController.class);

        RoleManager.registerRole(new ONPRC_EHRCustomerEditRole());
        RoleManager.registerRole(new ONPRC_EHRCMUAdministrationRole());
        RoleManager.registerRole(new ONPRC_EHRTransferRequestRole());
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        registerEHRResources();

        NotificationService ns = NotificationService.get();
        ns.registerNotification(new TreatmentAlertsNotification(this));

        //Added 6-23-2015 Blasa
        ns.registerNotification(new TreatmentAlertsPostOpsNotification(this));

        //Added 7-21-2015 Additional Scheduled for 8:30pm
        ns.registerNotification(new TreatmentAlertsPostOpsNotificationSecondary(this));

        //Added 9-2-2015 Blasa
        ns.registerNotification(new CullListNotification(this));

        //Added 1-12-2016 Blasa
        ns.registerNotification(new MensesTMBNotification(this));

        //Added 4-1-2016 Blasa
        ns.registerNotification(new ProtocolAlertsNotification(this));

         //Added 8-31-2016 Blasa     --temporary removed this info
        ns.registerNotification(new ClinicalRoundsTodayNotification(this));

        //Added 3-8-2017 Blasa
        ns.registerNotification(new ObeseFlagNotification(this));


        ns.registerNotification(new RequestAdminNotification(this));
        ns.registerNotification(new ColonyAlertsLiteNotification(this));
        ns.registerNotification(new ColonyAlertsNotification(this));
        ns.registerNotification(new ColonyMgmtNotification(this));
        ns.registerNotification(new ClinicalRoundsNotification(this));
        ns.registerNotification(new WeightAlertsNotification(this));
        ns.registerNotification(new RoutineClinicalTestsNotification(this));
        ns.registerNotification(new ComplianceNotification(this));
        ns.registerNotification(new BehaviorNotification(this));
        ns.registerNotification(new TMBNotification(this));
        ns.registerNotification(new ClinicalAlertsNotification(this));
        ns.registerNotification(new UnoccupiedRoomsNotification(this));
        ns.registerNotification(new VetReviewNotification(this));
        ns.registerNotification(new DataValidationNotification(this));
    }

    private void registerEHRResources()
    {
        EHRService.get().registerModule(this);
        EHRService.get().registerTableCustomizer(this, ONPRC_EHRCustomizer.class);

        Resource r = getModuleResource("/scripts/onprc_ehr/onprc_triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(this, r);

        EHRService.get().registerClientDependency(ClientDependency.fromPath("Ext4"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/panel/BloodSummaryPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/onprcReports.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/Utils.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/EHROverrides.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/data/sources/ONPRCDefaults.js"), this);
        //Added 6-4-2015 Blasa
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/model/sources/ClinicalProcedures.js"), this);

        //Added 11-17-16 KOLLI
   //     EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/form/field/CohortField.js"), this);

        //Added: 7-12-2016 R.Blasa
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/panel/SnapshotPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/buttons/ClinicalActionsButton.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/window/ManageTreatmentsWindow.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/panel/ManageTreatmentsPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/panel/SmallFormSnapShotPanel.js"), this);

        //Added: 8-24-2016 R.Blasa
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/DemographicsRecord.js"), this);

        //Added: 2-22-2017  R.Blasa
        EHRService.get().registerClientDependency(ClientDependency.fromPath("onprc_ehr/panel/NarrowSnapshotPanel.js"), this);


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

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.project, "View Active Projects", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=Project&query.viewName=Active Projects"), "Quick Links");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Services Needed For Processing", this, DetailsURL.fromString("/onprc_ehr/groupProcessing.view"), "Colony Services");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Date of Last Physical Exam", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsPE"), "Routine Clinical Tasks");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Date of Last TB Test", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsMostRecentTBDate&query.calculated_status~eq=Alive"), "Routine Clinical Tasks");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "View Summary of Clinical Tasks", this, DetailsURL.fromString("/ldk/runNotification.view?key=org.labkey.onprc_ehr.notification.RoutineClinicalTestsNotification"), "Routine Clinical Tasks");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Pairing Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=pairingSummary"), "Behavior");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Alopecia Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=alopeciaData"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Pathogen Summary", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=pathogenSummary"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Medical Cull List", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=medicalCullList"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Morbidity and Mortality By Breeding Group", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=animalGroupCategoryProblemSummary"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Morbidity and Mortality Raw Data", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=morbidityAndMortalityData"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Weight Loss Report", this, DetailsURL.fromString("/ldk/runNotification.view?key=org.labkey.onprc_ehr.notification.WeightAlertsNotification"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Weight Change Data", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsWeightChange&query.viewName=By Location"), "Clinical");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Clinical Alerts Report", this, DetailsURL.fromString("/ldk/runNotification.view?key=org.labkey.onprc_ehr.notification.ClinicalAlertsNotification"), "Clinical");

        //Added 1-30-2017  R.Blasa
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Clinical Snapshot Printable Report", this, DetailsURL.fromString("/onprc_ehr/SnapshotPrintableReport.view"), "Clinical");

        //Added 5-11-2015 New report for Lois Colgin
        try
        {
            EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Clinical Laboratory Test Summary", this, new URLHelper("http://primateapp.ohsu.edu/ReportServer/Pages/ReportViewer.aspx?%2fAnnual+Reports%2fPrimeLaboratory+Report&rs:Command=Render")
            {
                // SSRS is picky about the URI-encoding of the query parameters
                @Override
                public String toString()
                {
                    return "http://primateapp.ohsu.edu/ReportServer/Pages/ReportViewer.aspx?%2fAnnual+Reports%2fPrimeLaboratory+Report&rs:Command=Render";
                }
            }, "Clinical Pathology");
        }
        catch (URISyntaxException e)
        {
            throw new UnexpectedException(e);
        }

        try
        {
            EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Colony Census Excel Workbook", this, new URLHelper(AppProps.getInstance().getContextPath() + "/onprc_ehr/reports/Colony Census.xlsm"), "Colony Management");
        }
        catch (URISyntaxException e)
        {
            //ignore
        }

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Listing of Cages", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr_lookups&query.queryName=cage"), "Colony Management");
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
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Pregnant Animals (based on ultrasounds only)", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=pregnantAnimals"), "Reproductive Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Pregnant Animals (including PEs)", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=demographicsPregnancy"), "Reproductive Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Mense Data With Cycle Date", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=menseData"), "Reproductive Management");

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
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AnesthesiaFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DCMNotesFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ClinicalRoundsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SurgicalRoundsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BehaviorExamFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BehaviorRoundsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(TreatmentsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(MedSignoffFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(TBFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PairingFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(IStatFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ProcessingFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SurgeryFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SingleSurgeryFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(NecropsyFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BiopsyFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PathologyTissuesFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ClinicalReportFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BulkClinicalEntryFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DeathFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(MensFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AssignmentFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(GroupAssignmentFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BirthFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ArrivalFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DepartureFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(FlagsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(HousingFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(MatingFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PregnancyConfirmationFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ParentageFormType.class, this));

        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BloodDrawFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AuxProcedureFormType.class, this));

        //Modified: 12-13-2016 R.Blasa
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ASBRequestFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ColonyRequestFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkRequestFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(HousingRequestFormType.class, this));

        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BloodRequestBulkEditFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DrugRequestBulkEditFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkRequestBulkEditFormType.class, this));

        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(RecordAmendmentFormType.class, this));

        //Added: 10-19-2016 R.Blasa
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(NHPTrainingFormType.class, this));

        //single section forms
        EHRService.get().registerSingleFormOverride(new SingleQueryFormProvider(this, "study", "treatment_order", new MedicationsQueryFormSection("study", "Treatment Orders", "Medication/Treatment Orders")));
        EHRService.get().registerSingleFormOverride(new SingleQueryFormProvider(this, "study", "drug", new MedicationsQueryFormSection("study", "Drug Administration", "Medication/Treatments Given")));

        //demographics
        EHRService.get().registerDemographicsProvider(new ActiveCasesDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CagematesDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new HousingDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ParentsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new SourceDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveFlagsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new TBDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveAnimalGroupsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new AssignedVetDemographicsProvider(this));

        //Created: 1-20-2017 R.Blasa
        EHRService.get().registerDemographicsProvider(new PregnancyConfirmDemographicsProvider(this));


        //Created: 2-21-2017 R.Blasa
        EHRService.get().registerDemographicsProvider(new CagemateInfantDemographicsProvider(this));



        //Created: 3-10-2017 R.Blasa
        EHRService.get().registerDemographicsProvider(new FosterChildDemographicsProvider(this));

        //buttons
        EHRService.get().registerMoreActionsButton(new DiscardTaskButton(this), "ehr", "my_tasks");
        EHRService.get().registerMoreActionsButton(new DiscardTaskButton(this), "ehr", "tasks");
        EHRService.get().registerMoreActionsButton(new ProtocolEditButton(this, "ehr", "protocol_counts"), "ehr", "animalUsage");
        EHRService.get().registerMoreActionsButton(new EHRShowEditUIButton(this, "onprc_ehr", "investigators", EHRProjectEditPermission.class), "onprc_ehr", "investigators");
        EHRService.get().registerMoreActionsButton(new EHRShowEditUIButton(this, "onprc_ehr", "investigators", "Edit Investigators", EHRProjectEditPermission.class), "ehr", "project");
        EHRService.get().registerMoreActionsButton(new CreateProjectButton(this), "ehr", "project");
        EHRService.get().registerMoreActionsButton(new EHRShowEditUIButton(this, "onprc_ehr", "investigators", "Edit Investigators", EHRProjectEditPermission.class), "ehr", "protocol");
        EHRService.get().registerMoreActionsButton(new ShowEditUIButton(this, "onprc_ehr", "vet_assignment", ONPRC_EHRCMUAdministrationPermission.class), "onprc_ehr", "vet_assignment");
        EHRService.get().registerMoreActionsButton(new ShowEditUIButton(this, "study", "demographicsAssignedVet", ONPRC_EHRCMUAdministrationPermission.class), "study", "demographicsAssignedVet");
        EHRService.get().registerMoreActionsButton(new ShowEditUIButton(this, "onprc_ehr", "vet_assignment",ONPRC_EHRCMUAdministrationPermission.class), "onprc_ehr", "vet_assignment_summary");
        EHRService.get().registerMoreActionsButton(new ShowEditUIButton(this, "onprc_ehr", "customers", ONPRC_EHRCustomerEditPermission.class), "onprc_ehr", "customers");
        EHRService.get().registerMoreActionsButton(new MarkCompletedButton(this, "study", "flags", "End Flags", true), "study", "flags");
        EHRService.get().registerMoreActionsButton(new MarkCompletedButton(this, "study", "notes", "End Notes", true), "study", "notes");
        EHRService.get().registerMoreActionsButton(new MarkCompletedButton(this, "study", "cases", "End Cases", true), "study", "cases");
        EHRService.get().registerMoreActionsButton(new AnimalGroupCompletedButton(this), "study", "animal_group_members");
        EHRService.get().registerMoreActionsButton(new AssignmentCompletedButton(this), "study", "assignment");
        EHRService.get().registerMoreActionsButton(new AssignmentReleaseConditionButton(this), "study", "assignment");

        EHRShowEditUIButton editBtn = new EHRShowEditUIButton(this, "ehr_lookups", "flag_values", "Manage List of Flags", EHRDataAdminPermission.class);
        editBtn.setCopyFilters(false);
        EHRService.get().registerMoreActionsButton(editBtn, "study", "flags");

        EHRService.get().registerMoreActionsButton(new CreateTaskFromIdsButton(this, "Schedule Blood Draw For Selected", "Blood Draws", BloodDrawFormType.NAME, new String[]{"Blood Draws"}), "study", "demographics");
        //EHRService.get().registerMoreActionsButton(new CreateTaskFromIdsButton(this, "Schedule Weight For Selected", "Weight", "weight", new String[]{"Weight"}), "study", "demographics");
        //EHRService.get().registerMoreActionsButton(new CreateTaskFromIdsButton(this, "Schedule Weight For Selected", "Weight", "weight", new String[]{"Weight"}), "study", "weight");
        EHRService.get().registerTbarButton(new HousingTransferButton(this), "onprc_ehr", "housing_transfer_requests");

        EHRService.get().registerMoreActionsButton(new CreateTaskFromRecordsButton(this, "Create Task From Selected", "Blood Draws", BloodDrawFormType.NAME), "study", "blood");
        EHRService.get().registerMoreActionsButton(new CreateTaskFromRecordsButton(this, "Create Task From Selected", "Treatments/Medications", TreatmentsFormType.NAME), "study", "drug");
        EHRService.get().registerMoreActionsButton(new CreateTaskFromRecordsButton(this, "Create Task From Selected", "Labwork", LabworkFormType.NAME), "study", "clinpathRuns");
        EHRService.get().registerMoreActionsButton(new CreateTaskFromRecordsButton(this, "Create Task From Selected", "Surgeries", SurgeryFormType.NAME), "study", "surgery");

        EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this), "study", "blood");
        EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this, "ONPRC_EHR.window.ChangeLabworkStatusWindow", Collections.singleton(ClientDependency.fromPath("onprc_ehr/window/ChangeLabworkStatusWindow.js"))), "study", "clinpathRuns");
        EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this), "onprc_ehr", "housing_transfer_requests");
        EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this), "study", "encounters");
        EHRService.get().registerMoreActionsButton(new ChangeQCStateButton(this), "study", "drug");
        EHRService.get().registerTbarButton(new ChangeQCStateButton(this, "Mark Delivered", "ONPRC_EHR.window.MarkLabworkDeliveredWindow", Collections.singleton(ClientDependency.fromPath("onprc_ehr/window/MarkLabworkDeliveredWindow.js"))), "study", "clinpathRuns");

        EHRService.get().registerMoreActionsButton(new ReassignRequestButton(this, "bloodChargeType"), "study", "blood");
        EHRService.get().registerMoreActionsButton(new ReassignRequestButton(this, "medicationChargeType"), "study", "drug");
        EHRService.get().registerMoreActionsButton(new ReassignRequestButton(this, "procedureChargeType"), "study", "encounters");

        EHRService.get().registerTbarButton(new VetReviewRecordButton(this), "study", "vetRecordReview");
        EHRService.get().registerMoreActionsButton(new VetReviewButton(this), "study", "cases");
        EHRService.get().registerMoreActionsButton(new VetReviewButton(this), "study", "demographics");
        EHRService.get().registerMoreActionsButton(new ManageFlagsButton(this), "study", "demographics");
        EHRService.get().registerMoreActionsButton(new ChangeProjectedReleaseDateButton(this), "study", "assignment");

        EHRService.get().registerMoreActionsButton(new BulkEditRequestsButton(this, BloodRequestBulkEditFormType.NAME), "study", "blood");
        EHRService.get().registerMoreActionsButton(new BulkEditRequestsButton(this, DrugRequestBulkEditFormType.NAME), "study", "drug");
        EHRService.get().registerMoreActionsButton(new BulkEditRequestsButton(this, LabworkRequestBulkEditFormType.NAME), "study", "clinpathRuns");

        EHRService.get().registerOptionalClinicalHistoryResources(this);
        EHRService.get().registerHistoryDataSource(new DefaultSnomedDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultAnimalGroupsDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultAnimalGroupsEndDataSource(this));
        //R.Blasa   3-4-2015
        EHRService.get().registerHistoryDataSource(new DefaultAnimalRecordFlagDataSource(this));

        EHRService.get().registerLabworkType(new ONPRCUrinalysisLabworkType(this));
        //R.Blasa   11-28-2016
        EHRService.get().registerHistoryDataSource(new DefaultNHPTrainingDataSource(this));

        AdminLinkManager.getInstance().addListener((adminNavTree, container, user) ->
        {
            if (container.hasPermission(user, AdminPermission.class) && container.getActiveModules().contains(ONPRC_EHRModule.this))
            {
                adminNavTree.addChild(new NavTree("EHR Admin Page", new ActionURL("onprc_ehr", "ehrAdmin", container)));
            }
        });

    }

    @Override
    @NotNull
    public Collection<String> getSchemaNames()
    {
        return Arrays.asList(ONPRC_EHRSchema.SCHEMA_NAME);
    }

    @Override
    protected void registerSchemas()
    {
        DefaultSchema.registerProvider(ONPRC_EHRSchema.SCHEMA_NAME, new DefaultSchema.SchemaProvider(this)
        {
            public QuerySchema createSchema(final DefaultSchema schema, Module module)
            {
                return new ONPRC_EHRUserSchema(schema.getUser(), schema.getContainer());
            }
        });
    }
}

