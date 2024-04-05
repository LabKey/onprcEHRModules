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
package org.labkey.onprc_ehr.history;

import org.apache.commons.lang3.time.DurationUtils;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Date;
import java.util.Set;
import java.util.concurrent.TimeUnit;

//Created: 11-20-2019 R.Blasa
public class DefaultSustainedReleaseDatasource extends AbstractEHRDataSource
{
    public DefaultSustainedReleaseDatasource(Module module)
    {
        super("study", "DrugsGiven72hours", "Clinical Sustained Release Medication", "Clinical", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {


        String end = rs.getString(FieldKey.fromString("enddate"));
        String start = rs.getString(FieldKey.fromString("date"));


        StringBuilder sb = new StringBuilder();


        sb.append("Starting Date: ").append(start);
        sb.append("\n");


        if (rs.getObject(FieldKey.fromString("enddate")) != null)
        {
            sb.append("Ending Date: ").append(end);
            sb.append("\n");
        }
//        sb.append(safeAppend(rs, "Starting Date: ", "start"));
//        sb.append(safeAppend(rs, "Ending Date:", "end"));
        sb.append(safeAppend(rs, "Category", "category"));
        sb.append(safeAppend(rs, "Medication", "meaning"));
        sb.append(safeAppend(rs, "Medication Code", "code"));
        sb.append(safeAppend(rs, "Amount/Volume", "amountAndVolume"));
        sb.append(safeAppend(rs, "Route", "route"));
        long hours = DurationUtils.toDuration(rs.getDate("date").getTime() - new Date().getTime(), TimeUnit.HOURS).toHours();
        sb.append(PageFlowUtil.filter("Hours Elapsed: " + hours) + "\n");
        sb.append(safeAppend(rs, "Remarks", "remark"));


        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "enddate", "catgory", "meaning","route", "code","amountAndVolume","remark");
    }
}
