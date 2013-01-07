/*
 * Copyright (c) 2010-2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query displays all animals co-housed with each housing record
--to be considered co-housed, they only need to overlap by any period of time

PARAMETERS(STARTDATE TIMESTAMP, ENDDATE TIMESTAMP)

SELECT e.*

FROM study.encounters e
JOIN onprc_billing.procedureFeeDefinition p ON (p.procedureId = e.procedureId)

WHERE CONVERT(e.date, DATE) >= STARTDATE AND CONVERT(e.date, DATE) <= ENDDATE
AND e.qcstate.publicdata = true AND p.active = true

--TODO: blood draws