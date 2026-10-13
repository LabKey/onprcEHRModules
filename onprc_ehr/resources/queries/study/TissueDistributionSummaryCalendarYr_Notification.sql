-- Created: 10-12-2026  R.Blasa
SELECT
  calendarYear,
  t.requestCategory,
  count(t.Id) as totalSamples,
  count(distinct t.Id) as distinctAnimals,
  count(distinct t.recipient) as distinctRecipients

FROM study.tissueDistributions t
Where t.taskid is not null
  And t.QCState.Label in ('Request: Pending','Completed','In Progress')
   And t.requestCategory in ('','Affiliate','external')

GROUP BY calendarYear, t.requestCategory