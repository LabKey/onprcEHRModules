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

import org.labkey.api.util.GUID;

public class PurchaseDraftForm
{
    private Integer _rowid;
    private Integer _owner;
    private String _content;
    private GUID _containerid;
    private boolean _toBeDeleted;

    public Integer getRowid()
    {
        return _rowid;
    }

    public void setRowid(Integer rowid)
    {
        _rowid = rowid;
    }

    public Integer getOwner()
    {
        return _owner;
    }

    public void setOwner(Integer owner)
    {
        _owner = owner;
    }

    public String getContent()
    {
        return _content;
    }

    public void setContent(String content)
    {
        _content = content;
    }

    public GUID getContainerid()
    {
        return _containerid;
    }

    public void setContainerid(GUID containerid)
    {
        _containerid = containerid;
    }

    public boolean isToBeDeleted()
    {
        return _toBeDeleted;
    }

    public void setToBeDeleted(boolean toBeDeleted)
    {
        _toBeDeleted = toBeDeleted;
    }
}
