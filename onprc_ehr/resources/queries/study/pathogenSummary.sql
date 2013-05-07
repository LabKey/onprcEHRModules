PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  t1.pathogen,
  t1.category,
  max(t1.totalTests) as totalTests,
  max(t1.totalIds) as totalIds,
  sum(t1.positive) as totalPositive,
  count(distinct t1.IdPositive) as distinctPositive,
  max(t1.totalTests) - sum(t1.positive) as totalNegative,
  max(t1.totalIds) - count(distinct t1.IdPositive) as distinctNegative,
  count(distinct t1.wasSPFId) as numInitiallySPF,
  count(distinct t1.neverSPFId) as numNeverSPF,
  count(distinct t1.endedSPFId) as numEndedSPF,
  count(distinct t1.leftCenterId) as numLeftCenter,
  count(distinct t1.droppedFromSPFId) as numDroppedFromSPF,

  max(t1.StartDate) as StartDate,
  max(t1.EndDate) as EndDate,

FROM study.pathogenData t1
WHERE t1.pathogen != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)'
GROUP BY t1.pathogen, t1.category