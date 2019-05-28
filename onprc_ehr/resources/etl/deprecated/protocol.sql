/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
		--rpi.ProjectID,
-- 		case
-- 			when Rpi.eIACUCNum is null OR datalength(rtrim(ltrim(Rpi.eIACUCNum))) = 0 then rtrim(ltrim(Rpi.IACUCCode))
-- 			else rtrim(ltrim(Rpi.eIACUCNum))
-- 		end as protocol,
		rtrim(ltrim(Rpi.IACUCCode)) as protocol,
		rtrim(ltrim(Rpi.Title)) as title,

		--(select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri.firstname and i.lastname = ri.lastname group by i.LastName, i.firstname having count(*) <= 1) as investigatorId,
    CASE
      WHEN pi2.InvestigatorID IS NULL THEN (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri.firstname and i.lastname = ri.lastname group by i.LastName, i.firstname having count(*) <= 1)
      ELSE (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri2.firstname and i.lastname = ri2.lastname group by i.LastName, i.firstname having count(*) <= 1)
    END as investigatorId,
		--(ri.LastName + ', ' + ri.FirstName) as inves,

        --i think this is the last yearly approval
		--rpi.IACUCApprovalDate as approve,
		rpi.OriginalApprovalDate as approve,
		coalesce(rpi.dateDisabled, Rpi.EndDate) as enddate,
		s1.Value as USDA_Level,
		Rpi.eIACUCNum as external_id,
		Rpi.IBCApprovalNum as ibc_approval_num,
		Rpi.IBCApprovalRequired as ibc_approval_required,
		Rpi.DateCreated as created,
		--S2.Value as Project_Type,
		rpi.objectid
	From Ref_ProjectsIACUC rpi
    left join Ref_IACUCParentChildren ipc on (rpi.ProjectID = ipc.ProjectParentID and ipc.ProjectChildID = ipc.ProjectParentID and ipc.DateDisabled is null)

    left join Ref_ProjInvest pi on (pi.ProjectID = rpi.ProjectID AND pi.DateDisabled is null and pi.PIFlag = 1 and pi.InvestigatorID != 0)
    left join Ref_Investigator ri on ri.InvestigatorID = pi.investigatorid

    left join Ref_ProjInvest pi2 on (pi2.ProjectID = rpi.ProjectID AND pi2.DateDisabled is null and pi2.PIFlag = 2 and pi2.investigatorid != 0)
    left join Ref_Investigator ri2 on (ri2.InvestigatorID = pi2.investigatorid)

    left join Sys_Parameters s1 on (rpi.USDALevel = s1.Flag and s1.Field = 'USDALevel')
    left join Sys_Parameters s2 on (rpi.projecttype = s2.Flag and s2.Field = 'ProjectType')
	where rpi.datedisabled is null and rpi.projectid = ipc.ProjectParentID

    AND (rpi.ts > ? OR ipc.ts > ? or pi.ts > ? or ri.ts > ?)

--also include any project missing from the parent/child table
UNION ALL

select
		--rpi.ProjectID,
-- 		case
-- 			when Rpi.eIACUCNum is null OR datalength(rtrim(ltrim(Rpi.eIACUCNum))) = 0 then rtrim(ltrim(Rpi.IACUCCode))
-- 			else rtrim(ltrim(Rpi.eIACUCNum))
-- 		end as protocol,
		rtrim(ltrim(Rpi.IACUCCode)) as protocol,
		rtrim(ltrim(Rpi.Title)) as title,

		--(select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri.firstname and i.lastname = ri.lastname group by i.LastName, i.firstname having count(*) <= 1) as investigatorId,
    CASE
      WHEN pi2.InvestigatorID IS NULL THEN (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri.firstname and i.lastname = ri.lastname group by i.LastName, i.firstname having count(*) <= 1)
      ELSE (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri2.firstname and i.lastname = ri2.lastname group by i.LastName, i.firstname having count(*) <= 1)
    END as investigatorId,

		--(ri.LastName + ', ' + ri.FirstName) as inves,

		--i think this is the last yearly approval
		--rpi.IACUCApprovalDate as approve,
		rpi.OriginalApprovalDate as approve,
		coalesce(rpi.dateDisabled, Rpi.EndDate) as enddate,
		s1.Value as USDA_Level,
		Rpi.eIACUCNum as external_id,
		Rpi.IBCApprovalNum as ibc_approval_num,
		Rpi.IBCApprovalRequired as ibc_approval_required,
		Rpi.DateCreated as created,
		--S2.Value as Project_Type,
		rpi.objectid
	From Ref_ProjectsIACUC rpi
    left join Ref_IACUCParentChildren pc ON (rpi.ProjectID = pc.ProjectChildID)
    left join Ref_IACUCParentChildren pc2 ON (rpi.ProjectID = pc.ProjectParentID)

    left join Ref_ProjInvest pi on (pi.ProjectID = rpi.ProjectID AND pi.DateDisabled is null and pi.PIFlag = 1 and pi.InvestigatorID != 0)
    left join Ref_Investigator ri on (ri.InvestigatorID = pi.investigatorid)

    left join Ref_ProjInvest pi2 on (pi2.ProjectID = rpi.ProjectID AND pi2.DateDisabled is null and pi2.PIFlag = 2 and pi2.investigatorid != 0)
    left join Ref_Investigator ri2 on (ri2.InvestigatorID = pi2.investigatorid)

    left join Sys_Parameters s1 on (rpi.USDALevel = s1.Flag and s1.Field = 'USDALevel')
    left join Sys_Parameters s2 on (rpi.projecttype = s2.Flag and s2.Field = 'ProjectType')
	where pc.IDKey is null and pc2.IDKey is null

    AND (rpi.ts > ? OR pc.ts > ? OR pc2.ts > ? or pi.ts > ? or ri.ts > ?)