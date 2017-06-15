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
import org.labkey.api.module.ModuleContext;
import org.labkey.api.view.WebPartFactory;
import org.labkey.genotypeassays.assay.GenotypeAssayDataProvider;
import org.labkey.genotypeassays.assay.SNPAssayDataProvider;
import org.labkey.genotypeassays.assay.SSPAssayDataProvider;

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