SELECT

e.Id,
e.date,
e.caseno,
e.set_number,
group_concat(e.codeWithSort, chr(10)) as codes,
group_concat(e.codeMeaning, chr(10)) as codesMeaning,

FROM (

SELECT
  e.Id,
  e.date,
  e.objectid,
  e.caseno,
  s.set_number,
  cast(s.codeWithSort as varchar) as codeWithSort,
  s.code,
  sno.meaning,
  cast((cast(s.sort as varchar) || ': ' || sno.meaning || ' (' || s.code || ')') as varchar) as codeMeaning

FROM study.encounters e
JOIN ehr.snomed_tags s ON (e.id = s.id AND e.objectid = s.recordid)
JOIN ehr_lookups.snomed sno ON (s.code = sno.code)

) e

GROUP BY e.Id, e.date, e.objectid, e.caseno, e.set_number