/*
 * Copyright (c) 2013 LabKey Corporation
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

import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 9/5/13
 * Time: 12:43 PM
 */
public class PairingFormType extends TaskForm
{
    public static final String NAME = "Pairing Observations";

    public PairingFormType(Module owner)
    {
        super(owner, NAME, "Pairing Observations", "BSU", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleGridPanel("study", "pairings", "Pairing Observations")
        ));
    }
}
