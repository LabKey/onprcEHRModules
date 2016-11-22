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

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.history.HistoryRow;
import org.labkey.api.ehr.history.HistoryRowImpl;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 2/17/13
 * Time: 4:52 PM
 */
public class DefaultSnomedDataSource extends AbstractEHRDataSource
{
    public DefaultSnomedDataSource(Module module)
    {
        super("ehr", "snomed_tags", "Diagnostic Codes", "Clinical", module);

    }

    @Override
    protected List<HistoryRow> processRows(Container c, TableSelector ts, final boolean redacted, final Collection<ColumnInfo> cols)
    {
        final Map<String, List<Map<String, Object>>> idMap = new HashMap<>();
        ts.forEach(rs -> {
            Results results = new ResultsImpl(rs, cols);

            String html = getLine(results, redacted);
            if (!StringUtils.isEmpty(html))
            {
                Map<String, Object> rowMap = new CaseInsensitiveHashMap<>();

                rowMap.put("subjectId", results.getString(FieldKey.fromString(_subjectIdField)));
                rowMap.put("date", results.getTimestamp(getDateField()));
                rowMap.put("categoryText", getCategoryText(results));
                rowMap.put("categoryGroup", getPrimaryGroup(results));
                rowMap.put("categoryColor", getCategoryColor(results));
                //rowMap.put("qcStateLabel", results.getString(FieldKey.fromString("qcState/Label")));
                //rowMap.put("publicData", results.getBoolean(FieldKey.fromString("qcState/PublicData")));
                rowMap.put("code", getCategoryText(results));
                rowMap.put("meaning", getPrimaryGroup(results));
                rowMap.put("taskId", results.getString(FieldKey.fromString("taskId")));
                rowMap.put("taskRowId", results.getInt(FieldKey.fromString("taskId/rowid")));
                rowMap.put("formType", results.getString(FieldKey.fromString("taskId/formtype")));
                rowMap.put("objectId", results.getString(FieldKey.fromString("objectId")));
                rowMap.put("html", html);

                Date roundedDate = DateUtils.truncate((Date) rowMap.get("date"), Calendar.DATE);
                String key = results.getString(FieldKey.fromString("taskid")) + "||" + rowMap.get("Id") + "||" + roundedDate.toString();
                List<Map<String, Object>> obsRows = idMap.get(key);
                if (obsRows == null)
                    obsRows = new ArrayList<>();

                obsRows.add(rowMap);
                idMap.put(key, obsRows);
            }
        });

        List<HistoryRow> rows = new ArrayList<>();
        for (String key : idMap.keySet())
        {
            List<Map<String, Object>> toAdd = idMap.get(key);

            Date date = null;
            String subjectId = null;
            String categoryGroup = null;
            String categoryColor = null;
            String categoryText = null;
            //String qcStateLabel = null;
            Boolean publicData = null;
            String taskId = null;
            Integer taskRowId = null;
            String formType = null;
            String objectId = null;
            StringBuilder html = new StringBuilder();

            for (Map<String, Object> rowMap : toAdd)
            {
                date = (Date)rowMap.get("date");
                subjectId = (String)rowMap.get("subjectId");
                categoryText = (String)rowMap.get("categoryText");
                categoryGroup = (String)rowMap.get("categoryGroup");
                categoryColor = (String)rowMap.get("categoryColor");
                //qcStateLabel = (String)rowMap.get("qcStateLabel");
                publicData = (Boolean)rowMap.get("publicData");
                taskId = (String)rowMap.get("taskId");
                taskRowId = (Integer)rowMap.get("taskRowId");
                formType = (String)rowMap.get("formType");
                objectId = (String)rowMap.get("objectId");

                html.append(rowMap.get("html"));
            }

            HistoryRow row = new HistoryRowImpl(this, categoryText, categoryGroup, categoryColor, subjectId, date, html.toString(), null, publicData, taskId, taskRowId, formType, objectId);
            if (row != null)
                rows.add(row);
        }

        return rows;
    }

    private String getLine(Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        if (rs.getString(FieldKey.fromString("code/meaning")) != null)
            sb.append(rs.getString(FieldKey.fromString("code/meaning")));

        if (rs.getString(FieldKey.fromString("code")) != null)
        {
            boolean addSuffix = false;
            if (sb.length() > 0)
            {
                sb.append(" (");
                addSuffix = true;
            }

            sb.append(rs.getString(FieldKey.fromString("code")));

            if (addSuffix)
                sb.append(")");
        }

        if (sb.length() > 0)
            sb.append("\n");

        return sb.toString();
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        throw new UnsupportedOperationException("This should not be called");
    }

    @Override
    protected @NotNull
    List<HistoryRow> getRows(Container c, User u, SimpleFilter filter, boolean redacted)
    {
        filter.addCondition(FieldKey.fromString("recordid"), null, CompareType.ISBLANK);

        return super.getRows(c, u, filter, redacted);
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "code/meaning", "code", "taskid", "objectid", "taskid");
    }
}
