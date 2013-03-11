SELECT
d.id,
d.id.age.AgeInYears,
max(e.date) as lastdate,
TIMESTAMPDIFF('SQL_TSI_DAY', max(e.date), now()) as daysSinceExam,
COALESCE(CASE
  WHEN d.id.age.AgeInYears >= 18 THEN (180 - TIMESTAMPDIFF('SQL_TSI_DAY', max(e.date), now()))
  ELSE (365 - TIMESTAMPDIFF('SQL_TSI_DAY', max(e.date), now()))
END, 0) as daysUntilNextExam,
count(e.lsid) as totalExams,

FROM study.demographics d LEFT JOIN (select
    e.id,
    e.date,
    e.lsid
  FROM study.encounters e left join ehr.snomed_tags t on (e.objectid = t.recordid)
  where t.code.meaning like 'Physical Exam%' and e.id.demographics.calculated_status = 'Alive'
) e ON (e.id = d.id)

WHERE d.calculated_status = 'Alive'

GROUP BY d.id, d.id.age.AgeInYears