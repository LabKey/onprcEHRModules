SELECT
o.Id,
max(o.date) as date,
o.taskId,
o.category,
(SELECT group_concat(distinct d.code.meaning) as code FROM study.drug d WHERE d.Id = o.Id AND d.taskId = o.taskId AND d.code IN ('E-70590', 'E-YY992')) as sedation,
group_concat(DISTINCT o.observation, ',') as observation,
group_concat(DISTINCT o.performedby, ',') as performedBy,
(SELECT group_concat(distinct room) as rooms FROM study.housing h
WHERE h.Id = o.Id
  AND h.date <= max(o.date)
  AND h.enddateTimeCoalesced >= timestampadd('SQL_TSI_DAY', -30, max(o.date))
) as rooms,
(SELECT group_concat(distinct room.area) as areas FROM study.housing h
WHERE h.Id = o.Id
  AND h.date <= max(o.date)
  AND h.enddateTimeCoalesced >= timestampadd('SQL_TSI_DAY', -30, max(o.date))
) as areas

FROM study.clinical_observations o
WHERE o.category IN ('Alopecia Score', 'Alopecia Type', 'Alopecia Regrowth')
--note: this is a fairly arbitrary cutoff, used because we only started tracking these measures after this date
and date > '2014-05-01'
GROUP BY o.Id, o.taskId, o.category
PIVOT observation BY category IN ('Alopecia Score', 'Alopecia Type', 'Alopecia Regrowth')