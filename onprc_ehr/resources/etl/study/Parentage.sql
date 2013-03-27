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
 SELECT
  cast(AnimalID as nvarchar(4000)) as Id,
  Observation_date as date,
  null as enddate,
  SireId as parent,
  'Sire' as relationship,
  'Observed' as method,
  objectid 
FROM grip_prd.dbo.ObservedRelationship o
WHERE SireId != '0' and SireId is not null
and o.ts > ?

UNION ALL

SELECT
  cast(AnimalID as nvarchar(4000)) as Id,
  Observation_date as date,
  null as enddate,
  DamId as parent,
  'Dam' as relationship,
  'Observed' as method,
  objectid
FROM grip_prd.dbo.ObservedRelationship
WHERE damid != '0' and damid is not null
and ts > ?

UNION ALL

SELECT
  cast(AnimalID as nvarchar(4000)) as Id,
  Calculation_date as date,
  null as enddate,
  DamId as parent,
  'Dam' as relationship,
  'Genetic' as method,
  objectid
FROM grip_prd.dbo.Geneticrelationship
WHERE damid != '0' and damid is not null
and ts > ?

UNION ALL

SELECT
  cast(AnimalID as nvarchar(4000)) as Id,
  Calculation_date as date,
  null as enddate,
  SireId as parent,
  'Sire' as relationship,
  'Genetic' as method,
  objectid
FROM grip_prd.dbo.Geneticrelationship
WHERE SireId != '0' and SireId is not null
and ts > ?

UNION ALL

SELECT
	cast(Infant_ID as nvarchar(4000)) as Id,
	Foster_Start_Date as date,
	Foster_End_Date as enddate,
	cast(Foster_Mom as nvarchar(4000)) as parent,
    'Foster Mother' as relationship,	
    'Observed' as method, 	
	objectid

From iris_production.dbo.Birth_FosterMom
WHERE ts > ?
