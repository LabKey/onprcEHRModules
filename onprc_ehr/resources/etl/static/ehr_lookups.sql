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
--source
TRUNCATE TABLE labkey.ehr_lookups.source;
INSERT into labkey.ehr_lookups.source (code, meaning, SourceCity, SourceState, SourceCountry)
	select InstitutionCode, InstitutionName, InstitutionCity, InstitutionState, InstitutionCountry  from IRIS_Production.dbo.Ref_ISISInstitution;

--antibiotic subset
DELETE FROM labkey.ehr_lookups.snomed_subsets WHERE subset = 'Antibiotic';
INSERT INTO labkey.ehr_lookups.snomed_subsets (subset) VALUES ('Antibiotic');

DELETE FROM labkey.ehr_lookups.snomed_subset_codes WHERE primaryCategory = 'Antibiotic';
INSERT INTO labkey.ehr_lookups.snomed_subset_codes (primaryCategory, code, container, modified, created, modifiedby, createdby)
Select
'Antibiotic' as primaryCategory,
AntibioticCode as code,
(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
getdate() as modified,
getdate() as created,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby
From IRIS_Production.dbo.Ref_Antibiotics WHERE DateDisabled IS NULL;

--buildings
TRUNCATE TABLE labkey.ehr_lookups.buildings;
INSERT INTO labkey.ehr_lookups.buildings (name, description)
SELECT buildingname, description FROM IRIS_Production.dbo.ref_building WHERE datedisabled IS NULL;

--species
TRUNCATE TABLE labkey.ehr_lookups.species;
INSERT INTO labkey.ehr_lookups.species (common, scientific_name)
Select max(commonname), max(latinname) From IRIS_Production.dbo.ref_species WHERE Active = 1 GROUP BY CommonName;

UPDATE labkey.ehr_lookups.species SET blood_draw_interval = 21;

UPDATE labkey.ehr_lookups.species SET blood_per_kg = 56;
UPDATE labkey.ehr_lookups.species SET blood_per_kg = 65 WHERE common = 'CYNOMOLGUS MACAQUE';
UPDATE labkey.ehr_lookups.species SET max_draw_pct = 0.125;

--snomed
TRUNCATE TABLE labkey.ehr_lookups.full_snomed;
TRUNCATE TABLE labkey.ehr_lookups.snomed;
INSERT INTO labkey.ehr_lookups.snomed (code, meaning, modified, created, modifiedby, createdby)
Select
SnomedCode as code,
max(description) as meaning,
getdate() as modified,
getdate() as created,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby
From IRIS_Production.dbo.Ref_SnoMed
GROUP BY SnomedCode;


--gender
TRUNCATE TABLE labkey.ehr_lookups.gender_codes;
INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('f', 'Female', 'f');
INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('m', 'Male', 'm');
INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('h', 'Hermaphrodite', null);
INSERT INTO labkey.ehr_lookups.gender_codes (code, meaning, origgender) VALUES ('u', 'Unknown', null);

--toys subset
DELETE FROM labkey.ehr_lookups.snomed_subsets WHERE subset = 'Toys';
INSERT INTO labkey.ehr_lookups.snomed_subsets (subset) VALUES ('Toys');

DELETE FROM labkey.ehr_lookups.snomed_subset_codes WHERE primaryCategory = 'Toys';
INSERT INTO labkey.ehr_lookups.snomed_subset_codes (primaryCategory, code, container, modified, created, modifiedby, createdby)
Select
'Toys' as primaryCategory,
ToyCode as code,
(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container,
getdate() as modified,
getdate() as created,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
(SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby
From IRIS_Production.dbo.Ref_Toys WHERE ToyType = 1; --active only


--geographic origins
TRUNCATE TABLE labkey.ehr_lookups.geographic_origins;
INSERT INTO labkey.ehr_lookups.geographic_origins (meaning)
SELECT upper(GeographicName) as meaning From IRIS_Production.dbo.Ref_ISISGeographic;

--diet
DELETE FROM labkey.ehr_lookups.lookups WHERE set_name = 'Diet';
INSERT INTO labkey.ehr_lookups.lookups (set_name, value, created, date_disabled)
SELECT
   'Diet' as set_name,
	Description as value,
	StartDate as created,
	DisableDate as date_disabled
FROM IRIS_Production.dbo.ref_diet  ;


--treatment frequency
INSERT INTO labkey.ehr_lookups.treatment_frequency 
(meaning)
SELECT 
	value
FROM IRIS_Production.dbo.Sys_Parameters s3 
LEFT JOIN labkey.ehr_lookups.treatment_frequency f ON (s3.Value = f.meaning)
WHERE s3.Field = 'MedicationFrequency' AND f.meaning IS NULL;



TRUNCATE TABLE labkey.ehr_lookups.rooms
INSERT INTO labkey.ehr_lookups.rooms (room, area, building, maxCages, housingtype, housingCondition)
SELECT
	t.Location as room,
	t.area,
	t.BuildingID,
	t.Size,
	max(t.LocationTypeInt) as locationtype,
	max(t.LocationDefinitionInt) as housingcategory

FROM (
Select
	Location,
	null as area,
	BuildingID,
	Size,
	Status as active,
	LocationType as LocationTypeInt,
	--s1.Value as LocationType,
	LocationDefinition as LocationDefinitionInt
	--s2.Value as LocationDefinition,
	--loc.DateCreated,
	--loc.DateDisabled,
	--loc.DisplayOrder,
	--LockDownDate

From IRIS_Production.dbo.Ref_Location loc,
	IRIS_Production.dbo.Sys_Parameters s1, IRIS_Production.dbo.Sys_Parameters s2
Where s1.Field = 'LocationType'
	and s1.Flag = loc.LocationType
	and s2.Field = 'LocationDefinition'
	and s2.Flag = loc.LocationDefinition
	and loc.Status = 1

UNION ALL

Select
	Location,
	null as area,
	BuildingID,				--Ref_Building
	Size,
	Status,
	LocationType as LocationTypeInt,
	--s1.Value as LocationType,
	LocationDefinition as LocationDefinitionInt
	--s2.Value as LocationDefinition,

From IRIS_Production.dbo.Ref_LocationSPF rls,
	IRIS_Production.dbo.Sys_Parameters s1, IRIS_Production.dbo.Sys_Parameters s2
Where s1.Field = 'LocationType'
	and s1.Flag = rls.LocationType
	and s2.Field = 'LocationDefinition'
	and s2.Flag = rls.LocationDefinition
	and rls.Status = 1
	
) t 
GROUP BY t.location, t.area, t.buildingId, t.size;

--cage types
TRUNCATE TABLE labkey.ehr_lookups.cage_type;
INSERT INTO labkey.ehr_lookups.cage_type (cagetype,sqft,cageslots,MaxAnimalWeight)

Select
	CASE
		WHEN ct.CageTypeID = 19 THEN ct.CageDescription
		ELSE CONVERT(VARCHAR, ct.CageDescription + ' - ') + CONVERT(VARCHAR, ct.CageSize)
	END as cagetype,
	--ugly
	convert(float, rtrim(replace(replace(replace(cagesize, 'T', ''), 'O', ''), 'U', ''))) as cagesize,
	CageSlots,
	--CageCapacity,
	MaxAnimalSize
From IRIS_Production.dbo.Ref_CageTypes ct
WHERE DateDisabled is null;

--areas
DELETE FROM labkey.ehr_lookups.areas;
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('ASA');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('ASB');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('NSI');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Research');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Harem');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Colony');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Colony Annex - South');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Colony Annex - North');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Shelters');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Corrals');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Kroc');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Catch 2');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Catch 5');
INSERT INTO labkey.ehr_lookups.areas (area) VALUES ('Catch 8');