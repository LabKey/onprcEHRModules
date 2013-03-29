SELECT
  b.id,
  cast(b.date as date) as date,
  sum(b.quantity) as quantity
FROM study.blood b
WHERE (b.qcstate.metadata.DraftData = true OR b.qcstate.publicdata = true)
GROUP BY b.id, cast(b.date as date)