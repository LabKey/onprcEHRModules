/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
INSERT INTO labkey.onprc_ehr.investigators (firstname,lastName,position,address,city,state,country,zip,phoneNumber, investigatorType,emailAddress,dateCreated,dateDisabled,division,objectid)
Select
	rtrim(ltrim(firstname)) as FirstName,
    rtrim(ltrim(LastName)) as LastName,
	Position,
	Address,
	City,
	State,
	Country,
	ZIP,
	PhoneNumber,
	--InvestigatorType as InvestigatorTypeInt,
	s1.Value as InvestigatorType,
	EmailAddress,
	rinv.DateCreated,
	rinv.DateDisabled,
	--Division as DivisionInt,
	s2.Value as Division,
	rinv.objectid
From IRIS_Production.dbo.Ref_Investigator rinv
     left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Field = 'InvestigatorType'and s1.Flag = rinv.InvestigatorType)
     left join  IRIS_Production.dbo.Sys_Parameters s2 on (s2.Field = 'Division' and s2.Flag = rinv.Division)
WHERE rinv.objectid NOT IN (select objectid FROM labkey.onprc_ehr.investigators);

update onprc_ehr.investigators set firstName = null where firstName = '';