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
	--IDKey as IDKey  ,
	cast(AnimalID as nvarchar(4000)) as Id,
	GivenDate as date,
	RemoveDate as enddate,
	t.ToyCode as ToyCode,      ------ Ref_Snomed
	s.description as toyCodeMeaning,

	toy.ToyType as type,
	Reason,
	Remarks as Remark,
	t.objectid,
	t.ts as rowversion

From Af_Toys t
left join ref_snomed s ON (s.SnomedCode = t.ToyCode)

left join ref_toys toy ON (toy.ToyCode = t.ToyCode)

where t.ts > ?