SELECT
d.*,
f.date as dateAdded

FROM study.demographics d
JOIN study.flags f ON (d.id = f.id AND f.enddateTimeCoalesced >= now() AND f.value = 'Clinically Restricted - ADR')
WHERE d.calculated_status = 'Alive'