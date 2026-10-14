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

public class IACUCProject
{
    private Integer _project;
    private String _protocol;
    private String _account;
    private String _name;
    private String _title;
    private Integer _investigatorid;

    public Integer getProject()
    {
        return _project;
    }

    public void setProject(Integer project)
    {
        _project = project;
    }

    public String getProtocol()
    {
        return _protocol;
    }

    public void setProtocol(String protocol)
    {
        _protocol = protocol;
    }

    public String getAccount()
    {
        return _account;
    }

    public void setAccount(String account)
    {
        _account = account;
    }

    public String getName()
    {
        return _name;
    }

    public void setName(String name)
    {
        _name = name;
    }

    public String getTitle()
    {
        return _title;
    }

    public void setTitle(String title)
    {
        _title = title;
    }

    public Integer getInvestigatorid()
    {
        return _investigatorid;
    }

    public void setInvestigatorid(Integer investigatorid)
    {
        _investigatorid = investigatorid;
    }
}
