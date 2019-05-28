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
Select
	cast(afq.AnimalID as nvarchar(4000)) as Id,
	--Species as Species,		----- Ref_Species
	sp.CommonName as Species,

	--Sex as SexCode  ,			---- Ref_Sex
	CASE
	  WHEN rs.Value = 'Male' THEN 'm'
	  WHEN rs.Value = 'Female' THEN 'f'
	  WHEN rs.Value = 'Hermaphrodite' THEN 'h'
	  WHEN rs.Value = 'Unknown' THEN 'u'
	  ELSE rs.Value
    END AS Gender,

    CASE
        WHEN (gr.DamId IS NOT NULL AND gr.DamId != '0') THEN cast(gr.DamId as nvarchar(4000))
		--WHEN c.DamId != '0' THEN cast(c.DamId as nvarchar(4000))
		WHEN b.MotherID != '0' THEN cast(b.MotherId as nvarchar(4000))
		ELSE NULL
	END as dam,
    --b.MotherID,

    CASE
        WHEN (gr.sireId IS NOT NULL AND gr.SireId != '0') THEN cast(gr.SireId as nvarchar(4000))
		--WHEN c.SireId != '0' THEN cast(c.SireId as nvarchar(4000))
		WHEN b.FatherID != '0' THEN cast(b.FatherId as nvarchar(4000))
		ELSE NULL
	END as sire,
	--b.FatherID,

	--l2.Location as room,
	--rtrim(r2.row) + convert(char(2), r2.Cage) As cage,

	afq.BirthDate as Birth,

	afq.DeathDate as Death,

	CASE
	  WHEN s1.Value IS NULL THEN null
	  WHEN s1.value = 'Dead' THEN 'Dead'
	  WHEN s1.value = 'Live' THEN 'Alive'
      WHEN s1.value = 'Sold' THEN 'Shipped'
      else s1.value
    END as calculated_status,
    COALESCE(t.geographic_origin, aq.geographic_origin) as geographic_origin,

	--TODO: most of these should get moved into study.notes
	PregnancyDate as PregnancyDate ,
	Toys as Toys  ,

	--NOTE: these are just calculated on demand, so we dont cache in demographics.
	--TODO: need to verify we are capturing all of them from their associated tables.
	--AcquiDate as AcquiDate,
	--DepartureDate as DepartureDate ,
	--Assigned as Assigned  ,          ------ Flag > 0 Numeric count of assigned projects , Flag = 0 Not Assigned
	--LastTBTestdate as LastTBTestdate  ,

	afq.objectid
	--afq.ts as rowversion

From Af_Qrf afq
left join Sys_Parameters s1 on (afq.Deathflag = s1.Flag And s1.Field = 'DeathFlag')
left join Sys_Parameters s2 on (afq.BirthFlag = s2.Flag and s2.Field = 'BirthFlag')
left join Ref_RowCage r2 on  (r2.CageID = afq.CageID)
left join Ref_Location l2 on (r2.LocationID = l2.LocationId)
left join Ref_SEX rs ON (rs.Flag = afq.Sex)
left join Ref_Species sp ON (sp.SpeciesCode = afq.Species)
left join Ref_RowCage rc ON (rc.CageID = afq.CageID)
-- left join (
-- 	select
-- 	c.AnimalId,
-- 	max(c.DamId) as DamId,
-- 	max(c.SireId) as SireId,
-- 	max(c.birthdate) as birthdate,
-- 	max(cast(c.objectid as varchar(38))) as objectid,
-- 	max(r.Description) as description
-- 	from combinedrelationship c
-- 	left join refs r ON (r.field like '%calc%' AND r.Code = c.CalcType)
-- 	group by c.AnimalId
-- ) c ON (c.AnimalId = afq.AnimalID)
left join Af_Birth b ON (b.AnimalID = afq.AnimalID)
left join (
  SELECT
    gr.animalid,
    max(gr.sireid) as sireid,
    max(gr.damid) as damid,
    max(gr.ts) as ts
  FROM Geneticrelationship gr
  GROUP BY gr.animalid
) gr ON (gr.animalid = afq.animalid)

left JOIN (

select
    q.AnimalID,
    --labkey.core.group_concat_d(a.PoolCode, ',') as codes,
    CASE
        WHEN q.Species = 291 THEN 'Japan'
        WHEN q.Species = 305 AND count(distinct a.PoolCode) = 1 AND max(a.PoolCode) = 1052 THEN 'China'
        WHEN q.Species = 305 AND count(distinct a.PoolCode) = 1 AND max(a.PoolCode) = 1053 THEN 'Hybrid (China / India)'
        WHEN q.Species = 305 AND count(distinct a.PoolCode) = 1 AND max(a.PoolCode) = 1050 THEN 'India'
        else null
    END as geographic_origin,
    MAX(a.ts) as ts
from Af_QRF q
LEFT JOIN af_pool a ON (q.AnimalID = a.AnimalID AND a.poolcode in (1050,1052,1053) AND q.Species = 305 AND coalesce(a.DateReleased, CURRENT_TIMESTAMP) >= CURRENT_TIMESTAMP)
GROUP BY q.AnimalID, q.Species

) t ON (t.animalid = cast(afq.animalid AS nvarchar(4000)))

LEFT JOIN (
  select
    AnimalID,
    max(RefIs.GeographicName) as geographic_origin,
    max(afc.ts) as maxTs
  from Af_Acquisition afc
  LEFT JOIN Ref_IsisGeographic RefIs ON (Afc.GeographicOrigin = RefIs.GeographicCode)
  WHERE afc.GeographicOrigin > 0
  GROUP BY afc.AnimalId
) aq ON (t.animalid = cast(aq.animalid AS nvarchar(4000)))

WHERE (afq.ts > ? or b.ts > ? or t.ts > ? or gr.ts > ? or aq.maxTs > ?)