/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query displays all animals co-housed with each housing record
--to be considered co-housed, they only need to overlap by any period of time

PARAMETERS(STARTDATE TIMESTAMP, ENDDATE TIMESTAMP)

SELECT
  e.Id,
  e.date,
  e.project,
  e.procedureId,
  p.chargeId

FROM study.encounters e
JOIN onprc_billing.procedureFeeDefinition p ON (p.procedureId = e.procedureId and e.chargetype = p.chargetype)

WHERE e.dateOnly >= CAST(STARTDATE as date) AND e.dateOnly <= CAST(ENDDATE as date)
AND e.qcstate.publicdata = true AND p.active = true

UNION ALL

--Blood draws
SELECT
  e.Id,
  e.date,
  e.project,
  null as procedureId,
  (select rowid from onprc_billing.chargeableItems ci where ci.name = 'Blood Draw' and ci.active = true) as chargeId

FROM study.blood e
WHERE e.dateOnly >= CAST(STARTDATE as date) AND e.dateOnly <= CAST(ENDDATE as date)
and e.chargetype != 'No Charge'
AND e.qcstate.publicdata = true

UNION ALL

--Clinpath data
SELECT
  e.Id,
  e.date,
  e.project,
  null as procedureId,
  ci.rowId as chargeId

from study."Clinpath Runs" e
join onprc_billing.chargeableItems ci
ON (e.servicerequested = ci.name and ci.category = 'Clinpath')
WHERE e.dateOnly >= CAST(STARTDATE as date) AND e.dateOnly <= CAST(ENDDATE as date)
AND e.qcstate.publicdata = true

--TODO: drug administration