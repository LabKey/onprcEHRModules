SELECT
  d.id,
  max(h.date) as lastHematologyDate,
  max(bc.date) as lastBiochemistryDate

FROM study.demographics d
LEFT JOIN study.clinpathRuns h ON (d.id = h.id AND h.type = 'Hematology')
LEFT JOIN study.clinpathRuns bc ON (d.id = bc.id AND bc.type = 'Biochemistry')
WHERE d.calculated_status = 'Alive'
GROUP BY d.id

