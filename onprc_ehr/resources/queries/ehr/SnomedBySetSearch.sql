
---- Created: 12-15-2017  R.Blasa

PARAMETERS(SNOMEDCODE VARCHAR, STARTDATE TIMESTAMP, ENDDATE TIMESTAMP)


SELECT
  t1.Id,
  e.date,
  e.caseno,
  t1.type,
  t1.sort_order,
  t1.codes,
  t1.codesMeaning,
  t1.meaning,
   e.taskid
FROM (
SELECT

e.Id,
e.recordid,
e.sort_order,
e.parentid,
group_concat(DISTINCT e.type) as type,
group_concat(e.codeWithSort, chr(10)) as codes,
group_concat(e.codeMeaning, chr(10)) as codesMeaning,
group_concat(e.meaning, chr(10)) as meaning

FROM (

SELECT
  pd.Id,
  pd.date,
  'Diagnosis' as type,
  --e.objectid,
  --e.caseno,
  s.recordid,
  pd.sort_order,
  pd.parentid,
  cast(s.codeWithSort as varchar) as codeWithSort,
  s.code,
  sno.meaning,
  cast((cast(s.sort as varchar(10)) || cast(': ' as varchar(2)) || sno.meaning || ' (' || s.code || ')') as varchar(2000)) as codeMeaning

FROM ehr.snomed_tags s
JOIN study.pathologyDiagnoses pd ON (s.recordid = pd.objectid And s.code.code = rtrim(snomedCode))
JOIN ehr_lookups.snomed sno ON (s.code = sno.code)

   UNION ALL

SELECT
  pd.Id,
  pd.date,
  'Histology' as type,
  --e.objectid,
  --e.caseno,
  s.recordid,
  pd.formSort as sort_order,
  pd.parentid,
  cast(s.codeWithSort as varchar) as codeWithSort,
  s.code,
  sno.meaning,
  cast((cast(s.sort as varchar(10)) || cast(': ' as varchar(2)) || sno.meaning || ' (' || s.code || ')') as varchar(2000)) as codeMeaning

FROM ehr.snomed_tags s
JOIN study.histology pd ON (s.recordid = pd.objectid And s.code.code = rtrim(snomedCode))
JOIN ehr_lookups.snomed sno ON (s.code = sno.code)

) e

GROUP BY e.Id, e.recordid, e.parentid, e.sort_order

) t1

JOIN study.encounters e ON (e.Id = t1.Id AND e.objectid = t1.parentid And (e.date < ENDDATE and e.date >= STARTDATE))
