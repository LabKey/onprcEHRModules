/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
import org.apache.commons.lang3.time.DateUtils;

import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.Calendar;


//Created: 10-4-2019  R.Blasa  72 hours Drugs Given
public class ActiveDrugsGivenDemographicsProvider extends AbstractListDemographicsProvider
{
    public ActiveDrugsGivenDemographicsProvider(Module module)
    {
        super(module, "study", "DrugsGiven72hours", "activeDrugs");
        _supportsQCState = false;
    }

    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("code"));
        keys.add(FieldKey.fromString("meaning"));
        keys.add(FieldKey.fromString("enddate"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("route"));
        keys.add(FieldKey.fromString("ElapseHours"));
        keys.add(FieldKey.fromString("amountAndVolume"));

        keys.add(FieldKey.fromString("remark"));
        keys.add(FieldKey.fromString("category"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && ("drug".equalsIgnoreCase(query) || "treatment_order".equalsIgnoreCase(query))) ;

    }
}
