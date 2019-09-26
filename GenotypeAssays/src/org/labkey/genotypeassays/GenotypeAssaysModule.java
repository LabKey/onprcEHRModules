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

package org.labkey.genotypeassays;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.laboratory.LaboratoryService;
import org.labkey.api.laboratory.button.ChangeAssayResultStatusBtn;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.genotypeassays.assay.GenotypeAssayDataProvider;
import org.labkey.genotypeassays.assay.SNPAssayDataProvider;
import org.labkey.genotypeassays.assay.SSPAssayDataProvider;
import org.labkey.genotypeassays.buttons.HaplotypeReviewButton;
import org.labkey.genotypeassays.buttons.PublishSBTResultsButton;
import org.labkey.genotypeassays.buttons.SBTReviewButton;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Set;

public class GenotypeAssaysModule extends ExtendedSimpleModule
{
    public static final String NAME = "GenotypeAssays";
    public static final String SCHEMA_NAME = "genotypeassays";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public double getVersion()
    {
        return 0.03;
    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    @Override
    @NotNull
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return Collections.emptyList();
    }

    @Override
    protected void init()
    {
        addController("genotypeassays", GenotypeAssaysController.class);
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        LaboratoryService.get().registerModule(this);
        LaboratoryService.get().registerDataProvider(new SSPAssayDataProvider(this));
        LaboratoryService.get().registerDataProvider(new GenotypeAssayDataProvider(this));
        LaboratoryService.get().registerDataProvider(new SNPAssayDataProvider(this));

        LaboratoryService.get().registerAssayButton(new ChangeAssayResultStatusBtn(this), GenotypeAssaysManager.GENOTYPE_ASSAY_PROVIDER, "Data");
        LaboratoryService.get().registerAssayButton(new ChangeAssayResultStatusBtn(this), GenotypeAssaysManager.SNP_ASSAY_PROVIDER, "Data");

        LaboratoryService.get().registerAssayResultsIndex(GenotypeAssaysManager.SSP_ASSAY_PROVIDER, Arrays.asList("DataId:ASC", "include:primerPair,result,subjectId"));
        LaboratoryService.get().registerAssayResultsIndex(GenotypeAssaysManager.GENOTYPE_ASSAY_PROVIDER, Arrays.asList("result", "DataId"));
        LaboratoryService.get().registerAssayResultsIndex(GenotypeAssaysManager.GENOTYPE_ASSAY_PROVIDER, Arrays.asList("RowId", "DataId"));

        SimpleButtonConfigFactory btn3 = new SimpleButtonConfigFactory(this, "Edit Alignments", "GenotypeAssays.window.EditAlignmentsWindow.buttonHandler(dataRegionName, arguments[0] ? arguments[0].ownerCt : null)");
        btn3.setClientDependencies(ClientDependency.fromModuleName("laboratory"), ClientDependency.fromModuleName("sequenceanalysis"), ClientDependency.fromPath("genotypeassays/window/EditAlignmentsWindow.js"));
        LDKService.get().registerQueryButton(btn3, "sequenceanalysis", "alignment_summary_grouped");

        LDKService.get().registerQueryButton(new SBTReviewButton(), "sequenceanalysis", "sequence_analyses");
        LDKService.get().registerQueryButton(new HaplotypeReviewButton(), "sequenceanalysis", "sequence_analyses");
        LDKService.get().registerQueryButton(new PublishSBTResultsButton(), "sequenceanalysis", "alignment_summary_by_lineage");
        //LDKService.get().registerQueryButton(new PublishSBTHaplotypesButton(), "sequenceanalysis", "haplotypeMatches");
        LaboratoryService.get().registerTableCustomizer(this, GeneticsTableCustomizer.class, "sequenceanalysis", "sequence_analyses");
        LaboratoryService.get().registerTableCustomizer(this, GeneticsTableCustomizer.class, "sequenceanalysis", "alignment_summary_by_lineage");
        LaboratoryService.get().registerTableCustomizer(this, GeneticsTableCustomizer.class, "sequenceanalysis", "alignment_summary_grouped");
    }

    @Override
    @NotNull
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        return Collections.singleton(SCHEMA_NAME);
    }

    @Override
    @NotNull
    public Set<DbSchema> getSchemasToTest()
    {
        return Collections.singleton(GenotypeAssaysSchema.getInstance().getSchema());
    }
}