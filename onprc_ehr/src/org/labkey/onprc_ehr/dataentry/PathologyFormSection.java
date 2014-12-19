/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormElement;
import org.labkey.api.query.FieldKey;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

/**
 * User: bimber
 * Date: 11/20/13
 * Time: 7:52 PM
 */
public class PathologyFormSection extends EncounterChildFormSection
{
    public PathologyFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label, false);

        addClientDependency(ClientDependency.fromPath("ehr/form/field/SnomedCodesEditor.js"));
        addClientDependency(ClientDependency.fromPath("ehr/grid/SnomedColumn.js"));
    }

    @Override
    protected List<FormElement> getFormElements(DataEntryFormContext ctx)
    {
        List<FormElement> ret = super.getFormElements(ctx);

        for (TableInfo ti : getTables(ctx))
        {
            ColumnInfo col = ti.getColumn(FieldKey.fromString("codesRaw"));
            if (col != null)
            {
                ret.add(FormElement.createForColumn(col));
            }
        }

        return ret;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.add("DUPLICATE");

        return defaultButtons;
    }
}
