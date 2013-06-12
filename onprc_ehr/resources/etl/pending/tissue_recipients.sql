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
insert into labkey.onprc_ehr.tissue_recipients (firstName, lastName, institution, title, affiliation, address, city, state, country, zip, phoneNumber, emailAddress,
                                                shipAddress, shipCity, shipState, shipCountry, shipZip, dateCreated, dateDisabled, investigatorId, objectid, container, createdby, created, modifiedby, modified)
  select
    rt.firstName,
    rt.lastName,
    rt.institution,
    rt.title,
--rt.affiliation,
    s1.Value as affiliation,
    rt.address,
    rt.city,
    rt.state,
    rt.country,
    rt.zip,
    rt.phoneNumber,

    null as emailAddress,

    rt.shipAddress,
    rt.shipCity,
    rt.shipState,
    rt.shipCountry,
    rt.shipZip,

    rt.establishdate as dateCreated,
    rt.InactiveDate as dateDisabled,

    (SELECT i.rowid from labkey.onprc_ehr.investigators i WHERE i.objectid = ri.objectid) as investigatorId,

    rt.objectid,
    (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
    (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
    CURRENT_TIMESTAMP as created,
    (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
    CURRENT_TIMESTAMP as modified
  from Ref_TissueRecipients rt
    left join Ref_Investigator ri on (rt.InvestigatorID = ri.InvestigatorID)
    LEFT JOIN Sys_Parameters s1 ON (field = 'TissueAffiliation' and Flag = affiliation)