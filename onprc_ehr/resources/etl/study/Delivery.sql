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
Select
    cast(MotherID as nvarchar(4000)) as Id,
	Date,
	(SELECT rowid FROM labkey.ehr_lookups.lookups l WHERE l.set_name = 'DeliveryMode' and l.value = s1.value) as DeliveryType,
	--DeliveryType as DeliveryType,
    --s1.Value as DeliveryType,

    cast(InfantID as nvarchar(4000)) as Infant,
    case when fatherId = 0 then null else cast(FatherID as nvarchar(4000)) end as Sire,

	cast(NaturalMother as nvarchar(4000)) as NaturalMother,
	MultipleBirthsFlag ,

	case
	  WHEN rt.LastName = 'Unassigned' or rt.FirstName = 'Unassigned' THEN
        'Unassigned'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ', ' + rt.FirstName + ' (' + rt.Initials + ')'
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.FirstName) > 0 THEN
        rt.LastName + ', ' + rt.FirstName
	  WHEN datalength(rt.LastName) > 0 AND datalength(rt.Initials) > 0 THEN
        rt.LastName + ' (' + rt.Initials + ')'
      WHEN datalength(rt.Initials) = 0 OR rt.initials = ' ' OR rt.lastname = ' none' THEN
        null
	  else
	   rt.Initials
    END as performedBy,

	Remarks as remark,
	--IDKey,

	afd.objectid
	--afd.ts as rowversion

From Af_Delivery AfD
left join Sys_Parameters s1 on (Afd.DeliveryType = s1.Flag And s1.Field = 'DeliveryMode')
left join Ref_Technicians Rt on ( Rt.ID = AfD.Technician )
left join Sys_Parameters s2 on ( s2.field = 'Departmentcode'   And rt.Deptcode = s2.flag  )

where afd.ts > ?