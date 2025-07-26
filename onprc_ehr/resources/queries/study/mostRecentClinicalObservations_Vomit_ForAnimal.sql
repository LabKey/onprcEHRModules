select
    t.Id,
    group_concat(cast(t.date as date), chr(10)) as date,
    count(t.date) as totalcount,

  GROUP_CONCAT(CASE
    WHEN (t.category IS NOT NULL AND t.area IS NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.observation || t.remark) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.area IS NOT NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.area || ', ' || t.observation) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.observation IS NULL) THEN cast((t.category || t.remark) as varchar(1000))
    WHEN (t.category IS NULL AND t.observation IS NOT NULL) THEN cast((t.observation || t.remark) as varchar(1000))
    else t.remark
  END, chr(10)) as observations,
 group_concat(t.category, chr(10)) as category

FROM study.clinical_observations t

WHERE (t.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.VET_REVIEW')
  AND t.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TECH_REVIEW')
  AND t.category = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.OBS_VOMIT')  )
  AND (
    t.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalRoundsFormType.NAME') OR
    t.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalReportFormType.NAME') OR
    t.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.BulkClinicalEntryFormType.NAME')
    )
  AND t.date  >= (select cast(max(a.date) as date) from study.clinical_observations a where a.Id = t.Id
  AND (a.category = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.VET_REVIEW')   OR
    a.category = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TECH_REVIEW') )     )

group by t.Id
