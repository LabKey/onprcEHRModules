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
package org.labkey.onprc_ehr.query;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;

/**
 * User: bimber
 * Date: 10/28/13
 * Time: 11:35 AM
 */
public class ClinicalRemarkDisplayColumn extends DataColumn
{
    private String _targetColName;

    public ClinicalRemarkDisplayColumn(ColumnInfo col, String targetColName)
    {
        super(col);
        _targetColName = targetColName;
    }
}
