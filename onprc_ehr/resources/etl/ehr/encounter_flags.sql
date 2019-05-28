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

select
id,
date,
flag,
value,
objectid as parentid,
(cast(t.objectid as varchar(38)) + '_' + t.flag) as objectid

FROM (

--Cln_AntibioticSensHeader
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
    
FROM Cln_AntibioticSensHeader cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_AntibioticSensHeader cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_AntibioticSensHeader cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_AntibioticSensHeader cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_AntibioticSensHeader cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_AntibioticSensHeader cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_AntibioticSensHeader cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_AntibioticSensHeader cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_AntibioticSensHeader

UNION ALL

--Cln_Biochemistry
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_Biochemistry cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_Biochemistry

UNION ALL

--Cln_IStat
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_IStat cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_IStat

UNION ALL

--Cln_OccultBlood
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_OccultBlood cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_OccultBlood

UNION ALL

--Cln_Hematology
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

--hematology manualDiff
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Manual Diff' as flag,
	'Y' as value,
	objectid

FROM Cln_Hematology cln
WHERE manualDiff = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_Hematology cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_Hematology

UNION ALL

--Cln_CerebralspinalFluid
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_CerebralspinalFluid cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_CerebralspinalFluid

UNION ALL

--Cln_MicrobiologyHeader
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_MicrobiologyHeader cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_MicrobiologyHeader

UNION ALL

--Cln_RareTestHeader
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_RareTestHeader cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_RareTestHeader

UNION ALL

--Cln_VirologyHeader
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_VirologyHeader cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_VirologyHeader

UNION ALL

--Cln_SerologyHeader
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_SerologyHeader cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_SerologyHeader

UNION ALL

--Cln_Urinalysis
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_Urinalysis cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_Urinalysis

UNION ALL

--Cln_Parasitology
SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Experimental' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE experimental = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'PreAssignment' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE PreAssignment = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Quarantine' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE Quarantine = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Pregnant' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE Pregnant = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Followup' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE Followup = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Presale' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE Presale = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Fasting' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE Fasting = 1 AND cln.ts  > ?

UNION ALL

SELECT
	cast(AnimalId as nvarchar(4000)) as Id,
	Date ,
	'Sedated' as flag,
	'Y' as value,
	objectid
FROM Cln_Parasitology cln
WHERE Sedated = 1 AND cln.ts  > ?
--EO Cln_Parasitology

) t

