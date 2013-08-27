SELECT
  t1.id,
  t1.earliestClinicalMedication,
  TIMESTAMPDIFF('SQL_TSI_DAY', t1.earliestClinicalMedication, now()) as daysOnClinicalMedications
FROM (

SELECT
  d.Id,
  (select max(date) as lastDate FROM study."Treatment Orders" t WHERE d.Id = t.Id and t.isActive = true) as earliestClinicalMedication
FROM study.demographics d

) t1