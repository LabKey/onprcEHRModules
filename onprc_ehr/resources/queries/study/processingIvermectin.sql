SELECT
  d.Id,
  max(da.date) as lastDate,
  timestampdiff('SQL_TSI_DAY', max(da.date), now()) as daysSinceTreatment

FROM study.demographics d
LEFT JOIN study.drug da ON (d.id = da.Id AND da.code = 'E-Y7410') --Ivermectin

GROUP BY d.Id