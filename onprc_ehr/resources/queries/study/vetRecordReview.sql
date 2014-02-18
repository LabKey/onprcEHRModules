--remarks
SELECT
  '[Edit]' as editCol,
  c.Id,
  c.project,
  'SOAP' as recordType,
  c.category,
  c.date,
  c.description,
  c.remark,
  c.performedby,
  c.vetreviewdate,
  c.objectid,
  c.taskid,
  'clinRemarks' as queryName,
  CAST((c.lsid || '<>clinRemarks') as varchar(250)) as key
FROM study.clinRemarks c
WHERE c.vetreview IS NULL

UNION ALL

--observations
SELECT
  '[Edit]' as editCol,
  c.Id,
  c.project,
  'Observation' as recordType,
  c.category,
  c.date,
  observation as description,
  c.remark,
  c.performedby,
  c.vetreviewdate,
  c.objectid,
  c.taskid,
  'clinical_observations' as queryName,
  CAST((c.lsid || '<>clinical_observations') as varchar(250)) as key
FROM study.clinical_observations c
WHERE c.vetreview IS NULL

UNION ALL

--procedures
SELECT
  '[Edit]' as editCol,
  c.Id,
  c.project,
  'Procedure' as recordType,
  c.type as category,
  c.date,
  c.procedureid.name as description,
  c.remark,
  c.performedby,
  c.vetreviewdate,
  c.objectid,
  c.taskid,
  'encounters' as queryName,
  CAST((c.lsid || '<>encounters') as varchar(250)) as key
FROM study.encounters c
WHERE c.vetreview IS NULL AND c.type != 'Surgery'

UNION ALL

--drugs
SELECT
  '[Edit]' as editCol,
  c.Id,
  c.project,
  'Treatment' as recordType,
  c.category,
  c.date,
  (
    ifnull(c.code.meaning, '') || chr(10) ||
    ifnull(c.route, 'No route') || ', ' ||
    ifnull(c.amountAndVolume, '')
  ) as description,
  c.remark,
  c.performedby,
  c.vetreviewdate,
  c.objectid,
  c.taskid,
  'drug' as queryName,
  CAST((c.lsid || '<>drug') as varchar(250)) as key
FROM study.drug c
WHERE c.vetreview IS NULL

UNION ALL

--treatment order
SELECT
  '[Edit]' as editCol,
  c.Id,
  c.project,
  'Treatment Order' as recordType,
  c.category,
  c.date,
  (
    ifnull(c.code.meaning, '') || chr(10) ||
    ifnull(c.frequency.meaning, 'No frequency') || chr(10) ||
    ifnull(c.route, 'No route') || ', ' ||
    ifnull(c.amountAndVolume, '')
  ) as description,
  c.remark,
  c.performedby,
  c.vetreviewdate,
  c.objectid,
  c.taskid,
  'treatment_order' as queryName,
  CAST((c.lsid || '<>treatment_order') as varchar(250)) as key
FROM study.treatment_order c
WHERE c.vetreview IS NULL

UNION ALL

--case open
SELECT
  '[Edit]' as editCol,
  c.Id,
  c.project,
  'Case Open' as recordType,
  c.category,
  c.date,
  allProblemCategories as description,
  c.remark,
  c.performedby,
  c.vetreviewdate,
  c.objectid,
  c.taskid,
  'cases' as queryName,
  CAST((c.lsid || '<>cases') as varchar(250)) as key
FROM study.cases c
WHERE c.vetreview IS NULL

UNION ALL

--case open
SELECT
  '[Edit]' as editCol,
  c.Id,
  c.project,
  'Case Closed' as recordType,
  c.category,
  c.enddate as date,
  allProblemCategories as description,
  c.remark,
  c.performedby,
  c.vetreviewdate,
  c.objectid,
  c.taskid,
  'cases' as queryName,
  CAST((c.lsid || '<>cases') as varchar(250)) as key
FROM study.cases c
WHERE c.vetreview IS NULL and c.enddate IS NULL