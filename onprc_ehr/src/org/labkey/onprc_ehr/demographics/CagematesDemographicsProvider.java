/*
 * Copyright (c) 2013-2016 LabKey Corporation
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
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * User: bimber
 * Date: 7/9/13
 * Time: 10:12 PM
 */
public class CagematesDemographicsProvider extends AbstractListDemographicsProvider
{
    public CagematesDemographicsProvider(Module module)
    {
        super(module, "study", "demographicsPaired", "cagemates");
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
        Set<String> ret = new TreeSet<>();

        List<String> oldAnimals = oldList == null || oldList.isEmpty() ? Collections.emptyList() : toList(oldList.get(0).get("animals"));
        List<String> newAnimals = newList == null || newList.isEmpty() ? Collections.emptyList() : toList(newList.get(0).get("animals"));
        if (oldAnimals.equals(newAnimals))
        {
            if (!oldAnimals.isEmpty())
            {
                _log.info(id + ": cagemates before/after move are identical, no changes needed.  list size: " + oldAnimals.size());
            }
            return Collections.emptySet();
        }

        ret.addAll(oldAnimals);
        ret.addAll(newAnimals);
        ret.remove(id);

        if (!ret.isEmpty())
        {
            _log.info(id + ": Triggered additional housing updates for " + ret.size() + " ids: " + StringUtils.join(ret, ";"));
        }

        return ret;
    }

    private List<String> toList(Object input)
    {
        if (input == null)
            return Collections.emptyList();

        if (input instanceof  List)
        {
            return (List)input;
        }
        else if (input instanceof String)
        {
            return Arrays.asList(StringUtils.split((String) input, ", "));
        }
        else
        {
            _log.error("Unknown type: " + input.getClass().getName() + ", " + input);
            return Collections.emptyList();
        }
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && "Housing".equalsIgnoreCase(query)) ||
               ("study".equalsIgnoreCase(schema) && "Demographics".equalsIgnoreCase(query)) ||
               ("ehr_lookups".equalsIgnoreCase(schema) && "cage".equalsIgnoreCase(query));
    }

}
