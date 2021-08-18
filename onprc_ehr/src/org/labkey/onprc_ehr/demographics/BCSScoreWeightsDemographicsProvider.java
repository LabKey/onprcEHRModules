/*
 * Copyright (c) 2017 LabKey Corporation
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
 * Updated 2021-08-18 Update to stop error reporting
 */
package org.labkey.onprc_ehr.demographics;

import org.labkey.api.data.Sort;
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

//Created: 1-16-2021  R.Blasa
public class BCSScoreWeightsDemographicsProvider extends AbstractListDemographicsProvider
{
    public BCSScoreWeightsDemographicsProvider(Module module)
    {
        super(module, "study", "BCSScoreWeights", "BCSWeights");
        _supportsQCState = false;
    }
//update 8-18-2021 jonesga
    @Override
    public Collection<String> getKeysToTest()
    {
        Set<String> keys = new HashSet<>(super.getKeysToTest());
        keys.remove("BCSWeights");

        return keys;
    }

    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("weight"));
        keys.add(FieldKey.fromString("observation"));
        keys.add(FieldKey.fromString("duration"));
        keys.add(FieldKey.fromString("weightdate"));

        return keys;
    }

    @Override
    protected Sort getSort()
    {

        return new Sort("-weightdate");
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return "study".equalsIgnoreCase(schema) && ("Demographics".equalsIgnoreCase(query) || "weight".equalsIgnoreCase(query)  || "clinical_observations".equalsIgnoreCase(query)) ;

    }

}
