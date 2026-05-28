/*
 * Copyright (c) 2013-2026 LabKey Corporation
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
package org.labkey.onprc_reports;

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.BaseColumnInfo;
import org.labkey.api.data.TableCustomizer;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.UserSchema;

/***
 * User: bimber
 * Date: 5/16/13
 * Time: 3:41 PM
 */
public class ONPRC_ReportsCustomizer implements TableCustomizer
{
    @Override
    public void customize(TableInfo table)
    {
        if (table instanceof AbstractTableInfo)
        {
            if (matches(table, "study", "Animal"))
            {
                appendMHCColumn((AbstractTableInfo)table);
            }
        }
    }

    private void appendMHCColumn(AbstractTableInfo ti)
    {
        String name = "mhcSummary";
        if (ti.getColumn(name) == null)
        {
            BaseColumnInfo col = getWrappedIdCol(ti.getUserSchema(), ti, name, "demographicsMHCTests");
            col.setLabel("MHC Test Summary");
            ti.addColumn(col);
        }

        String name2 = "dnaBank";
        if (ti.getColumn(name2) == null)
        {
            BaseColumnInfo col = getWrappedIdCol(ti.getUserSchema(), ti, name2, "demographicsDNABank");
            col.setLabel("DNA Bank Summary");
            ti.addColumn(col);
        }
    }

    private BaseColumnInfo getWrappedIdCol(UserSchema us, AbstractTableInfo ds, String name, String queryName)
    {
        String ID_COL = "Id";
        WrappedColumn col = new WrappedColumn(ds.getColumn(ID_COL), name);
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(QueryForeignKey.from(us, ds.getContainerFilter())
                .table(queryName)
                .key(ID_COL)
                .display(ID_COL));

        return col;
    }

    private boolean matches(TableInfo ti, String schema, String query)
    {
        return ti.getSchema().getName().equalsIgnoreCase(schema) && ti.getName().equalsIgnoreCase(query);
    }
}
