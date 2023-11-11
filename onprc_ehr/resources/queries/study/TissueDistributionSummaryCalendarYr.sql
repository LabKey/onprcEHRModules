-- Created: 1-2-2-18  R.Blasa
SELECT
  calendarYear,
  t.requestCategory,
  count(t.Id) as totalSamples,
  count(distinct t.Id) as distinctAnimals,
  count(distinct t.recipient) as distinctRecipients

FROM study.tissueDistributions t
Where taskid is not null
  And t.QCState.Label in ('Request: Pending','Completed')

GROUP BY calendarYear, t.requestCategory