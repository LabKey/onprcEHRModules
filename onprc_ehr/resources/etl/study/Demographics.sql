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
Select
	cast(AnimalID as varchar) as Id,
	--Species as Species,		----- Ref_Species
	sp.CommonName as Species,

	--Sex as SexCode  ,			---- Ref_Sex
	rs.Value AS Gender,

	--afq.CageID as CageID ,		----- Ref_RowCage
	--l2.Location as CurrentLocation,
	--rtrim(r2.row) + '-' + convert(char(2), r2.Cage) As CurrentCage,
	--TransferDate as TransferDate ,

	BirthDate as Birth,
	DeathDate as Death,

	--TODO: what are these?
	BirthFlag as BirthFlagInt  ,
	s2.Value as BirthFlag  ,
	DeathFlag as DeathFlagInt,
	s1.Value as DeathFlag,

	--TODO: most of these should get moved into study.notes
	ReproImpair as ReproImpair ,
	ReproImpairDate as ReproImpairDate ,
	BreedingFlag as BreedingFlag  ,
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

WHERE afq.ts > ?