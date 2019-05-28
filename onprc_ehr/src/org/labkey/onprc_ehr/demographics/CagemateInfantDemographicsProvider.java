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
 */
package org.labkey.onprc_ehr.demographics;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

//Added: 2-21-2017 R.Blasa
public class CagemateInfantDemographicsProvider extends AbstractListDemographicsProvider
{
    public CagemateInfantDemographicsProvider(Module module)
    {
        super(module, "study", "CageMateInfant", "cagemateinfant");
        _supportsQCState = true;
    }

    @Override

    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("room"));
        keys.add(FieldKey.fromString("InfantCageMate"));

        return keys;
    }



    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && "Births".equalsIgnoreCase(query)) ||
                ("study".equalsIgnoreCase(schema) && "housing".equalsIgnoreCase(query)) ||
                ("ehr_lookups".equalsIgnoreCase(schema) && "cage".equalsIgnoreCase(query))  ||
                ("study".equalsIgnoreCase(schema) && "Demographics".equalsIgnoreCase(query));

    }



}
