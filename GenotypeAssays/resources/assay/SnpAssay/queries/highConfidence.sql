SELECT
  d.subjectId,
  COUNT(DISTINCT d.marker) as totalMarkers,
  COUNT(DISTINCT (CASE WHEN (d.confidence >= 0.6) THEN d.marker ELSE NULL END)) as highConfidenceMarkers,

FROM Data d
WHERE (d.statusflag IS NULL OR d.statusflag LIKE '%DEFINITIVE%')
GROUP BY d.subjectId
