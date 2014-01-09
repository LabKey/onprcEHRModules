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

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class TreatmentsTaskFormSection extends SimpleFormSection
{
    private boolean _showAddTreatments;

    public TreatmentsTaskFormSection()
    {
        this(true);
    }

    public TreatmentsTaskFormSection(boolean showAddTreatments)
    {
        this(showAddTreatments, EHRService.FORM_SECTION_LOCATION.Body);
    }

    public TreatmentsTaskFormSection(boolean showAddTreatments, EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Drug Administration", "Medications/Diet", "ehr-gridpanel", location);
        setConfigSources(Collections.singletonList("Task"));

        setClientStoreClass("EHR.data.DrugAdministrationRunsClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/AddScheduledTreatmentsWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromSectionWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SedationWindow.js"));

        _showAddTreatments = showAddTreatments;
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        if (_showAddTreatments)
            defaultButtons.add(0, "ADDTREATMENTS");

        return defaultButtons;
    }
}
