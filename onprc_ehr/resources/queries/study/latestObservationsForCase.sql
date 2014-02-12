SELECT
  o.Id,
  o.date,
  o.category,
  o.area,
  o.observation,
  o.remark,
  o.caseid,
  c.category as caseCategory,
  c.isActive as caseIsActive,
  o.taskid

FROM study.clinical_observations o
JOIN study.cases c ON (c.objectid = o.caseid)
WHERE (
  o.category IS NULL
  OR o.category NOT IN (javaConstant('org.labkey.ehr.EHRManager.OBS_REVIEWED'), javaConstant('org.labkey.ehr.EHRManager.VET_REVIEW'), javaConstant('org.labkey.ehr.EHRManager.VET_ATTENTION'))
)
AND o.taskid = (
  SELECT o2.taskid
  FROM study.clinical_observations o2
  WHERE o2.caseid = o.caseid AND o2.Id = o.Id AND o2.taskId is not null
  ORDER BY o2.date DESC LIMIT 1
)