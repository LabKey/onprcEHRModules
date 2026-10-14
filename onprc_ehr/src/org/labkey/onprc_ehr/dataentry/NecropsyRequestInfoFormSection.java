/*
 * Copyright (c) 2019-2026 LabKey Corporation
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
package org.labkey.onprc_ehr.dataentry;

import org.json.JSONObject;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.RequestFormSection;

public class NecropsyRequestInfoFormSection extends RequestFormSection
{
    protected Integer maxItemsPerColumn = 3;

    @Override
    public JSONObject toJSON(DataEntryFormContext ctx, boolean includeFormElements)
    {
        JSONObject ret = super.toJSON(ctx, includeFormElements);

        if (maxItemsPerColumn != null)
        {
            // Make the form appear in two columns
            JSONObject formConfig = new JSONObject(ret.get("formConfig").toString());
            formConfig.put("maxItemsPerCol", maxItemsPerColumn);
            ret.put("formConfig", formConfig);
        }

        return ret;
    }
}
