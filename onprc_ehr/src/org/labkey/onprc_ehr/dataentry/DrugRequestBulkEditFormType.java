/*
 * Copyright (c) 2014-2016 LabKey Corporation
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

import org.labkey.api.ehr.dataentry.BulkEditFormType;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**

 */
public class DrugRequestBulkEditFormType extends BulkEditFormType
{
    public static final String NAME = "DrugBulkEdit";
    public DrugRequestBulkEditFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, "DrugBulkEdit", "Medication/Injection Requests", "Clinical", "lsid", Arrays.asList(
                new DrugAdministrationRequestFormSection()
        ));
    }
}
