/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
--source
-- TRUNCATE TABLE labkey.ehr_lookups.source;
-- INSERT into labkey.ehr_lookups.source (code, meaning, SourceCity, SourceState, SourceCountry)
-- 	select InstitutionCode, InstitutionName, InstitutionCity, InstitutionState, InstitutionCountry  from IRIS_Production.dbo.Ref_ISISInstitution;

--antibiotic subset
-- DELETE FROM labkey.ehr_lookups.snomed_subsets WHERE subset = 'Antibiotics';
-- INSERT INTO labkey.ehr_lookups.snomed_subsets (container, subset) VALUES ((SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC'), 'Antibiotics');
--
-- DELETE FROM labkey.ehr_lookups.snomed_subset_codes WHERE primaryCategory = 'Antibiotics';
-- DELETE FROM labkey.ehr_lookups.snomed_subset_codes WHERE primarycategory = 'Antibiotic';
-- INSERT INTO labkey.ehr_lookups.snomed_subset_codes (primaryCategory, code, container, modified, created, modifiedby, createdby)
-- Select
-- 'Antibiotics' as primaryCategory,
-- AntibioticCode as code,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as modified,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby
-- From IRIS_Production.dbo.Ref_Antibiotics WHERE DateDisabled IS NULL;

--buildings
-- TRUNCATE TABLE labkey.ehr_lookups.buildings;
-- INSERT INTO labkey.ehr_lookups.buildings (name, description)
-- SELECT buildingname, description FROM IRIS_Production.dbo.ref_building WHERE datedisabled IS NULL;

-- --species
-- TRUNCATE TABLE labkey.ehr_lookups.species;
-- INSERT INTO labkey.ehr_lookups.species (common, scientific_name)
-- Select max(commonname), max(latinname) From IRIS_Production.dbo.ref_species WHERE Active = 1 GROUP BY CommonName;
--
-- UPDATE labkey.ehr_lookups.species SET blood_draw_interval = 21;
--
-- UPDATE labkey.ehr_lookups.species SET blood_per_kg = 56;
-- UPDATE labkey.ehr_lookups.species SET blood_per_kg = 65 WHERE common = 'CYNOMOLGUS MACAQUE';
-- UPDATE labkey.ehr_lookups.species SET max_draw_pct = 0.125;

-- UPDATE labkey.ehr_lookups.species
-- SET cites_code = (SELECT min(SpeciesCode) FROM IRIS_Production.dbo.ref_species WHERE Active = 1 AND species.common = ref_species.CommonName)

--snomed
--TRUNCATE TABLE labkey.ehr_lookups.snomed;
INSERT INTO labkey.ehr_lookups.snomed (code, meaning, modified, created, modifiedby, createdby, container)
Select
ltrim(rtrim(SnomedCode)) as code,
max(description) as meaning,
getdate() as modified,
getdate() as created,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC')
From IRIS_Production.dbo.Ref_SnoMed
WHERE ltrim(rtrim(SnomedCode)) not in (select code from labkey.ehr_lookups.snomed WHERE container = (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC')) AND snomedcode != '---'
GROUP BY SnomedCode;


--gender
-- TRUNCATE TABLE labkey.ehr_lookups.gender_codes;
-- INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('f', 'Female', 'f');
-- INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('m', 'Male', 'm');
-- INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('h', 'Hermaphrodite', null);
-- INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('u', 'Unknown', null);

--toys subset
-- DELETE FROM labkey.ehr_lookups.snomed_subsets WHERE subset = 'Toys';
-- INSERT INTO labkey.ehr_lookups.snomed_subsets (subset) VALUES ('Toys');
--
-- DELETE FROM labkey.ehr_lookups.snomed_subset_codes WHERE primaryCategory = 'Toys';
-- INSERT INTO labkey.ehr_lookups.snomed_subset_codes (primaryCategory, code, container, modified, created, modifiedby, createdby)
-- Select
-- 'Toys' as primaryCategory,
-- ToyCode as code,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as modified,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby
-- From IRIS_Production.dbo.Ref_Toys WHERE ToyType = 1; --active only


--geographic origins
-- TRUNCATE TABLE labkey.ehr_lookups.geographic_origins;
-- INSERT INTO labkey.ehr_lookups.geographic_origins (meaning)
-- SELECT upper(ltrim(rtrim(GeographicName))) as meaning From IRIS_Production.dbo.Ref_ISISGeographic;



--treatment frequency
-- INSERT INTO labkey.ehr_lookups.treatment_frequency
-- (meaning)
-- SELECT
-- 	value
-- FROM IRIS_Production.dbo.Sys_Parameters s3
-- LEFT JOIN labkey.ehr_lookups.treatment_frequency f ON (s3.Value = f.meaning)
-- WHERE s3.Field = 'MedicationFrequency' AND f.meaning IS NULL;



-- TRUNCATE TABLE labkey.ehr_lookups.rooms;
-- INSERT INTO labkey.ehr_lookups.rooms (room, area, building, maxCages, housingtype, housingCondition, dateDisabled, sort_order)
-- SELECT
-- 	t.Location as room,
-- 	max(t.area) as area,
-- 	max(t.buildingName) as buildingName,
-- 	max(t.Size) as size,
-- 	max(t.LocationType) as locationtype,
-- 	max(t.LocationDefinition) as housingcategory,
-- 	min(t.datedisabled) as datedisabled,
-- 	min(sort_order) as sort_order
--
-- FROM (
-- Select
-- 	Location,
-- 	BuildingName as area,
-- 	BuildingName,
-- 	Size,
-- 	Status as active,
-- 	--s1.SearchKey as LocationTypeInt,
-- 	(select l.rowid FROM labkey.ehr_lookups.lookups l where l.set_name = s1.Field and l.value = s1.Value) as locationType,
-- 	--s1.Value as LocationType,
-- 	--s2.searchkey as LocationDefinitionInt
--
-- 	(select l.rowid FROM labkey.ehr_lookups.lookups l where l.set_name = s2.Field and l.value = s2.Value) as locationDefinition,
-- 	loc.DateDisabled,
-- 	loc.DisplayOrder as sort_order
-- 	--s2.Value as LocationDefinition,
-- 	--loc.DateCreated,
-- 	--loc.DateDisabled,
-- 	--loc.DisplayOrder,
-- 	--LockDownDate
--
-- From IRIS_Production.dbo.Ref_Location loc,
-- 	IRIS_Production.dbo.Sys_Parameters s1, IRIS_Production.dbo.Sys_Parameters s2, IRIS_Production.dbo.Ref_Building rb
-- Where s1.Field = 'LocationType'
-- 	and s1.Flag = loc.LocationType
-- 	and s2.Field = 'LocationDefinition'
-- 	and s2.Flag = loc.LocationDefinition
-- 	and rb.BuildingId = loc.BuildingID
-- 	--and loc.DateDisabled is null
--
-- UNION ALL
--
-- Select
-- 	Location,
-- 	BuildingName as area,
-- 	BuildingName,				--Ref_Building
-- 	Size,
-- 	Status,
-- 	(select l.rowid FROM labkey.ehr_lookups.lookups l where l.set_name = s1.Field and l.value = s1.Value) as locationType,
-- 	--s1.Value as LocationType,
-- 	--s2.searchkey as LocationDefinitionInt
--
-- 	(select l.rowid FROM labkey.ehr_lookups.lookups l where l.set_name = s2.Field and l.value = s2.Value) as locationDefinition,
-- 	--s2.Value as LocationDefinition,
-- 	rls.datedisabled,
-- 	rls.DisplayOrder as sort_order
--
-- From IRIS_Production.dbo.Ref_LocationSPF rls,
-- 	IRIS_Production.dbo.Sys_Parameters s1, IRIS_Production.dbo.Sys_Parameters s2, IRIS_Production.dbo.Ref_Building rb
-- Where s1.Field = 'LocationType'
-- 	and s1.Flag = rls.LocationType
-- 	and s2.Field = 'LocationDefinition'
-- 	and s2.Flag = rls.LocationDefinition
-- 	and rb.BuildingId = rls.BuildingID
-- 	--and rls.DateDisabled is null
--
-- ) t
-- GROUP BY t.location;

--cage types
-- TRUNCATE TABLE labkey.ehr_lookups.cage_type;
-- INSERT INTO labkey.ehr_lookups.cage_type (cagetype,sqft,cageslots)
--
-- Select
-- 	CASE
-- 		WHEN ct.CageTypeID = 19 THEN ct.CageDescription
-- 		ELSE CONVERT(VARCHAR, ct.CageDescription + ' - ') + CONVERT(VARCHAR, ct.CageSize)
-- 	END as cagetype,
-- 	--ugly
-- 	convert(float, rtrim(replace(replace(replace(cagesize, 'T', ''), 'O', ''), 'U', ''))) as cagesize,
-- 	CageSlots
-- From IRIS_Production.dbo.Ref_CageTypes ct
-- WHERE DateDisabled is null;

--areas
-- DELETE FROM labkey.ehr_lookups.areas;
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('ASA');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('ASB');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('NSI');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Research');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Harem');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Colony');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Colony Annex - South');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Colony Annex - North');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Shelters');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Corrals');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Kroc');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Catch 2');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Catch 5');
-- INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Catch 8');

