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
--insert procedures, only if not already present
INSERT INTO labkey.ehr_lookups.procedures (name, category, active, major)
Select
	ProcedureName as name,
	'Surgery' as category,
	CASE
	  WHEN Status = 1 THEN 1
      ELSE 0
    END as active,					-- 1 = active, 0 = inactive
	--rsp.DisplayOrder,
	--Category as CategoryInt,
	CASE
	  WHEN s1.Value = 'Major Surgery' then 1
	  ELSE 0
    END as major
From IRIS_Production.dbo.Ref_SurgProcedure rsp
	left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Field = 'SurgeryCategory' and rsp.Category = s1.Flag)
	LEFT JOIN labkey.ehr_lookups.procedures p ON (rsp.ProcedureName = p.name)
	WHERE p.name IS NULL


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


--procedure comments
TRUNCATE TABLE labkey.ehr_lookups.procedure_default_comments;
INSERT INTO labkey.ehr_lookups."procedure_default_comments" (procedureid, comment)
Select
	--p0.ProcedureID,		--Ref_SurgProcedure
	(SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = r.procedureName) as procedureid,
	cast(coalesce(p0.LogText, '') as nvarchar(4000)) + cast(coalesce(p1.LogPage, '') as nvarchar(4000)) + cast(coalesce(p2.LogText, '') as nvarchar(4000)) + cast(coalesce(p3.LogText, '') as nvarchar(4000)) + cast(coalesce(p4.LogText, '') as nvarchar(4000)) + cast(coalesce(p5.LogText, '') as nvarchar(4000)) as Comment

From IRIS_Production.dbo.Ref_SurgLog p0
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure r on (p0.procedureid = r.procedureid)
LEFT JOIN IRIS_Production.dbo.Ref_SurgLog p1 ON (p0.ProcedureID = p1.ProcedureID AND p1.LogPage = 1)
LEFT JOIN IRIS_Production.dbo.Ref_SurgLog p2 ON (p0.ProcedureID = p2.ProcedureID AND p2.LogPage = 2)
LEFT JOIN IRIS_Production.dbo.Ref_SurgLog p3 ON (p0.ProcedureID = p3.ProcedureID AND p2.LogPage = 3)
LEFT JOIN IRIS_Production.dbo.Ref_SurgLog p4 ON (p0.ProcedureID = p4.ProcedureID AND p2.LogPage = 4)
LEFT JOIN IRIS_Production.dbo.Ref_SurgLog p5 ON (p0.ProcedureID = p5.ProcedureID AND p2.LogPage = 5)

WHERE p0.LogPage = 0


--procedure flags
TRUNCATE TABLE labkey.ehr_lookups.procedure_default_flags;
INSERT INTO labkey.ehr_lookups.procedure_default_flags (procedureId, flag, value)
Select
  (SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = r.procedureName) as procedureid,
  'BreedImpair' as flag,
  'Y' as value

FROM IRIS_Production.dbo.Ref_SurgProcedure r
WHERE BreedImpairFlag = 1;

INSERT INTO labkey.ehr_lookups.procedure_default_flags (procedureId, flag, value)
Select
  (SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = r.procedureName) as procedureid,
  'USDASurvival' as flag,
  'Y' as value

FROM IRIS_Production.dbo.Ref_SurgProcedure r
WHERE USDASurvivalFlag = 1;

INSERT INTO labkey.ehr_lookups.procedure_default_flags (procedureId, flag, value)
Select
  (SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = r.procedureName) as procedureid,
  'Vessel Surgery' as flag,
  'Y' as value

FROM IRIS_Production.dbo.Ref_SurgProcedure r
WHERE VesselID = 1;


--procedure charges
TRUNCATE TABLE labkey.ehr_lookups.procedure_default_charges;
INSERT INTO labkey.ehr_lookups.procedure_default_charges (procedureid, chargeid, quantity)
SELECT
(SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = procedurename) as procedureid,
--'PersonHours' as chargeid,
null as chargeId,
PersonHours as quantity
FROM IRIS_Production.dbo.Ref_SurgProcedure
WHERE PersonHours > 0;

TRUNCATE TABLE labkey.ehr_lookups.procedure_default_charges;
INSERT INTO labkey.ehr_lookups.procedure_default_charges (procedureid, chargeid, quantity)
SELECT
(SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = procedurename) as procedureid,
--'Comsumables' as chargeid,
null as chargeId,
Comsumables as quantity
FROM IRIS_Production.dbo.Ref_SurgProcedure
WHERE PersonHours > 0;


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



--procedure medications
TRUNCATE TABLE labkey.ehr_lookups.procedure_default_treatments;
INSERT INTO labkey.ehr_lookups.procedure_default_treatments (procedureid, code, dosage, dosage_units, route, frequency)
Select
	(SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = r.procedurename) as procedureid,
	Medication as code,
	rsm.Dose as dosage,
	s1.Value as dosage_units,
	--Route as RouteInt,
	s2.Value as Route,
	(SELECT rowid from labkey.ehr_lookups.treatment_frequency f WHERE f.meaning = s3.Value) as Frequency

From IRIS_Production.dbo.Ref_SurgMedications rsm
	left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Field = 'MedicationUnits' and s1.Flag = rsm.Units)
	left join IRIS_Production.dbo.Sys_Parameters s2 on (s2.Field = 'MedicationRoute' and s2.Flag = rsm.route)
	left join IRIS_Production.dbo.Sys_Parameters s3 on (s3.Field = 'MedicationFrequency' and s3.Flag = rsm.frequency)
	LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure r on (rsm.procedureid = r.procedureid);


--procedure_default_codes
TRUNCATE TABLE labkey.ehr_lookups.procedure_default_codes;
INSERT INTO labkey.ehr_lookups.procedure_default_codes (procedureid, sort_order, code)
Select
	(SELECT max(rowid) as rowid from labkey.ehr_lookups.procedures p WHERE p.name = p.name) as procedureid,
	s2.i as sort,
	s2.value as code

From IRIS_Production.dbo.Ref_SurgSnomed r
left join IRIS_Production.dbo.Ref_SurgProcedure p on (r.ProcedureID = p.ProcedureID)
cross apply IRIS_Production.dbo.fn_splitter(r.SnomedCodes, ',') s2
where s2.value is not null and s2.value != '';

TRUNCATE TABLE labkey.ehr_lookups.locations
INSERT INTO labkey.ehr_lookups.locations (location, area, buildingId, size, locationtype, housingcategory)
SELECT 
	t.Location,
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