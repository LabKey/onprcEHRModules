SELECT
  e.id,
  e.date,
  s.objectid,
  s.set_number,
  s.sort,
  s.code,
  s.qualifier

FROM study.encounters e
JOIN ehr.snomed_tags s ON (e.id = s.id AND e.objectid = s.recordid)