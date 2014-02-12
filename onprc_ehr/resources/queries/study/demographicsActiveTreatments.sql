SELECT
  t.Id,
  count(t.Id) as totalTreatments,
  COUNT(CASE WHEN t.category = 'Clinical' THEN 1 ELSE null END) as totalClinicalTreatments,
  COUNT(CASE WHEN t.category = 'Surgical' THEN 1 ELSE null END) as totalSurgicalTreatments,
  COUNT(CASE WHEN t.category = 'Research' THEN 1 ELSE null END) as totalResearchTreatments,

  GROUP_CONCAT(CASE WHEN t.category = 'Clinical' THEN t.code.meaning ELSE null END, chr(10)) as clinicalTreatments,
  GROUP_CONCAT(CASE WHEN t.category = 'Surgical' THEN t.code.meaning ELSE null END, chr(10)) as surgicalTreatments,
  GROUP_CONCAT(CASE WHEN t.category = 'Research' THEN t.code.meaning ELSE null END, chr(10)) as researchTreatments,

  max(t.modified) as lastModification,

FROM study.treatment_order t
WHERE t.isActive = true
GROUP BY t.Id