-- TRUNCATE TABLE labkey.ehr_lookups.areas;
-- INSERT INTO labkey.ehr_lookups.areas (area, description)
-- SELECT buildingname, description FROM IRIS_Production.dbo.ref_building WHERE datedisabled IS NULL;


-- INSERT INTO labkey.ehr_lookups.divider_types (divider)
-- SELECT
--   s2.value
--   from IRIS_Production.dbo.sys_parameters s2
--   left join labkey.ehr_lookups.divider_types d ON (s2.value = d.divider)
--   where s2.field = 'CageDivider' and s2.DateDisabled IS NULL and d.divider is null;


-- DELETE FROM labkey.ehr_lookups.lookups where set_name = 'housing_reason'
-- and value not in (select value from iris_production.dbo.Sys_Parameters s where s.Field = 'TRANSFERREASON');

-- INSERT INTO labkey.ehr_lookups.lookups (set_name, value, sort_order)
-- select
-- 'housing_reason' as setname,
-- s.Value as value,
-- s.DisplayOrder as sort_order
--
-- from iris_production.dbo.Sys_Parameters s
-- where s.Field = 'TRANSFERREASON'
-- and s.value not in (select value from labkey.ehr_lookups.lookups WHERE set_name = 'housing_reason');

-- DELETE FROM labkey.ehr_lookups.lookups where set_name = 'birth_type'
-- and value not in (select value from iris_production.dbo.Sys_Parameters s where s.Field = 'BirthType');

