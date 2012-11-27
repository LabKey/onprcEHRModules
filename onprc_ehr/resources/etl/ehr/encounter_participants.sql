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
    null as userid,
    t.role,
    t.procedure_id,
    (cast(t.procedure_id as varchar(38)) + '_' + t.role) as objectid,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
	  else
	   rt.Initials
    END as username

FROM (

SELECT
    p.pathologist as userId,
    'Pathologist' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.pathologist) > 0

UNION ALL

SELECT
    p.prosector1 as userId,
    'Prosector1' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.prosector1) > 0

UNION ALL

SELECT
    p.prosector2 as userId,
    'Prosector2' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.prosector2) > 0

UNION ALL

SELECT
    p.prosector3 as userId,
    'Prosector3' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.prosector3) > 0

UNION ALL

SELECT
    p.pathologist as userId,
    'Pathologist' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.pathologist) > 0

UNION ALL

SELECT
    p.prosector1 as userId,
    'Prosector1' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.prosector1) > 0

UNION ALL

SELECT
    p.prosector2 as userId,
    'Prosector2' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.prosector2) > 0

UNION ALL

SELECT
    p.prosector3 as userId,
    'Prosector3' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.prosector3) > 0

) t

left join Ref_Technicians Rt on (t.userId = Rt.ID)

where t.rowversion > ?