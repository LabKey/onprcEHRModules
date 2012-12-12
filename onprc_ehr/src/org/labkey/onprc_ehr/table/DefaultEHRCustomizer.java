package org.labkey.onprc_ehr.table;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableCustomizer;
import org.labkey.api.data.TableInfo;

import java.sql.Timestamp;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/7/12
 * Time: 2:22 PM
 */
public class DefaultEHRCustomizer implements TableCustomizer
{
    public DefaultEHRCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        for (ColumnInfo col : table.getColumns())
        {
            COL_ENUM.processColumn(col);
        }
    }

    private enum COL_ENUM
    {
        project(Integer.class){
            public void customizeColumn(ColumnInfo col)
            {
                col.setFormat("00000000");
            }
        };

        private Class dataType;

        COL_ENUM(Class dataType){
            this.dataType = dataType;
        }

        abstract public void customizeColumn(ColumnInfo col);

        public static void processColumn(ColumnInfo col)
        {
            try
            {
                COL_ENUM colEnum = COL_ENUM.valueOf(col.getName().toLowerCase());
                if (colEnum != null)
                {
                    if (col.getJdbcType().getJavaClass() == colEnum.dataType)
                    {
                        colEnum.customizeColumn(col);
                    }

                    if (col.isAutoIncrement())
                    {
                        col.setUserEditable(false);
                        col.setShownInInsertView(false);
                        col.setShownInUpdateView(false);
                    }
                }
            }
            catch (IllegalArgumentException e)
            {
                //ignore, unknown column name
            }
        }
    }
}
