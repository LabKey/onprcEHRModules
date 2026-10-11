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
package org.labkey.onprc_ehr.table;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.util.LinkBuilder;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.api.writer.HtmlWriter;

import java.util.Collections;
import java.util.Map;
import java.util.Set;

public class ClinicalActionsDisplayColumn extends DataColumn
{
    private boolean _clickHandlerAdded = false;

    public ClinicalActionsDisplayColumn(ColumnInfo col)
    {
        super(col);
    }

    @Override
    public void renderGridCellContents(RenderContext ctx, HtmlWriter out)
    {
        Object o = getValue(ctx);
        if (o != null)
        {
            out.write(LinkBuilder.simpleLink("[Actions]").addClass("labkey-text-link cadc-row").attributes(Map.of("data-obj", o.toString())));
            if (!_clickHandlerAdded)
            {
                HttpView.currentPageConfig().addHandlerForQuerySelector("a.cadc-row", "click", "EHR.panel.ClinicalManagementPanel.displayActionMenu(this, this.attributes.getNamedItem('data-obj').value);" );
                _clickHandlerAdded = true;
            }
        }
    }

    @Override
    public @NotNull Set<ClientDependency> getClientDependencies()
    {
        return Collections.singleton(ClientDependency.fromPath("ehr/ehr_api.lib.xml"));
    }
}
