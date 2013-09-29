/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query displays all animals co-housed with each housing record
--to be considered co-housed, they only need to overlap by any period of time

PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  e.Id,
  e.date,
  e.project,
  e.procedureId,
  p.chargeId,
  e.objectid as sourceRecord

FROM study.encounters e
JOIN onprc_billing.procedureFeeDefinition p ON (p.procedureId = e.procedureId and e.chargetype = p.chargetype AND p.active = true)

WHERE e.dateOnly >= CAST(StartDate as date) AND e.dateOnly <= CAST(EndDate as date)
AND e.qcstate.publicdata = true

UNION ALL

--Blood draws
SELECT
  e.Id,
  e.date,
  e.project,
  null as procedureId,
  (select rowid from onprc_billing.chargeableItems ci where ci.name = 'Blood Draw' and ci.active = true) as chargeId,
  e.objectid as sourceRecord

FROM study.blood e
WHERE e.dateOnly >= CAST(StartDate as date) AND e.dateOnly <= CAST(EndDate as date)
and e.chargetype != 'No Charge'
AND e.qcstate.publicdata = true

--TODO: drug administration