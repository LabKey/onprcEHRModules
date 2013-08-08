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

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.dialect.SqlDialect;

public class GenotypeAssaysSchema
{
    private static final GenotypeAssaysSchema _instance = new GenotypeAssaysSchema();
    public static final String TABLE_PRIMER_PAIRS = "primer_pairs";
    public static final String TABLE_SSP_RESULT_TYPES = "ssp_result_types";

    public static GenotypeAssaysSchema getInstance()
    {
        return _instance;
    }

    private GenotypeAssaysSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class
    }

    public DbSchema getSchema()
    {
        return DbSchema.get(GenotypeAssaysModule.SCHEMA_NAME);
    }

    public TableInfo getTable(String name)
    {
        return getSchema().getTable(name);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }
}
