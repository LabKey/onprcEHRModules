/*
 * Copyright (c) 2016-2026 LabKey Corporation
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
package org.labkey.sla.model;

public class Investigator
{
    private Integer _rowid;
    private String _firstname;
    private String _lastname;

    public Integer getRowid()
    {
        return _rowid;
    }

    public void setRowid(Integer rowid)
    {
        _rowid = rowid;
    }

    public String getFirstname()
    {
        return _firstname;
    }

    public void setFirstname(String firstname)
    {
        _firstname = firstname;
    }

    public String getLastname()
    {
        return _lastname;
    }

    public void setLastname(String lastname)
    {
        _lastname = lastname;
    }
}
