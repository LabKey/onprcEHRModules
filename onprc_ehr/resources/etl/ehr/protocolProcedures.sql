/*
 * Copyright (c) 2012 LabKey Corporation
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
 SELECT
	--iacuc.ProjectID as ProjectID , --Ref_ProjectsIACUC
	rtrim(ltrim(lower(ri.IACUCCode))) as protocol,
	
	--iacuc.ProcedureID as ProcedureID  , --Ref_SurgProcedure
	(SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = s.procedureName) as procedureid,
	
	iacuc.ProcedureCount as allowed,
	iacuc.DateCreated as startdate,
	iacuc.objectid 

FROM IACUC_NHPSurgeries IACUC
left join Ref_SurgProcedure s on (iacuc.ProcedureID = s.ProcedureID)
left join Ref_ProjectsIACUC ri on (IACUC.ProjectID = ri.ProjectID) 
where IACUC.DateDisabled is null
and iacuc.ts > ?