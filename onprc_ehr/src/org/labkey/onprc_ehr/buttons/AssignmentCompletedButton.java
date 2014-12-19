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
package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

/**

 */
public class AssignmentCompletedButton extends MarkCompletedButton
{
    public AssignmentCompletedButton(Module owner)
    {
        super(owner, "study", "assignment", "End Assignments");

        setClientDependencies(ClientDependency.fromPath("onprc_ehr/window/MarkAssignmentCompletedWindow.js"));
    }

    @Override
    protected String getJsHandler(TableInfo ti)
    {
        return "ONPRC_EHR.window.MarkAssignmentCompletedWindow.buttonHandler(dataRegionName);";
    }
}
