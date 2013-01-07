/*
 * Copyright (c) 2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query displays all animals co-housed with each housing record
--to be considered co-housed, they only need to overlap by any period of time

SELECT
    --pd.project,
    --pd.project.protocol,
    pd.account,
    --pd.type,
    sum(pd.effectiveDays) as effectiveDays,
    group_concat(DISTINCT pd.id) as animals
FROM onprc_billing.perDiemsByDay pd

GROUP BY pd.account
--, pd.type