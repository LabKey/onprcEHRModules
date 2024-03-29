-- Added: 1-2-2018  R.Blasa
SELECT
  calendarYear,
  t.recipient,
  t.recipient.affiliation,
  t.requestCategory,
  count(t.Id) as totalSamples,
  count(distinct t.Id) as distinctAnimals,
  count(distinct t.recipient) as distinctRecipients

FROM study.tissueDistributions t
Where t.taskid is not null
  And t.QCState.Label in ('Request: Pending','Completed')

GROUP BY  calendarYear, t.recipient, t.recipient.affiliation, t.requestCategory