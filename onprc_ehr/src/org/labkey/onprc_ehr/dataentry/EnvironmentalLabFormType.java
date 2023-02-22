
/*
 * Copyright (c) 2016-2017 LabKey Corporation
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

        import org.labkey.api.ehr.dataentry.DataEntryFormContext;
        import org.labkey.api.ehr.dataentry.FormSection;
        import org.labkey.api.ehr.dataentry.TaskForm;
        import org.labkey.api.ehr.dataentry.TaskFormSection;
        import org.labkey.api.ehr.security.EHRLabworkEntryPermission;
        import org.labkey.api.view.template.ClientDependency;
        import org.labkey.api.module.Module;

        import java.util.Arrays;
        import java.util.List;

//Created: 9-9-2022  R.Blasa

        public class EnvironmentalLabFormType extends TaskForm
        {
        public static final String NAME = "Environmental Assessment";

        public EnvironmentalLabFormType(DataEntryFormContext ctx, Module owner)
        {
        super(ctx, owner, NAME, "Environmental Assessment", "Lab Results", Arrays.<FormSection>asList(
        new TaskFormSection(),
        new EnvironmentalFormSection()
        ));


        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/Env_Sanitation.js"));


        for (FormSection s : this.getFormSections())
        {
        s.addConfigSource("Environmental");

        }
      }


            @Override
            protected boolean canInsert()
            {
                if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRLabworkEntryPermission.class))
                    return false;

                return super.canInsert();
            }

}
