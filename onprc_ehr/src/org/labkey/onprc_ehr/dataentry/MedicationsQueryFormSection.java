/*
 * Copyright (c) 2014-2015 LabKey Corporation
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

import org.labkey.api.ehr.dataentry.SingleQueryFormSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 2/1/14
 * Time: 1:28 PM
 */
public class MedicationsQueryFormSection extends SingleQueryFormSection
{
    public MedicationsQueryFormSection(String schema, String query, String label)
    {
        super(schema, query, label);

        addConfigSource("SingleQuery");

        setClientStoreClass("EHR.data.DrugAdministrationRunsClientStore");
        addClientDependency(ClientDependency.fromPath("ehr/data/DrugAdministrationRunsClientStore.js"));
        addClientDependency(ClientDependency.fromPath("ehr/window/SedationWindow.js"));
        addClientDependency(ClientDependency.fromPath("onprc_ehr/window/ONPRC_AddScheduledTreatmentWindow.js"));
        addClientDependency(ClientDependency.fromPath("ehr/model/sources/SingleQuery.js"));
    }
}
