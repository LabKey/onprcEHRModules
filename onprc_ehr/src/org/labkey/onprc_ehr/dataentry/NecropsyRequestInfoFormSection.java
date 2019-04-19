package org.labkey.onprc_ehr.dataentry;

import org.json.JSONObject;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.RequestFormSection;

public class NecropsyRequestInfoFormSection extends RequestFormSection
{
    protected Integer maxItemsPerColumn = 3;

    @Override
    public JSONObject toJSON(DataEntryFormContext ctx, boolean includeFormElements) {
        JSONObject ret = super.toJSON(ctx, includeFormElements);

        if ( maxItemsPerColumn != null ) {
            // Make the form appear in two columns
            JSONObject formConfig = new JSONObject(ret.get("formConfig"));
            formConfig.put("maxItemsPerCol", maxItemsPerColumn);
            ret.put("formConfig", formConfig);
        }

        return ret;
    }
}