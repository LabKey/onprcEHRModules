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
  e.servicerequested,
  p.chargeId

FROM study.clinpathRuns e
JOIN onprc_billing.labworkFeeDefinition p ON (p.servicename = e.servicerequested AND p.active = true)

WHERE e.dateOnly >= CAST(STARTDATE as date) AND e.dateOnly <= CAST(ENDDATE as date)
AND e.qcstate.publicdata = true