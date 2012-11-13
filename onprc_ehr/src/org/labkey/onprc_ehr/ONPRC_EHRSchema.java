package org.labkey.onprc_ehr;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.dialect.SqlDialect;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 11/9/12
 * Time: 2:50 PM
 */

public class ONPRC_EHRSchema
{
    private static final ONPRC_EHRSchema _instance = new ONPRC_EHRSchema();
    public static final String SCHEMA_NAME = "onprc_ehr";
    public static final String TABLE_ETL_RUNS = "etl_runs";

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

        public SqlDialect getSqlDialect()
        {
            return getSchema().getSqlDialect();
        }
}
