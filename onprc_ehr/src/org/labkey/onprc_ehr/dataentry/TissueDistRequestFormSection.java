
/*
 * Copyright (c) 2014-2018 LabKey Corporation
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

        import org.json.old.JSONObject;
        import org.labkey.api.ehr.EHRService;
        import org.labkey.api.ehr.dataentry.SimpleGridPanel;
        import org.labkey.api.ehr.dataentry.DataEntryFormContext;
        import org.labkey.api.view.template.ClientDependency;

        import java.util.List;

//  Created: 9-17-2021  R.Blasa

public class TissueDistRequestFormSection extends SimpleGridPanel
{
    public TissueDistRequestFormSection()
    {
        super("study", "tissueDistributions", "Tissue Distributions");
        setLocation(EHRService.FORM_SECTION_LOCATION.Tabs);
        setXtype("onprc_ehr-dragdropgridpanel");
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/CopyTissuesRequestWindow.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/DragDropGridPanel.js"));
    }
    //    Added: 6-26-2017  R.Blasa  Include tool bar at bottom grid
    @Override
    public JSONObject toJSON(DataEntryFormContext ctx, boolean includeFormElements)
    {
        JSONObject jsonObject = super.toJSON(ctx, includeFormElements);
        jsonObject.put("topAndBottomButtons", true);
        return jsonObject;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.add("COPY_TISSUES");

        return defaultButtons;
    }
}
