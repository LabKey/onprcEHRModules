/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
  
select 
	--coalesce(i2.eIACUCNum, rtrim(ltrim(lower(i2.IACUCCode)))) as protocol,
	rtrim(ltrim(i2.IACUCCode)) as protocol,
	t.*

FROM (
 
select 

    Rpi.ProjectId as project,
    rpi.IACUCCode,
    rtrim(ltrim(Rpi.IACUCCode)) as name,
	coalesce ((select top 1
				ipc.projectparentid
				from Ref_ProjectsIACUC rpi2 join Ref_IACUCParentChildren ipc on (rpi2.ProjectID = ipc.ProjectParentID and ipc.datedisabled is null)
				where ipc.projectchildid = rpi.projectid order by ipc.datecreated desc), rpi.projectid) as protocolId,

  coalesce ((select max(rpi2.ts) as maxTs
       from Ref_ProjectsIACUC rpi2 join Ref_IACUCParentChildren ipc on (rpi2.ProjectID = ipc.ProjectParentID and ipc.datedisabled is null)
       where ipc.projectchildid = rpi.projectid), rpi.ts
  ) as maxTs,

	(select top 1 ohsuaccountnumber from Ref_ProjectAccounts rpa where rpi.projectid = rpa.ProjectID order by datecreated desc) as account,
	Rpi.Title,
	Rpi.StartDate,
	coalesce(rpi.dateDisabled, Rpi.EndDate) as enddate,
	CASE
	  WHEN pc2.InvestigatorID IS NULL THEN (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri.firstname and i.lastname = ri.lastname group by i.LastName, i.firstname having count(*) <= 1)
      ELSE (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri2.firstname and i.lastname = ri2.lastname group by i.LastName, i.firstname having count(*) <= 1)
    END as investigatorId,
	rpi.objectid,
	CASE
	  WHEN Rpi.IACUCCode LIKE '%0492%' THEN 0
	  ELSE 1
  END as research,

  CASE
    WHEN Rpi.IACUCCode = '0492-03' THEN 'U24'
    WHEN Rpi.IACUCCode = '0492-02' THEN 'U42'
    WHEN Rpi.IACUCCode = '0300' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0456' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = 'O833' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0095-50' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0689' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0794' THEN 'Center Resource'

    ELSE 'Research'
  END as use_category

From Ref_ProjectsIACUC rpi
	left join Ref_ProjInvest pc on (pc.ProjectID = rpi.ProjectID AND pc.DateDisabled is null and pc.PIFlag = 1 and pc.investigatorid != 0)
	left join Ref_Investigator ri on (ri.InvestigatorID = pc.investigatorid)

	left join Ref_ProjInvest pc2 on (pc2.ProjectID = rpi.ProjectID AND pc2.DateDisabled is null and pc2.PIFlag = 2 and pc2.investigatorid != 0)
	left join Ref_Investigator ri2 on (ri2.InvestigatorID = pc2.investigatorid)

WHERE (rpi.ts > ? or pc.ts > ? or ri.ts > ?)

) t

LEFT JOIN Ref_ProjectsIACUC i2 ON (i2.ProjectID = t.protocolId)
WHERE maxTs > ?
