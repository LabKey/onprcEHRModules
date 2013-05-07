SELECT
  m.lsid,
  m.id,
  count(distinct pc.Id) as confirmations,
  min(pc.date) as confirmationDate,
  count(distinct b.Id) as births,
  min(b.date) as birthDate,
  max(b.date) as maxBirthDate,
  max(m.male) as male,
  group_concat(distinct b.id) as offspring,
  group_concat(distinct b.cond) as birthCondition,

FROM study.matings m
LEFT JOIN study.pregnancyConfirmation pc ON (pc.id = m.id AND m.date < pc.date AND TIMESTAMPDIFF('SQL_TSI_DAY', m.date, pc.date) < 180)
LEFT JOIN study.Birth b ON (b.dam = m.id AND m.date < b.date AND TIMESTAMPDIFF('SQL_TSI_DAY', m.date, b.date) < 180)
GROUP BY m.lsid, m.id