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
select
  cast(c.AnimalId as varchar(4000)) as Id,
  c.Calculation_Date as date,
  null as enddate,
  cast(c.SireId as varchar(4000)) as parent,
  'Sire' as relationship,
  CASE
  WHEN c.CalcType = 0 THEN 'Observed' --Unknown or Observed Sire/Dam
  WHEN c.CalcType = 1 THEN 'Genetic' --Genetic Sire/Genetic Dam
  WHEN c.CalcType = 2 THEN 'Genetic' --Genetic Sire/Observed or Unknown Dam
  WHEN c.CalcType = 3 THEN 'Observed' --Observed or Unknown Sire/Genetic Dam
  WHEN c.CalcType = 4 THEN 'Excluded' --Observed Sire Excluded/Observed or Unknown Dam
  WHEN c.CalcType = 5 THEN 'Excluded' --Observed Sire Excluded/Genetic Dam
  WHEN c.CalcType = 6 THEN 'Unknown' --Observed or Unknown Sire/Observed Dam Excluded
  WHEN c.CalcType = 7 THEN 'Genetic' --Genetic Sire/Observed Dam Excluded
  WHEN c.CalcType = 8 THEN 'Excluded' --Both Observed Parents Excluded
  WHEN c.CalcType = 9 THEN 'Genetic' --Genetic Sire/Provisional Dam
  WHEN c.CalcType = 10 THEN 'Observed' --Observed or Unknown Sire/Provisional Dam
  WHEN c.CalcType = 11 THEN 'Provisional Genetic' --Provisional Sire/Genetic Dam
  WHEN c.CalcType = 12 THEN 'Provisional Genetic' --Provisional Sire/Observed or Unknown Dam
  WHEN c.CalcType = 13 THEN 'Provisional Genetic' --Provisional Sire/Provisional Dam
  END as method,
  (cast(c.objectid as varchar(38)) + '_sire') as objectid

from combinedrelationship c
where SireId != '0' and SireId is not null
AND c.ts > ?

UNION ALL

select
  cast(c.AnimalId as varchar(4000)) as Id,
  c.Calculation_Date as date,
  null as enddate,
  cast(c.DamId as varchar(4000)) as parent,
  'Dam' as relationship,
  CASE
  WHEN c.CalcType = 0 THEN 'Observed' --Unknown or Observed Sire/Dam
  WHEN c.CalcType = 1 THEN 'Genetic' --Genetic Sire/Genetic Dam
  WHEN c.CalcType = 2 THEN 'Observed' --Genetic Sire/Observed or Unknown Dam
  WHEN c.CalcType = 3 THEN 'Genetic' --Observed or Unknown Sire/Genetic Dam
  WHEN c.CalcType = 4 THEN 'Observed' --Observed Sire Excluded/Observed or Unknown Dam
  WHEN c.CalcType = 5 THEN 'Genetic' --Observed Sire Excluded/Genetic Dam
  WHEN c.CalcType = 6 THEN 'Excluded' --Observed or Unknown Sire/Observed Dam Excluded
  WHEN c.CalcType = 7 THEN 'Excluded' --Genetic Sire/Observed Dam Excluded
  WHEN c.CalcType = 8 THEN 'Excluded' --Both Observed Parents Excluded
  WHEN c.CalcType = 9 THEN 'Provisional Genetic' --Genetic Sire/Provisional Dam
  WHEN c.CalcType = 10 THEN 'Provisional Genetic' --Observed or Unknown Sire/Provisional Dam
  WHEN c.CalcType = 11 THEN 'Genetic' --Provisional Sire/Genetic Dam
  WHEN c.CalcType = 12 THEN 'Observed' --Provisional Sire/Observed or Unknown Dam
  WHEN c.CalcType = 13 THEN 'Provisional Genetic' --Provisional Sire/Provisional Dam
  END as method,
  (cast(c.objectid as varchar(38)) + '_dam') as objectid

from combinedrelationship c
where DamId != '0' and DamId is not null
AND c.ts > ?

UNION ALL

SELECT
  cast(Infant_ID as nvarchar(4000)) as Id,
  Foster_Start_Date as date,
  Foster_End_Date as enddate,
  cast(Foster_Mom as nvarchar(4000)) as parent,
  'Foster Dam' as relationship,
  'Observed' as method,
  cast(objectid as varchar(38)) as objectid
From Birth_FosterMom
WHERE ts > ?

UNION ALL

select
  cast(b.AnimalID as nvarchar(4000)) as Id,
  b.Date as date,
  null as enddate,
  cast(b.SurrogateMotherID as nvarchar(4000)) as parent,
  'Surrogate Dam' as relationship,
  'Other' as method,
  cast(objectid as varchar(38)) as objectid
from Af_Birth b
where SurrogateMotherID is not null
AND ts > ?