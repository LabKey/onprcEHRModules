SELECT
  t.lsid,
  t.id,
  t.date,
  cast(t.lastWeight as double) as lastWeight,
  t.lastWeightDate,
  cast(t.previousBlood as double) as previousBlood,
  cast((t.lastWeight * t.blood_per_kg * t.max_draw_pct) as double) as allowableBlood,
  cast(((t.lastWeight * t.blood_per_kg * t.max_draw_pct) - t.previousBlood) as double) as availableBlood,

FROM (

SELECT
  t0.*,
  (select avg(w2.weight) as lastWeight FROM study.weight w2 WHERE w2.id = t0.id AND w2.date = t0.lastWeightDate) as lastWeight
FROM (

SELECT
  b.lsid,
  b.id,
  b.quantity,
  b.dateOnly,
  b.date,
  b2.lastWeightDate,
  d.species.blood_per_kg,
  d.species.max_draw_pct,
  b3.quantity as previousBlood,
FROM study.demographics d
JOIN study."Blood Draws" b ON (d.id = b.id)
JOIN (
  SELECT
    b.lsid,
    max(w.date) as lastWeightDate
  FROM study.blood b
  JOIN study.weight w ON (w.id = b.id AND w.date <= b.date)
  GROUP BY b.lsid
) b2 on (b2.lsid = b.lsid)
JOIN (
  SELECT
    b1.lsid,
    sum(b2.quantity) as quantity
  FROM study.blood b1
  JOIN study.blood b2 ON (b1.id = b2.id AND b2.dateOnly > TIMESTAMPADD('SQL_TSI_DAY', (-1 * 21), b1.dateOnly) AND b2.dateOnly <= b1.dateOnly)
  GROUP BY b1.lsid
) b3 ON (b3.lsid = b.lsid)
WHERE d.calculated_status = 'Alive'

) t0

) t