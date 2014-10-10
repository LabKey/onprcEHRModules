/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  b.lsid,
  b.id,

  b.weight as mostRecentWeight,
  b.wdate as mostRecentWeightDate,
  b.blood_draw_interval,
  convert(bloodPrevious, float) as bloodPrevious,
  convert(bloodFuture, float) as bloodFuture,
  (b.weight * b.blood_per_kg * b.max_draw_pct) AS maxBlood,

  convert(case
    when (b.bloodPrevious > b.bloodFuture)
      THEN ((b.weight * b.blood_per_kg * b.max_draw_pct) - b.bloodPrevious)
    else
      ((b.weight * b.blood_per_kg * b.max_draw_pct) - b.bloodFuture)
  end, float) as availBlood

FROM (

SELECT
  d.lsid,
  d.id,
  d.species,
  --NOTE: this uses date part only
  lastWeight.dateOnly as wdate,
  (SELECT AVG(w.weight) AS _expr
    FROM study.weight w
    WHERE w.id = d.id
      --NOTE: this uses date part only
      AND w.dateOnly = lastWeight.dateOnly
      AND w.qcstate.publicdata = true
  ) AS weight,
  d.species.blood_per_kg,
  d.species.max_draw_pct,
  d.species.blood_draw_interval,

  COALESCE ((
    SELECT
    SUM(bd.quantity) AS quantity
    FROM study.blood bd
    WHERE bd.id = d.id
        AND (bd.qcstate.publicdata = true OR bd.qcstate.metadata.DraftData = true) --NOTE: this does mean non-completed past requests will count against blood
        AND bd.dateOnly > cast(TIMESTAMPADD('SQL_TSI_DAY', -1 * d.species.blood_draw_interval, now()) as date)
        AND bd.dateOnly <= cast(curdate() as date)
  ), 0) AS bloodPrevious,

  COALESCE ((
    SELECT
    SUM(bd.quantity) AS quantity
    FROM study.blood bd
    WHERE bd.id = d.id
        AND (bd.qcstate.publicdata = true OR bd.qcstate.metadata.DraftData = true)
        AND bd.dateOnly < cast(TIMESTAMPADD('SQL_TSI_DAY', d.species.blood_draw_interval, curdate()) as date)
        AND bd.dateOnly >= cast(curdate() as date)
  ), 0) AS bloodFuture

FROM
    study.demographics d
    --NOTE: this uses date part only
    JOIN (SELECT w.id, MAX(dateOnly) as dateOnly FROM study.weight w WHERE w.qcstate.publicdata = true GROUP BY w.id) lastWeight ON (d.id = lastWeight.id)
WHERE d.calculated_status = 'Alive'

) b