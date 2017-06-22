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

import org.apache.commons.lang3.StringUtils;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

import java.sql.Date;
import java.sql.SQLException;
import java.util.Set;

//Created: 11-28-2016  R.Blasa
public class DefaultNHPTrainingDataSource extends AbstractEHRDataSource
{
    public DefaultNHPTrainingDataSource(Module module)
    {
        super("onprc_ehr", "NHP_Training", "NHP Training", "Behavior", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        Date end = rs.getDate(FieldKey.fromString("training_Ending_Date"));
        Date start = rs.getDate(FieldKey.fromString("date"));
        StringBuilder sb = new StringBuilder();


        sb.append("Training Starting Date: ").append(DateUtil.formatDateTime(c, start));
        sb.append("\n");

        if (rs.getObject(FieldKey.fromString("training_Ending_Date")) != null)
        {
            sb.append("Training Ending Date: ").append(DateUtil.formatDateTime(c, end));
            sb.append("\n");
        }

        sb.append(safeAppend(rs, "Training Type", "training_type"));
        sb.append(safeAppend(rs, "Reason for Training", "reason"));
        sb.append(safeAppend(rs, "Training Results", "training_results"));
        sb.append(safeAppend(rs, "Performed By", "performedby"));
        sb.append(safeAppend(rs, "Remarks", "remark"));


        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {

        return PageFlowUtil.set("Id", "date", "training_Ending_Date", "training_type", "reason", "training_results","performedby", "remark");
    }
}
