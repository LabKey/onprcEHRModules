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
package org.labkey.onprc_ehr.dataentry;

import org.json.JSONObject;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

/**
 * User: bimber
 * Date: 12/28/13
 * Time: 3:56 PM
 */
public class PathologyDiagnosesFormSection extends PathologyFormSection
{
    public PathologyDiagnosesFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label);

        setClientStoreClass("EHR.data.PathologyDiagnosesStore");
        addClientDependency(ClientDependency.supplierFromPath("ehr/data/PathologyDiagnosesStore.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/grid/DragDropGridPanel.js"));
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/buttons/pathologyButtons.js"));
        setXtype("onprc_ehr-dragdropgridpanel");

        //Added: 10-31-2018  R.Blasa   address issues with text font size
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/Gross_Finding.css"));
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
    public List<String> getTbarButtons()
    {
        List<String> result = super.getTbarButtons();
        result.add("PATH_SAVE_DRAFT");
        return result;
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = new ArrayList<>();
        defaultButtons.addAll(super.getTbarMoreActionButtons());
        defaultButtons.add("RESET_SORT_ORDER");

        return defaultButtons;
    }
}
