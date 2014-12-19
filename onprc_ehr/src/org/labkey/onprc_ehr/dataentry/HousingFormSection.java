/*
 * Copyright (c) 2014 LabKey Corporation
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

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**

 */
public class HousingFormSection extends SimpleGridPanel
{
    public HousingFormSection(String schema, String query, String label)
    {
        super(schema, query, label);

        addClientDependency(ClientDependency.fromPath("ehr/window/RoomTransferWindow.js"));
        setClientStoreClass("EHR.data.HousingClientStore");
        addClientDependency(ClientDependency.fromPath("ehr/data/HousingClientStore.js"));
        addClientDependency(ClientDependency.fromPath("ehr/buttons/housingButtons.js"));
        setTemplateMode(TEMPLATE_MODE.NONE);
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> ret = super.getTbarButtons();
        ret.remove("COPYFROMSECTION");

        ret.add("ROOM_TRANSFER");
        ret.add("ROOM_LAYOUT");

        return ret;
    }

}
