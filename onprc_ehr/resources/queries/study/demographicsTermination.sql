SELECT
d.id,
CASE
  WHEN (count(a.lsid) > 0 OR count(f.lsid) > 0)
    THEN true
    ELSE false
END as status,
group_concat(DISTINCT a.project.displayName, chr(10)) as projects,
group_concat(DISTINCT f.value) as flags,

FROM study.demographics d
LEFT JOIN study.assignment a ON (a.id = d.id AND (a.releaseCondition.meaning = 'Terminal' OR a.projectedReleaseCondition.meaning = 'Terminal'))
LEFT JOIN study.flags f ON (f.id = d.id AND f.endDateTimeCoalesced >= now() AND f.value = 'Clinically Restricted - ADR')
WHERE d.calculated_status = 'Alive'
GROUP BY d.id