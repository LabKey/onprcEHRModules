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
		rpi.ProjectID,
		rtrim(ltrim(lower(Rpi.IACUCCode))) as protocol,
		rtrim(ltrim(Rpi.Title)) as title,
		pi.InvestigatorID,
		(ri.LastName + ', ' + ri.FirstName) as inves,
		Rpi.StartDate as approve,
		Rpi.EndDate,
		s1.Value as USDA_Level,
		Rpi.eIACUCNum as external_id,
		Rpi.IBCApprovalNum as ibc_approval_num,
		Rpi.IBCApprovalRequired as ibc_approval_required,
		Rpi.DateCreated as created,
		S2.Value as Project_Type
	From Sys_Parameters s1, Sys_Parameters s2,
		Ref_ProjectsIACUC rpi
--			left join Ref_IACUCParentChildren ipc on rpi.ProjectID = ipc.ProjectChildID --ipc.ProjectParentID
			left join Ref_IACUCParentChildren ipc on (rpi.ProjectID = ipc.ProjectParentID
				and ipc.ProjectChildID = ipc.ProjectParentID)
			left join Ref_ProjInvest pi on (pi.ProjectID = rpi.ProjectID AND pi.DateDisabled is null and pi.PIFlag = 1)
			left join Ref_Investigator ri on ri.InvestigatorID = pi.investigatorid
	where ipc.DateDisabled is null
		and rpi.USDALevel = s1.Flag
		and s1.Field = 'USDALevel'
		and rpi.projecttype = s2.Flag
		and s2.Field = 'ProjectType'

AND rpi.ts > ?


