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

package org.labkey.hormoneassay;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.dialect.SqlDialect;

public class HormoneAssaySchema
{
    private static final HormoneAssaySchema _instance = new HormoneAssaySchema();
    public static final String NAME = "hormoneassay";

    public static final String TABLE_ROCHETESTS = "rochee411_tests";
    public static final String TABLE_ASSAYTESTS = "assay_tests";

    public static HormoneAssaySchema getInstance()
    {
        return _instance;
    }

    private HormoneAssaySchema()
    {

    }

    public DbSchema getSchema()
    {
        return DbSchema.get(NAME);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }
}
