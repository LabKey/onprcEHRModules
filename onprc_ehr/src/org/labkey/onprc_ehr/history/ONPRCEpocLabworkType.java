
/*
 * Copyright (c) 2013-2017 LabKey Corporation
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
package org.labkey.onprc_ehr.history;

        import org.labkey.api.ehr.history.SortingLabworkType;
        import org.labkey.api.module.Module;

//Created 7-26-2022  R.Blasa
        public class ONPRCEpocLabworkType extends SortingLabworkType
        {
        public ONPRCEpocLabworkType(Module module)
        {
        super("Epoc", "study", "EpocRefRange", "Epoc", module);
        _normalRangeField = "range";
        _normalRangeStatusField = "status";
        }

        @Override
        public boolean showPerformedBy()
        {
        return false;
        }
        }
