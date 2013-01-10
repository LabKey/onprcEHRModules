SELECT
  t.*,
  s.blood_draw_interval,
  s.blood_per_kg,
  s.max_draw_pct,
  (s.blood_per_kg / s.blood_draw_interval) as volReconstitutedPerDay,

  CASE
    WHEN ((s.blood_per_kg / s.blood_draw_interval) * abs(timeDiffWithBloodDraw) > t.quantity) THEN t.quantity
    ELSE ((s.blood_per_kg / s.blood_draw_interval) * abs(timeDiffWithBloodDraw))
  END as reconstituted,

FROM (

  SELECT
    b.id,
    dates.date,
    timestampdiff('SQL_TSI_DAY', curdate(), dates.date) as timeDiffWithNow,
    b.dateOnly as bloodDrawDate,
    timestampdiff('SQL_TSI_DAY', b.dateOnly, dates.date) as timeDiffWithBloodDraw,

    sum(b.quantity) as quantity,
    b.id.dataset.demographics.species,
    b.id.mostRecentWeight.MostRecentWeight as lastWeight,

  FROM (
    SELECT
      timestampadd('SQL_TSI_DAY', i.value, curdate()) as date,
    FROM ldk.integers i

    WHERE i.value < 30

  ) dates

  JOIN study.blood b ON (
    b.id.dataset.demographics.species.blood_draw_interval IS NOT NULL AND
    b.dateOnly <= dates.date AND
    timestampdiff('SQL_TSI_DAY', b.dateOnly, dates.date) <= b.id.dataset.demographics.species.blood_draw_interval
    --AND (b.qcstate.metadata.DraftData = true OR b.qcstate.publicdata = true)
  )

  GROUP BY b.id, b.dateOnly, dates.date, b.id.dataset.demographics.species, b.id.MostRecentWeight.MostRecentWeight

) t

LEFT JOIN ehr_lookups.species s ON (s.common = t.species)