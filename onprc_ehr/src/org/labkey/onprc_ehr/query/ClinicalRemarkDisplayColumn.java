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
package org.labkey.onprc_ehr.query;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.JavaScriptDisplayColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.ehr.EHRQCState;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.view.template.ClientDependency;

import java.io.IOException;
import java.io.Writer;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 10/28/13
 * Time: 11:35 AM
 */
public class ClinicalRemarkDisplayColumn extends DataColumn
{
    private final LinkedHashSet<ClientDependency> _dependencies = new LinkedHashSet<>();
    private String _targetColName;
    private boolean _hasInsertCompletedPermission;
    private boolean _hasInsertInProgressPermission;

    public ClinicalRemarkDisplayColumn(ColumnInfo col, String targetColName)
    {
        super(col);
        _targetColName = targetColName;

        Container c  = col.getParentTable().getUserSchema().getContainer();
        _hasInsertInProgressPermission = EHRService.get().hasPermission("study", "clinremarks", c, col.getParentTable().getUserSchema().getUser(), InsertPermission.class, EHRService.QCSTATES.InProgress.getQCState(c));
        _hasInsertCompletedPermission = EHRService.get().hasPermission("study", "clinremarks", c, col.getParentTable().getUserSchema().getUser(), InsertPermission.class, EHRService.QCSTATES.Completed.getQCState(c));
        _dependencies.add(ClientDependency.fromModuleName("ehr"));
    }

    @Override
    public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
    {
        Object o = getValue(ctx);

        if (o != null)
        {
            out.write("<a href=\"#\" tabindex=\"-1\" ");

            if (_hasInsertCompletedPermission || _hasInsertInProgressPermission)
            {
                out.write(" onclick='alert(\"Hello!\")'");
            }

            out.write(">");
            out.write(getFormattedValue(ctx));
            out.write("</a>");
        }
        else
        {
            if (_hasInsertInProgressPermission)
            {
                out.write("<span style=\"white-space:nowrap\"><a href=\"javascript:void(0);\" tabindex=\"-1\" ");
                out.write(" onclick='EHR.window.EnterRemarkWindow.createWindow(\"" + ctx.get("Id") + "\", \"" + ctx.get("category") + "\", \"" + ctx.get("objectid") + "\")'>");
                out.write("[Enter Remark]</a></span>");
            }
            else
            {
                out.write("&nbsp;");
            }
        }
    }

    @Override
    public void addQueryFieldKeys(Set<FieldKey> keys)
    {
        super.addQueryFieldKeys(keys);
        keys.add(new FieldKey(getBoundColumn().getFieldKey().getParent(), "Id"));
        keys.add(new FieldKey(getBoundColumn().getFieldKey().getParent(), "objectid"));
        keys.add(new FieldKey(getBoundColumn().getFieldKey().getParent(), "category"));
    }

    @Override
    public Set<ClientDependency> getClientDependencies()
    {
        return _dependencies;
    }
}
