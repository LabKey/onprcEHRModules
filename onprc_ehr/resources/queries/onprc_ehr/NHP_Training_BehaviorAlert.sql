/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    Id,
    date,
    training_Ending_Date,
    training_type,
    reason,
    training_results,
    remark,
    taskid,
    performedby
FROM NHP_Training
Where training_results = 'In-Progress'
And TIMESTAMPDIFF(day, date, now()) > 60
