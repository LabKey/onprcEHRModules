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
package org.labkey.onprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

/**
 * User: bimber
 * Date: 2/17/13
 * Time: 4:52 PM
 */
public class ONPRCClinicalRemarksDataSource extends AbstractDataSource
{
    public static final String REPLACED_SOAP = "Replaced SOAP";
    public static final String REPLACEMENT_SOAP = "Replacement SOAP";

    public ONPRCClinicalRemarksDataSource(Module module)
    {
        super("study", "Clinical Remarks", "Clinical Remark", "Clinical", module);
        setShowTime(true);
    }

    @Override
    protected String getCategoryText(Results rs) throws SQLException
    {
        String category = rs.getString("category");
        return (category == null || REPLACED_SOAP.equals(category) || REPLACEMENT_SOAP.equals(category) ?  "Clinical" : category) + " Remark";
    }


    @Override
    protected String getPrimaryGroup(Results rs) throws SQLException
    {
        String category = rs.getString("category");
        return (category == null ?  "Clinical" : category);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();
        sb.append("<table>");

        String category = rs.getString(FieldKey.fromString("category"));

        //this is a mechanism to allow individual notes to be replaced, yet remain in the record
        if (REPLACED_SOAP.equals(category))
        {
            return null;
        }

        if (!redacted && rs.getObject(FieldKey.fromString("performedby")) != null)
        {
            String label;
            if ("Replacement SOAP".equals(category))
            {
                label = "Amended By";
            }
            else
            {
                label = "Entered By";
            }

            appendNote(rs, "performedby", label, sb);
        }

        appendNote(rs, "hx", "Hx", sb);
        appendNote(rs, "so", "S/O", sb);
        appendNote(rs, "s", "S", sb);
        appendNote(rs, "o", "O", sb);
        appendNote(rs, "a", "A", sb);
        appendNote(rs, "p", "P", sb);
        appendNote(rs, "p2", "P2", sb);
        appendNote(rs, "CEG_Plan", "CEG Plan", sb);
        appendNote(rs, "remark", "Other Remark", sb);

        sb.append("</table>");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "enddate", "category", "hx", "so", "s", "o", "a", "p", "p2", "remark","CEG_Plan", "performedby");
    }

    private void appendNote(Results rs, String field, String label, StringBuilder sb) throws SQLException
    {
        if (rs.hasColumn(FieldKey.fromString(field)) && rs.getObject(FieldKey.fromString(field)) != null)
        {
            sb.append("<tr style='vertical-align:top;margin-bottom: 5px;'><td style='padding-right: 5px;'><span style='white-space:nowrap'>" + PageFlowUtil.filter(label) + ":</span></td><td>");
            sb.append(PageFlowUtil.filter(rs.getString(FieldKey.fromString(field))));
            sb.append("</td></tr>");
        }
    }
}