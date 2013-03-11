-- SELECT
--   cast(AnimalID as nvarchar(4000)) as Id,
--   Observation_date as date,
--   null as enddate,
--   SireId as parent,
--   'Sire' as relationship,
--   'Observed' as method,
--   null as objectid
-- FROM grip_prd.dbo.ObservedRelationship
-- WHERE SireId != '0' and SireId is not null
--
-- UNION ALL
--
-- SELECT
--   cast(AnimalID as nvarchar(4000)) as Id,
--   Observation_date as date,
--   null as enddate,
--   DamId as parent,
--   'Dam' as relationship,
--   'Observed' as method,
--   null as objectid
-- FROM grip_prd.dbo.ObservedRelationship
-- WHERE damid != '0' and damid is not null
--
-- UNION ALL
--
-- SELECT
--   cast(AnimalID as nvarchar(4000)) as Id,
--   Calculation_date as date,
--   null as enddate,
--   DamId as parent,
--   'Dam' as relationship,
--   'Genetic' as method,
--   null as objectid
-- FROM grip_prd.dbo.Geneticrelationship
-- WHERE damid != '0' and damid is not null
--
-- UNION ALL
--
-- SELECT
--   cast(AnimalID as nvarchar(4000)) as Id,
--   Calculation_date as date,
--   null as enddate,
--   SireId as parent,
--   'Sire' as relationship,
--   'Genetic' as method,
--   null as objectid
-- FROM grip_prd.dbo.Geneticrelationship
-- WHERE SireId != '0' and SireId is not null
--
-- UNION ALL

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
