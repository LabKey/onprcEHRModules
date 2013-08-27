/*
 * Copyright (c) 2011-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query displays all animals co-housed with each housing record
--to be considered co-housed, they only need to overlap by any period of time

SELECT
    pd.Id,
    pd.project,
    pd.chargeId,

    sum(pd.effectiveDays) as effectiveDays,
    min(pd.startDate) as startDate @hidden,
    min(pd.numDays) as numDays @hidden,
FROM onprc_billing.perDiemsByDay pd

GROUP BY pd.Id, pd.project, pd.chargeId