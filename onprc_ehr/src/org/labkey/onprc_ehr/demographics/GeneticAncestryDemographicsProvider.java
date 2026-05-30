/*
 * Copyright (c) 2020-2026 LabKey Corporation
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
package org.labkey.onprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * Created by bimber on 3/23/2017.
 */
public class GeneticAncestryDemographicsProvider extends AbstractDemographicsProvider
{
    public GeneticAncestryDemographicsProvider(Module module)
    {
        super(module, "study", "demographicsGeneticAncestry");
        _supportsQCState = false;
    }

    @Override
    public String getName()
    {
        return "Genetic Ancestry";
    }

    @Override
    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("geneticAncestry"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return "study".equalsIgnoreCase(schema) && ("geneticAncestry".equalsIgnoreCase(query) || "Genetic Ancestry".equalsIgnoreCase(query));
    }
}
