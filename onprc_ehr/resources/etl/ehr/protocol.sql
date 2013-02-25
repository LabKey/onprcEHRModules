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
		--rpi.ProjectID,
-- 		case
-- 			when Rpi.eIACUCNum is null OR datalength(rtrim(ltrim(Rpi.eIACUCNum))) = 0 then rtrim(ltrim(Rpi.IACUCCode))
-- 			else rtrim(ltrim(Rpi.eIACUCNum))
-- 		end as protocol,
		rtrim(ltrim(Rpi.IACUCCode)) as protocol,
		rtrim(ltrim(Rpi.Title)) as title,

		(select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri.firstname and i.lastname = ri.lastname group by i.LastName, i.firstname having count(*) <= 1) as investigatorId,
		--(ri.LastName + ', ' + ri.FirstName) as inves,
		Rpi.StartDate as approve,
		Rpi.EndDate,
		s1.Value as USDA_Level,
		Rpi.eIACUCNum as external_id,
		Rpi.IBCApprovalNum as ibc_approval_num,
		Rpi.IBCApprovalRequired as ibc_approval_required,
		Rpi.DateCreated as created,
		S2.Value as Project_Type,
		rpi.objectid
	From Sys_Parameters s1, Sys_Parameters s2,
		Ref_ProjectsIACUC rpi
			left join Ref_IACUCParentChildren ipc on (rpi.ProjectID = ipc.ProjectParentID and ipc.ProjectChildID = ipc.ProjectParentID and ipc.DateDisabled is null)
			left join Ref_ProjInvest pi on (pi.ProjectID = rpi.ProjectID AND pi.DateDisabled is null and pi.PIFlag = 1)
			left join Ref_Investigator ri on ri.InvestigatorID = pi.investigatorid
	where ipc.DateDisabled is null
	    and rpi.datedisabled is null
		and rpi.USDALevel = s1.Flag
		and s1.Field = 'USDALevel'
		and rpi.projecttype = s2.Flag
		and s2.Field = 'ProjectType'
		and rpi.projectid = ipc.ProjectParentID

AND (rpi.ts > ? OR ipc.ts > ? or pi.ts > ? or ri.ts > ?)


