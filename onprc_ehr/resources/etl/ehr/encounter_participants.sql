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
SELECT
    null as userid,
    cast(AnimalId as nvarchar(4000)) as Id,
    t.role,
    t.procedure_id as parentid,
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
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as username

FROM (

SELECT
    p.pathologist as userId,
    p.animalid,
    'Pathologist' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.pathologist) > 0

UNION ALL

SELECT
    p.prosector1 as userId,
    p.animalid,
    'Prosector1' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.prosector1) > 0

UNION ALL

SELECT
    p.prosector2 as userId,
    p.animalid,
    'Prosector2' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.prosector2) > 0

UNION ALL

SELECT
    p.prosector3 as userId,
    p.animalid,
    'Prosector3' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Autopsy p
WHERE datalength(p.prosector3) > 0

UNION ALL

SELECT
    p.pathologist as userId,
    p.animalid,
    'Pathologist' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.pathologist) > 0

UNION ALL

SELECT
    p.prosector1 as userId,
    p.animalid,
    'Prosector1' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.prosector1) > 0

UNION ALL

SELECT
    p.prosector2 as userId,
    p.animalid,
    'Prosector2' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.prosector2) > 0

UNION ALL

SELECT
    p.prosector3 as userId,
    p.animalid,
    'Prosector3' as role,
    objectid as procedure_id,
    ts as rowversion

From Path_Biopsy p
WHERE datalength(p.prosector3) > 0

UNION ALL

SELECT
    s.surgeon as userId,
    s.animalid,
    'Surgeon' as role,
    objectid as procedure_id,
    ts as rowversion

From Sur_General s
WHERE datalength(s.surgeon) > 0

UNION ALL

SELECT
    s.Assistant as userId,
    s.animalid,
    'Assistant' as role,
    objectid as procedure_id,
    ts as rowversion

From Sur_General s
WHERE datalength(s.Assistant) > 0

UNION ALL

SELECT
    s.Anesthetist as userId,
    s.animalid,
    'Anesthetist' as role,
    objectid as procedure_id,
    ts as rowversion

From Sur_General s
WHERE datalength(s.Anesthetist) > 0

UNION ALL

SELECT
    s.InstrumentTech as userId,
    s.animalid,
    'Instrument Tech' as role,
    objectid as procedure_id,
    ts as rowversion

From Sur_General s
WHERE datalength(s.InstrumentTech) > 0

UNION ALL

SELECT
    s.Circulator as userId,
    s.animalid,
    'Circulator' as role,
    objectid as procedure_id,
    ts as rowversion

From Sur_General s
WHERE datalength(s.Circulator) > 0

UNION ALL

SELECT
  i.surgeon as userId,
  i.animalid,
  'Surgeon' as role,
  max(cast(objectid as varchar(38))) as procedure_id,
  max(ts) as rowversion

From Sur_Implants i
WHERE datalength(i.surgeon) > 0
GROUP BY i.AnimalId, i.Date, i.Surgeon

) t

left join Ref_Technicians Rt on (t.userId = Rt.ID)

where t.rowversion > ? and rt.lastname != ' none'