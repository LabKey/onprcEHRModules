/*
 * Copyright (c) 2013-2015 LabKey Corporation
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

import org.labkey.api.ehr.history.SortingLabworkType;
import org.labkey.api.module.Module;
import org.labkey.api.data.Results;
import org.labkey.api.query.FieldKey;

import java.sql.SQLException;

//Modified: 10-14-2022 R.Blasa
public class ONPRCUrinalysisLabworkType extends SortingLabworkType
{
    public ONPRCUrinalysisLabworkType(Module module)
    {
        super("Urinalysis", "study", "Urinalysis Results", "Urinalysis", module);
        _resultField = null;
        _qualResultField = "results";
        _remarkField = "remark";
    }

    protected String getLine(Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();
        String testId = getTestId(rs);
        Double result = _resultField == null ? null : rs.getDouble(FieldKey.fromString(_resultField));
        if (rs.wasNull())
        {
            result = null;
        }
        String units = _unitsField == null ? null : rs.getString(FieldKey.fromString(_unitsField));
        String qualResult = _qualResultField == null ? null : rs.getString(FieldKey.fromString(_qualResultField));
        String testIDfieldremark = _remarkField == null ? null : rs.getString(FieldKey.fromString(_remarkField));

        if (result != null || qualResult != null || testIDfieldremark != null)
        {
            sb.append("<td style='padding: 2px;'>").append(testId).append(": ").append("</td>");
            sb.append("<td style='padding: 2px;'>");

            boolean unitsAppended = false;
            boolean remarkAppended = false;
            if (result != null)
            {
                sb.append(result);
                if (units != null)
                {
                    sb.append(" ").append(units);
                    unitsAppended = true;
                }
                if (testIDfieldremark != null)
                {
                    sb.append(" ").append(testIDfieldremark);
                }
            }

            if (qualResult != null)
            {
                if (result != null)
                    sb.append(" ").append(result);

                sb.append(qualResult);

                if (units != null && !unitsAppended)
                    sb.append(" ").append(units);

            }

            if (testIDfieldremark != null)
            {
                if (result != null)
                    sb.append(result);

                if (qualResult != null)
                    sb.append(" ");

                if (units != null && !unitsAppended)
                    sb.append(" ");

                if (!remarkAppended)
                    sb.append(" ").append(testIDfieldremark);
            }


            sb.append("</td>");

            //append normals
            String normalRange = _normalRangeField == null ? null : rs.getString(FieldKey.fromString(_normalRangeField));
            String status = _normalRangeStatusField == null ? null : rs.getString(FieldKey.fromString(_normalRangeStatusField));
            if (normalRange != null)
            {
                if (status != null)
                {
                    String color = "green";
                    if (status.equals("High"))
                        color = "#E3170D";
                    else if (status.equals("Low"))
                        color = "#FBEC5D";

                    sb.append("<td style='padding: 2px;background-color: " + color + ";'>&nbsp;" + status + "&nbsp;</td>");
                }

                sb.append("<td style='padding: 2px;'>");
                sb.append(" (").append(normalRange).append(")");
                sb.append("</td>");
            }
        }

        return sb.toString();
    }

}
