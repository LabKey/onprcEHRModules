SELECT
  d.id,
  max(p.date) as confirmationDate,
  max(p.estDeliveryDate) as estDeliveryDate,
  timestampdiff('SQL_TSI_DAY', curdate(), max(p.estDeliveryDate)) as estDeliveryDays,
  group_concat(p.confirmationType) as confirmationType

FROM study.demographics d
JOIN study.pregnancyOutcome p ON (p.id = d.Id)
WHERE p.birthDate IS NULL AND timestampdiff('SQL_TSI_DAY', p.date, curdate()) < 180
GROUP BY d.id