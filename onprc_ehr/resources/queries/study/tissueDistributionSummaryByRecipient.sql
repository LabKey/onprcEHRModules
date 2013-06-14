SELECT
  fiscalYear,
  t.recipient,
  t.recipient.affiliation,
  t.requestCategory,
  count(t.Id) as totalSamples,
  count(distinct t.Id) as distinctAnimals,
  count(distinct t.recipient) as distinctRecipients,

FROM study.tissueDistributions t

GROUP BY fiscalYear, t.recipient, t.recipient.affiliation, t.requestCategory