-- INSERT INTO labkey.ehr_lookups.lookups (set_name, value, sort_order)
-- select
-- 'birth_type' as setname,
-- s.Value as value,
-- s.DisplayOrder as sort_order
--
-- from iris_production.dbo.Sys_Parameters s
-- where s.Field = 'BirthType'
-- and s.value not in (select value from labkey.ehr_lookups.lookups WHERE set_name = 'birth_type');

-- DELETE FROM labkey.ehr_lookups.lookups where set_name = 'birth_condition'
-- and value not in (select value from iris_production.dbo.Sys_Parameters s where s.Field = 'BirthCondition');
--
-- INSERT INTO labkey.ehr_lookups.lookups (set_name, value, sort_order)
-- select
-- 'birth_condition' as setname,
-- s.Value as value,
-- s.DisplayOrder as sort_order
--
-- from iris_production.dbo.Sys_Parameters s
-- where s.Field = 'BirthCondition'
-- and s.value not in (select value from labkey.ehr_lookups.lookups WHERE set_name = 'birth_condition');


-- DELETE FROM labkey.ehr_lookups.lookups where set_name = 'death_cause'
-- and value not in (select value from iris_production.dbo.Sys_Parameters s where s.Field = 'Deathcause');
--
-- INSERT INTO labkey.ehr_lookups.lookups (set_name, value, sort_order)
-- select
-- 'death_cause' as setname,
-- s.Value as value,
-- s.DisplayOrder as sort_order
--
-- from iris_production.dbo.Sys_Parameters s
-- where s.Field = 'Deathcause'
-- and s.value not in (select value from labkey.ehr_lookups.lookups WHERE set_name = 'death_cause');


