SELECT
  t.id,
  t.date,
  t.lastBloodDraw,
  t.quantity,
  --t.volReconstitutedPerDay,
  t.timeDiffWithLastBloodDraw,
  CASE
    WHEN ((t.quantity - (t.timeDiffWithLastBloodDraw * t.volReconstitutedPerDay)) < 0) THEN 0
    ELSE (t.quantity - (t.timeDiffWithLastBloodDraw * t.volReconstitutedPerDay))
  END as effectiveVolume,
  blood_per_kg,
  max_draw_pct,
  lastWeight

FROM (

SELECT
  bd.id,
  bd.date,
  max(bd.lastWeight) as lastWeight,
  max(bd.bloodDrawDate) lastBloodDraw,
  sum(bd.quantity) as quantity,
  max(volReconstitutedPerDay) as volReconstitutedPerDay,
  min(timeDiffWithBloodDraw) as timeDiffWithLastBloodDraw,
  max(blood_per_kg) as blood_per_kg,
  max(max_draw_pct) as max_draw_pct,

FROM study.currentBloodDraws bd
GROUP BY bd.id, bd.date

) t