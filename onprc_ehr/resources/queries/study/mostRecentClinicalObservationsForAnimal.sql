SELECT
  t.Id,
  max(t.date) as date,

  GROUP_CONCAT(CASE
    WHEN (t.category IS NOT NULL AND t.area IS NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.observation || t.remark) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.area IS NOT NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.area || ', ' || t.observation) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.observation IS NULL) THEN cast((t.category || t.remark) as varchar(1000))
    WHEN (t.category IS NULL AND t.observation IS NOT NULL) THEN cast((t.observation || t.remark) as varchar(1000))
    else t.remark
  END, chr(10)) as observations

FROM (SELECT
  o.Id,
  o.date,
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
  END, '') as remark

FROM study.clinical_observations o
JOIN (
  SELECT o2.Id, max(o2.date) as date
  FROM study.clinical_observations o2
  WHERE o2.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.VET_REVIEW')
    AND o2.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TECH_REVIEW')
    AND (
      o2.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalRoundsFormType.NAME') OR
      o2.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalReportFormType.NAME')
    )
  GROUP BY o2.Id
) t ON (t.Id = o.Id AND t.date = o.date)

WHERE o.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.VET_REVIEW')
  AND o.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TECH_REVIEW')
  AND (
    o.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalRoundsFormType.NAME') OR
    o.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalReportFormType.NAME')
  )
) t
GROUP BY t.Id