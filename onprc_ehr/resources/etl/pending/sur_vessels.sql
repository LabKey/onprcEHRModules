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
SELECT
	g.AnimalID,
	g.Date,
	v.Vessel as code,
	s.Description as codeMeaning,
	v.Action as actionInt,
	s1.Value as action,
	v.Notes as remark,	
	v.objectid  
  
from Sur_vessels v
LEFT JOIN Sur_General g ON (v.SurgeryID = g.SurgeryID)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'VesselAction' AND s1.Flag = v.Action)
LEFT JOIN Sys_parameters s2 ON (s2.Field = 'VesselNotes' AND s2.Flag = v.Notes) 
left join ref_snomed s ON (s.SnomedCode = v.Vessel)