SELECT
  t.Id,
  max(t.date) as date,
  'Observations' as category,
  null as description,
  GROUP_CONCAT(CASE
    WHEN (t.category IS NOT NULL AND t.area IS NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.observation || t.remark) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.area IS NOT NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.area || ', ' || t.observation) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.observation IS NULL) THEN cast((t.category || t.remark) as varchar(1000))
    WHEN (t.category IS NULL AND t.observation IS NOT NULL) THEN cast((t.observation || t.remark) as varchar(1000))
    else t.remark
  END, chr(10)) as remark,
  max(t.performedby) as performedby

FROM (SELECT
  o.Id,
  o.date,
  o.dateOnly,
  o.taskId,
  CASE
    WHEN o.category = javaConstant('org.labkey.ehr.EHRManager.OBS_CATEGORY_OBSERVATIONS') THEN null
    ELSE o.category
  END as category,
  CASE
    WHEN o.area = 'N/A' THEN null
    ELSE o.area
  END as area,
  o.observation,
  COALESCE(CASE
    WHEN (o.remark IS NOT NULL AND o.observation IS NOT NULL) THEN ('.  ' || o.remark)
    ELSE o.remark
  END, '') as remark,
  o.performedby

FROM study.clinical_observations o

WHERE o.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.VET_REVIEW')
  AND o.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TECH_REVIEW')
  AND o.qcstate.PublicData = true
) t
GROUP BY t.Id, t.taskId, t.dateOnly

UNION ALL

SELECT
  t.Id,
  t.date,
  t.category,
  t.description,
  t.remark,
  t.performedby

FROM study.clinremarks t
WHERe t.qcstate.PublicData = true