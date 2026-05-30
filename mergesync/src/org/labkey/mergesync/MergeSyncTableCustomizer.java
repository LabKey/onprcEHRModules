/*
 * Copyright (c) 2014-2026 LabKey Corporation
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
package org.labkey.mergesync;

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.query.UserSchema;

/**

 */
public class MergeSyncTableCustomizer extends AbstractTableCustomizer
{
    public MergeSyncTableCustomizer()
    {

    }

    @Override
    public void customize(TableInfo ti)
    {
        if (ti instanceof AbstractTableInfo && (matches(ti, "study", "Clinpath Runs") || matches(ti, "study", "clinpathRuns")))
        {
            customizeClinpathRuns((AbstractTableInfo)ti);
        }
    }

    private void customizeClinpathRuns(AbstractTableInfo ti)
    {
        if (ti.getUserSchema().getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule(MergeSyncModule.NAME)))
        {
            String name = "mergeSyncInfo";
            if (ti.getColumn(name) == null && ti.getColumn("servicerequested") != null)
            {
                final UserSchema us = getUserSchema(ti, MergeSyncSchema.NAME);
                WrappedColumn ci = new WrappedColumn(ti.getColumn("servicerequested"), name);
                LookupForeignKey fk = new LookupForeignKey()
                {
                    @Override
                    public TableInfo getLookupTableInfo()
                    {
                        return us.getTable(MergeSyncManager.TABLE_TESTNAMEMAPPING);
                    }
                };

                ci.setFk(fk);
                ci.setUserEditable(false);
                ci.setIsUnselectable(true);
                ci.setLabel("Merge Sync Info");
                ti.addColumn(ci);
            }
        }
    }
}
