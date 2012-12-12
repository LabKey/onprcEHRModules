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
left join ref_snomed121311 s ON (s.SnomedCode = v.Vessel)