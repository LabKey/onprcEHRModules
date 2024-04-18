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

package org.labkey.ONPRCEHR_ComplianceDB;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.dialect.SqlDialect;

public class ONPRC_EHR_ComplianceDBSchema
{
    public static final String NAME = "onprc_ehr_complianceDB";

    private static final ONPRC_EHR_ComplianceDBSchema _instance = new ONPRC_EHR_ComplianceDBSchema();


    public static final String TABLE_SCISHIELD_DATA = "SciShield_Data";
    public static final String TABLE_SCISHIELD_REFERENCE_DATA = "SciShield_Reference_Data";

    public static final String TABLE_EMPLOYEEPERUNIT_DATA = "employeeperUnit";

    public static final String TABLE_COMPLETIONDATES_DATA = "completiondates";

    public static ONPRC_EHR_ComplianceDBSchema getInstance()
    {
        return _instance;
    }

    private ONPRC_EHR_ComplianceDBSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class: this singleton should only be
        // accessed via org.labkey.ONPRCEHR_ComplianceDB.ONPRC_EHR_ComplianceDBSchema.getInstance()
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
