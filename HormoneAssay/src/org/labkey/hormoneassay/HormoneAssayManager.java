/*
 * Copyright (c) 2012 LabKey Corporation
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

package org.labkey.hormoneassay;

public class HormoneAssayManager
{
    private static final HormoneAssayManager _instance = new HormoneAssayManager();
    public static final String ASSAY_PROVIDER_NAME = "Hormone Assay";

    private HormoneAssayManager()
    {
        // prevent external construction with a private default constructor
    }

    public static HormoneAssayManager get()
    {
        return _instance;
    }
}