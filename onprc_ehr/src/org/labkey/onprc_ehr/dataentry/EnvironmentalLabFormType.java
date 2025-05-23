
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
        import org.labkey.api.view.template.ClientDependency;
        import org.labkey.api.module.Module;
        import org.labkey.onprc_ehr.security.ONPRC_EHREnvironmentalPermission;

        import java.util.Arrays;
        import java.util.List;
        import java.util.ArrayList;

//Created: 9-9-2022  R.Blasa

        public class EnvironmentalLabFormType extends TaskForm
        {
        public static final String NAME = "Environmental_Assessment_CLS";

        public EnvironmentalLabFormType(DataEntryFormContext ctx, Module owner)
        {
            super(ctx, owner, NAME, "Environmental Assessment", "Lab Results", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new EnvironmentalFormSection()
            ));


                addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/Env_Sanitation.js"));

                addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/EnvironmentalRecords.js"));

                           //Added 5-9-2025 R. Blasa
                addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/BulkEnvironmental_CPL_Water_Window.js"));

            //Added 5-9-2025 R. Blasa
            addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/window/BulkEnvironmental_CPL_Contact_Window.js"));



                for  (FormSection s : getFormSections())
                {
                    s.addConfigSource("Environmental");
                }


      }

            @Override
            protected List<String> getButtonConfigs()
            {
                List<String> ret = super.getButtonConfigs();

                int idx = ret.indexOf("SUBMIT");
                assert idx > -1;
                ret.remove("SUBMIT");
                if (idx > -1)
                    ret.add(idx, "ENV_RUN");
                else
                    ret.add("ENV_RUN");

                int idx2 = ret.indexOf("CLOSE");
                assert idx2 > -1;
                ret.remove("CLOSE");
                if (idx2 > -1)
                    ret.add(idx2, "ENV_CLOSE");
                else
                    ret.add("ENV_CLOSE");

                return ret;
            };


            //Added 1-19-2024 Blasa
            @Override
            protected List<String> getMoreActionButtonConfigs()
            {
                List<String> defaultButtons = new ArrayList<>();
                defaultButtons.addAll(super.getMoreActionButtonConfigs()) ;
                defaultButtons.add("ENV_CPL_Water_IMPORT");
                defaultButtons.add("ENV_CPL_Contact_IMPORT");

                return defaultButtons;
            }


            @Override
            protected boolean canInsert()
            {
                if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_EHREnvironmentalPermission.class))
                    return false;

                return super.canInsert();
            }

}
