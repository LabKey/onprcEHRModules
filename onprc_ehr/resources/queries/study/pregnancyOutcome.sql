SELECT
  m.lsid,
  m.id,
  m.date,
  max(m.estDeliveryDate) as estDeliveryDate,
  group_concat(m.confirmationType.value) as confirmationType,
  count(distinct b.Id) as births,
  min(b.date) as birthDate,
  max(b.date) as maxBirthDate,
  group_concat(distinct b.id) as offspring,
  group_concat(distinct b.cond) as birthCondition

FROM study.pregnancyConfirmation m
LEFT JOIN study.Birth b ON (b.dam = m.id AND m.date < b.date AND TIMESTAMPDIFF('SQL_TSI_DAY', m.date, b.date) < 180)
GROUP BY m.lsid, m.id, m.date