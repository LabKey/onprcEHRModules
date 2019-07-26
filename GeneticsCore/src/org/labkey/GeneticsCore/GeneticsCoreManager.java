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

package org.labkey.GeneticsCore;

import org.labkey.api.query.Queryable;

public class GeneticsCoreManager
{
    private static final GeneticsCoreManager _instance = new GeneticsCoreManager();

    @Queryable
    public static final String DNA_DRAW_COLLECTED = "DNA Bank Blood Draw Collected";
    @Queryable
    public static final String DNA_DRAW_NEEDED = "DNA Bank Blood Draw Needed";
    @Queryable
    public static final String DNA_NOT_NEEDED = "DNA Bank Not Needed";
    @Queryable
    public static final String PARENTAGE_DRAW_COLLECTED = "Parentage Blood Draw Collected";
    @Queryable
    public static final String PARENTAGE_DRAW_NEEDED = "Parentage Blood Draw Needed";
    @Queryable
    public static final String PARENTAGE_NOT_NEEDED = "Parentage Not Needed";
    @Queryable
    public static final String MHC_DRAW_COLLECTED = "MHC Blood Draw Collected";
    @Queryable
    public static final String MHC_DRAW_NEEDED = "MHC Blood Draw Needed";
    @Queryable
    public static final String MHC_NOT_NEEDED = "MHC Typing Not Needed";

    private GeneticsCoreManager()
    {
        // prevent external construction with a private default constructor
    }

    public static GeneticsCoreManager get()
    {
        return _instance;
    }
}
