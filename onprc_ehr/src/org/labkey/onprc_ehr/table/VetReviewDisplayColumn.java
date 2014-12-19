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
package org.labkey.onprc_ehr.table;

import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.template.ClientDependency;

import java.io.IOException;
import java.io.Writer;
import java.util.Collections;
import java.util.Set;

/**
 * User: bimber
 * Date: 10/23/13
 * Time: 3:49 PM
 */
public class VetReviewDisplayColumn extends DataColumn
{
    public VetReviewDisplayColumn(ColumnInfo col)
    {
        super(col);
    }

    public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
    {
        Object o = getValue(ctx);
        if (o != null)
        {
            String val = o.toString();
            String[] parts = val.split("<:>");
            String delim = "";
            for (String part : parts)
            {
                part = StringUtils.trimToNull(part);
                String[] tokens = part.split("<>");

                out.write(delim);
                delim = "<br><br>";
                //String key = StringUtils.trimToNull(tokens[0]);
                String text = StringUtils.trimToNull(tokens[1]);
                if (text != null)
                {
                    text = text.replaceAll("\\r?\\n", "<br>");
                    text = text.replaceAll("\\*\\*", "<span style=\"background-color: yellow;\">\\*\\*</span>");
                }

                out.write("<a style=\"max-width: 500px;\" onclick=\"EHR.panel.ClinicalManagementPanel.replaceSoap({objectid: " + PageFlowUtil.jsString(StringUtils.trimToNull(tokens[2])) + ", scope: this, callback: function(){EHR.panel.ClinicalManagementPanel.updateVetColumn(this, arguments[0], arguments[1]);}});\">");
                out.write(text);
                out.write("</a>");
            }
        }
    }

    @Override
    public @NotNull Set<ClientDependency> getClientDependencies()
    {
        return Collections.singleton(ClientDependency.fromPath("ehr/ehr_api.lib.xml"));
    }
}
