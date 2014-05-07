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
SELECT
 	cast(AnimalID as nvarchar(4000)) as Id,
	ConfirmationDate as date,

	cast(MaleId as nvarchar(4000)) as sire,
	EstDeliveryDate as EstDeliveryDate,

	(SELECT rowid FROM labkey.ehr_lookups.lookups l WHERE l.set_name = 'PregnancyConfirm' and l.value = s1.value) as ConfirmationType,
	--ConfirmationType as ConfirmationType,
	--s1.Value as ConfirmationType,

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


	--bm.ts as rowversion,
	bm.objectid

FROM Brd_PregnancyConfirm bm
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'PregnancyConfirm' and s1.Flag = ConfirmationType)
LEFT JOIN Ref_Technicians rt ON (bm.Technician = rt.ID)
LEFT JOIN Sys_parameters s2 ON (s2.Field = 'DepartmentCode' and s2.Flag = rt.DeptCode)

WHERE bm.ts > ?