/*
 * Copyright (c) 2013-2016 LabKey Corporation
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

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.ehr.history.HistoryRow;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import java.util.Set;

//Created: 6-3-2021   R.Blasa
public class BiopsyHistologyDataSource extends AbstractDataSource
{
        public BiopsyHistologyDataSource (Module module)
        {
                super ("study", "histology", "Biopsy Diagnosis", "Biopsy", module);
        }

        @Override
        protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
        {
                StringBuilder sb = new StringBuilder();
                sb.append("<table>");

                appendNote(rs, "tissue/meaning", sb);
                appendNote(rs, "remark",sb);

                sb.append("</table>");

                return sb.toString();
        }
        @Override
        protected SimpleFilter getFilter(String subjectId, Date minDate, Date maxDate)
        {
                SimpleFilter result = super.getFilter(subjectId, minDate, maxDate);
                result.addCondition(FieldKey.fromParts("taskid", "formtype"), "Biopsy");
                return result;
        }


        @Override
        protected Set<String> getColumnNames()
        {
                return PageFlowUtil.set("Id", "date", "sort_order", "codes","remark", "tissue/meaning");
        }

        private void appendNote(Results rs, String field, StringBuilder sb) throws SQLException
        {
                if (rs.hasColumn(FieldKey.fromString(field)) && rs.getObject(FieldKey.fromString(field)) != null)
                {
//                        sb.append("<tr style='vertical-align:top;margin-bottom: 5px;'><td style='padding-right: 5px;'>" + label + ":</td><td>");
                        sb.append("<tr style='vertical-align:top;margin-bottom: 5px;'></td><td>");
                        sb.append(PageFlowUtil.filter(rs.getString(FieldKey.fromString(field))));
                        sb.append("</td></tr>");
                }
        }
}
