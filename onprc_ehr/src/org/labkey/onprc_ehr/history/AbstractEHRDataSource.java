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
package org.labkey.onprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.User;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

/**
 * User: bimber
 * Date: 7/22/13
 * Time: 11:58 AM
 */
abstract public class AbstractEHRDataSource extends AbstractDataSource
{
    public AbstractEHRDataSource(String schema, String query)
    {
        super(schema, query);
    }

    public AbstractEHRDataSource(String schema, String query, String categoryText, String categoryGroup)
    {
        super(schema, query, categoryText, categoryGroup);
    }

    @Override
    public boolean isAvailable(Container c, User u)
    {
        if (!c.getActiveModules().contains(ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class)))
        {
            return false;
        }

        return super.isAvailable(c, u);
    }
}
