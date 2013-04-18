Select
y.projectID as project,
--r.IACUCCode as project,
--r.eIACUCNum,
y.CurrentYearStartDate as start,
y.CurrentYearEndDate as endDate,
a.NumAnimalsAssigned as allowed,
CASE
  WHEN sp.commonname = 'Cynomolgus' THEN 'CYNOMOLGUS MACAQUE'
  WHEN sp.commonname = 'Rhesus' THEN 'RHESUS MACAQUE'
  WHEN sp.commonname = 'Japanese' THEN 'JAPANESE MACAQUE'
  ELSE sp.CommonName
END as species,
s.Value as gender,
y.objectid

from IACUC_NHPYearly y
join IACUC_NHPAnimals a on (y.NHPYearlyID = a.NHPYearlyID)
join ref_ProjectsIACUC r on (r.ProjectID = y.ProjectID)
left join ref_species sp on (sp.SpeciesCode = a.Species)
left join ref_sex s on (s.Flag = a.Sex)

where (y.DateDisabled is null and a.DateDisabled is Null) and  y.CurrentYearEndDate > '12/31/2012'
and (y.ts > ? OR a.ts > ? OR r.ts > ?)