-- DELETE FROM labkey.ehr_lookups.lookups where set_name = 'problem_list_category'
-- and value not in (select value from iris_production.dbo.Sys_Parameters s where s.Field = 'MasterProblemList');
--
-- INSERT INTO labkey.ehr_lookups.lookups (set_name, value, sort_order)
-- select
-- 'problem_list_category' as setname,
-- s.Value as value,
-- s.DisplayOrder as sort_order
--
-- from iris_production.dbo.Sys_Parameters s
-- where s.Field = 'MasterProblemList'
-- and s.value not in (select value from labkey.ehr_lookups.lookups WHERE set_name = 'problem_list_category');

-- TRUNCATE TABLE labkey.ehr_lookups.animal_condition;
-- INSERT INTO labkey.ehr_lookups.animal_condition (code, meaning, created, createdby, modified, modifiedby)
-- select
-- PoolCode as code,
-- Description as meaning,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
-- getdate() as modified,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby
-- from iris_production.dbo.ref_pool where (ShortDescription = 'Condition' or poolcode = 207) and DateDisabled is null and PoolCode != 203;

--append custom flags
-- insert into ehr_lookups.flag_values (category, value,code,datedisabled,objectid,container,created,createdby,modified,modifiedby)
-- select
-- 'Genetics' as category,
-- 'DNA Bank Blood Draw Collected' as value,
-- null as code,
-- null as datedisabled,
-- NEWID() as objectid,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
-- getdate() as modified,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby
--
-- WHERE NOT EXISTS (SELECT rowid FROM labkey.ehr_lookups.flag_values WHERE 'Genetics' = category AND 'DNA Bank Blood Draw Collected' = value);
--
-- insert into ehr_lookups.flag_values (category, value,code,datedisabled,objectid,container,created,createdby,modified,modifiedby)
-- select
-- 'Genetics' as category,
-- 'DNA Bank Blood Draw Needed' as value,
-- null as code,
-- null as datedisabled,
-- NEWID() as objectid,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
-- getdate() as modified,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby
--
-- WHERE NOT EXISTS (SELECT rowid FROM labkey.ehr_lookups.flag_values WHERE 'Genetics' = category AND 'DNA Bank Blood Draw Needed' = value);
--
-- insert into ehr_lookups.flag_values (category, value,code,datedisabled,objectid,container,created,createdby,modified,modifiedby)
-- select
-- 'Genetics' as category,
-- 'MHC Blood Draw Collected' as value,
-- null as code,
-- null as datedisabled,
-- NEWID() as objectid,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
-- getdate() as modified,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby
--
-- WHERE NOT EXISTS (SELECT rowid FROM labkey.ehr_lookups.flag_values WHERE 'Genetics' = category AND 'MHC Blood Draw Collected' = value);
--
-- insert into ehr_lookups.flag_values (category, value,code,datedisabled,objectid,container,created,createdby,modified,modifiedby)
-- select
-- 'Genetics' as category,
-- 'MHC Blood Draw Needed' as value,
-- null as code,
-- null as datedisabled,
-- NEWID() as objectid,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
-- getdate() as modified,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby
--
-- WHERE NOT EXISTS (SELECT rowid FROM labkey.ehr_lookups.flag_values WHERE 'Genetics' = category AND 'MHC Blood Draw Needed' = value);
--
-- insert into ehr_lookups.flag_values (category, value,code,datedisabled,objectid,container,created,createdby,modified,modifiedby)
-- select
-- 'Genetics' as category,
-- 'Parentage Blood Draw Collected' as value,
-- null as code,
-- null as datedisabled,
-- NEWID() as objectid,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
-- getdate() as modified,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby
--
-- WHERE NOT EXISTS (SELECT rowid FROM labkey.ehr_lookups.flag_values WHERE 'Genetics' = category AND 'Parentage Blood Draw Collected' = value);
--
-- insert into ehr_lookups.flag_values (category, value,code,datedisabled,objectid,container,created,createdby,modified,modifiedby)
-- select
-- 'Genetics' as category,
-- 'Parentage Blood Draw Needed' as value,
-- null as code,
-- null as datedisabled,
-- NEWID() as objectid,
-- (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
-- getdate() as created,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby,
-- getdate() as modified,
-- (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby
--
-- WHERE NOT EXISTS (SELECT rowid FROM labkey.ehr_lookups.flag_values WHERE 'Genetics' = category AND 'Parentage Blood Draw Needed' = value);