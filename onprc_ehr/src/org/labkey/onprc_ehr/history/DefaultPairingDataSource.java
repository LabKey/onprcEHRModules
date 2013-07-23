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
package org.labkey.onprc_ehr.history;

import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.gwt.client.util.StringUtils;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

/**
 * User: bimber
 * Date: 2/17/13
 * Time: 4:52 PM
 */
public class DefaultPairingDataSource extends AbstractEHRDataSource
{
    public DefaultPairingDataSource()
    {
        super("study", "pairingData", "Pairing", "Behavior");
    }

    @Override
    protected String getHtml(Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();
        sb.append(safeAppend(rs, "Second Id", "Id2"));
        sb.append(safeAppend(rs, "Pairing Type", "pairingType/value"));
        sb.append(safeAppend(rs, "Pairing Outcome", "pairingoutcome/value"));
        sb.append(safeAppend(rs, "Separation Reason", "separationreason/value"));
        sb.append(safeAppend(rs, "Aggressor", "aggressor"));

        String room1 = rs.getString("room1");
        if (!StringUtils.isEmpty(room1))
        {
            sb.append("Location 1: ").append(room1);
            String cage = rs.getString("cage1");
            if (!StringUtils.isEmpty(cage))
            {
                sb.append(" / ").append(cage);
            }
            sb.append("\n");
        }

        String room2 = rs.getString("room2");
        if (!StringUtils.isEmpty(room2))
        {
            sb.append("Location 2: ").append(room2);
            String cage = rs.getString("cage2");
            if (!StringUtils.isEmpty(cage))
            {
                sb.append(" / ").append(cage);
            }
            sb.append("\n");
        }

        sb.append(safeAppend(rs, "remark", "Remark"));
        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "enddate", "pairingType/value", "pairingoutcome/value", "separationreason/value", "aggressor", "room1", "cage1", "room2", "cage2", "remark");
    }
}
