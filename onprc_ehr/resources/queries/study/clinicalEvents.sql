SELECT
  p.id,
  p.date,
  'Problem Created' as eventType,
  p.category as value,
  p.remark
FROM study.problem p

UNION ALL

SELECT
  c.id,
  c.date,
  'Case Opened' as eventType,
  c.category as value,
  c.remark
FROM study.cases c

UNION ALL

SELECT
  c.id,
  c.date,
  'Death - Not For Experiment' as eventType,
  c.cause as value,
  c.remark
FROM study.deaths c
WHERE c.cause != 'Sacrifice for Experiment'

UNION ALL

SELECT
  c.id,
  c.date,
  'Death - For Experiment' as eventType,
  c.cause as value,
  c.remark
FROM study.deaths c
WHERE c.cause = 'Sacrifice for Experiment'

UNION ALL

SELECT
  c.id,
  c.date,
  'Birth' as eventType,
  c.cond as value,
  c.remark
FROM study.birth c

UNION ALL

SELECT
  c.id,
  c.date,
  'Acquisition' as eventType,
  c.acquisitionType.value as value,
  c.remark
FROM study.arrival c

UNION ALL

SELECT
  c.id,
  c.date,
  'Departure' as eventType,
  c.destination as value,
  c.remark
FROM study.departure c