/*
 * Copyright (c) 2013 LabKey Corporation
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

import org.apache.commons.lang3.StringUtils;
import org.labkey.api.data.Container;
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 7/9/13
 * Time: 10:12 PM
 */
public class CagematesDemographicsProvider extends AbstractListDemographicsProvider
{
    public CagematesDemographicsProvider(Module module)
    {
        super("study", "demographicsPaired", "cagemates", module);
        _supportsQCState = false;
    }

    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("total"));
        keys.add(FieldKey.fromString("animals"));
        keys.add(FieldKey.fromString("category"));
        keys.add(FieldKey.fromString("housingType"));

        return keys;
    }

    @Override
    public Set<String> getIdsToUpdate(Container c, String id, Map<String, Object> originalProps, Map<String, Object> newProps)
    {
        List<Map<String, Object>> oldList = originalProps == null ? null : (List)originalProps.get(_propName);
        List<Map<String, Object>> newList = newProps == null ? null : (List)newProps.get(_propName);
        Set<String> ret = new HashSet<>();

        if (oldList == null && newList == null)
        {
            return Collections.emptySet();
        }
        else if (oldList == null && newList != null && !newList.isEmpty())
        {
            Map<String, Object> list = newList.get(0);
            List<String> newAnimals = list.get("animals") == null ? null : Arrays.asList(StringUtils.split((String)list.get("animals"), ", "));
            if (newAnimals != null)
            {
                newAnimals.remove(id);
                ret.addAll(newAnimals);
            }
        }
        else if (oldList != null && newList == null && !oldList.isEmpty())
        {
            Map<String, Object> list = oldList.get(0);
            List<String> oldAnimals = list.get("animals") == null ? null : Arrays.asList(StringUtils.split((String) list.get("animals"), ", "));
            if (oldAnimals != null)
            {
                oldAnimals.remove(id);
                ret.addAll(oldAnimals);
            }
        }
        else if (oldList != null && newList != null)
        {
            Map<String, Object> list = oldList.get(0);
            List<String> oldAnimals = list.get("animals") == null ? null : Arrays.asList(StringUtils.split((String) list.get("animals"), ", "));

            Map<String, Object> list2 = newList.get(0);
            List<String> newAnimals = list2.get("animals") == null ? null : Arrays.asList(StringUtils.split((String) list2.get("animals"), ", "));

            Set<String> set = new HashSet<>();
            if (oldAnimals != null)
                set.addAll(oldAnimals);

            if (newAnimals != null)
                set.addAll(newAnimals);
            set.remove(id);
            ret.addAll(set);
        }

        return ret;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && "Housing".equalsIgnoreCase(query)) ||
               ("study".equalsIgnoreCase(schema) && "Demographics".equalsIgnoreCase(query)) ||
               ("ehr_lookups".equalsIgnoreCase(schema) && "cage".equalsIgnoreCase(query));
    }

}
