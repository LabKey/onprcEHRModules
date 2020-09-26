/*
 * Copyright (c) 2016-2017 LabKey Corporation
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

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.util.HtmlString;

//Created: 9-8-2016 R.Blasa
public class ObservationDisplayColumn extends DataColumn
{
    public ObservationDisplayColumn(ColumnInfo col)
    {
        super(col);
    }

    @Override
    public HtmlString getFormattedHtml(RenderContext ctx)
    {
        String result = super.getFormattedHtml(ctx).toString();
        return HtmlString.unsafe(result.replace("Vet Attention", "<span style=\"background-color: yellow;\">Vet Attention</span>"));
    }



}
