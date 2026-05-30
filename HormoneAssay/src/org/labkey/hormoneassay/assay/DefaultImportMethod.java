/*
 * Copyright (c) 2013-2026 LabKey Corporation
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
package org.labkey.hormoneassay.assay;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.Container;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.laboratory.assay.AssayImportMethod;
import org.labkey.api.laboratory.assay.AssayParser;
import org.labkey.api.laboratory.assay.DefaultAssayImportMethod;
import org.labkey.api.laboratory.assay.DefaultAssayParser;
import org.labkey.api.laboratory.assay.ImportContext;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.view.ViewContext;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DefaultImportMethod extends DefaultAssayImportMethod
{
    public static final String CATEGORY_FIELD = "category";

    public DefaultImportMethod(String providerName)
    {
        super(providerName);
    }

    @Override
    public JSONObject getMetadata(ViewContext ctx, ExpProtocol protocol)
    {
        JSONObject meta = super.getMetadata(ctx, protocol);

        JSONObject resultMeta = getJsonObject(meta, "Results");
        String[] globalResultFields = new String[]{"sampleType"};
        for (String field : globalResultFields)
        {
            JSONObject json = getJsonObject(resultMeta, field);
            json.put("setGlobally", true);
            resultMeta.put(field, json);
        }
        meta.put("Results", resultMeta);

        return meta;
    }

    @Override
    public AssayParser getFileParser(Container c, User u, int assayId)
    {
        return new HormoneAssayParser(this, c, u, assayId);
    }

    protected static class HormoneAssayParser extends DefaultAssayParser
    {
        public HormoneAssayParser(AssayImportMethod method, Container c, User u, int assayId)
        {
            super(method, c, u, assayId);
        }

        @Override
        protected List<Map<String, Object>> processRows(List<Map<String, Object>> rows, ImportContext context) throws BatchValidationException
        {
            rows = super.processRows(rows, context);
            return handleRows(rows);
        }
    }

    public static List<Map<String, Object>> handleRows(List<Map<String, Object>> rows)
    {
        List<Map<String, Object>> newRows = new ArrayList<>();
        for (Map<String, Object> row : rows)
        {
            Map<String, Object> map = new CaseInsensitiveHashMap<>(row);
            if (StringUtils.isEmpty((String)map.get(CATEGORY_FIELD)))
            {
                map.put(CATEGORY_FIELD, SAMPLE_CATEGORY.Unknown.name());
            }
            newRows.add(map);
        }

        return newRows;
    }
}
