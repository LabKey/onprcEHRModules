/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
package org.labkey.onprc_ehr;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.dialect.SqlDialect;

/**
 * User: bimber
 * Date: 11/9/12
 * Time: 2:50 PM
 */

public class ONPRC_EHRSchema
{
    private static final ONPRC_EHRSchema _instance = new ONPRC_EHRSchema();
    public static final String SCHEMA_NAME = "onprc_ehr";
    public static final String BILLING_SCHEMA_NAME = "onprc_billing";

    public static final String TABLE_ETL_RUNS = "etl_runs";
    public static final String TABLE_INVOICED_ITEMS = "invoicedItems";
    public static final String TABLE_INVOICE_RUNS = "invoiceRuns";
    public static final String TABLE_MISC_CHARGES = "miscCharges";
    public static final String TABLE_PROJECT_ACCOUNT_HISTORY = "projectAccountHistory";

    public static ONPRC_EHRSchema getInstance()
    {
        return _instance;
    }

    private ONPRC_EHRSchema()
    {

    }

    public DbSchema getSchema()
    {
        return DbSchema.get(SCHEMA_NAME);
    }

    public DbSchema getBillingSchema()
    {
        return DbSchema.get(BILLING_SCHEMA_NAME);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }
}