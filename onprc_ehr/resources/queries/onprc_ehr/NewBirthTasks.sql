/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 *  Created by Kollil, 10/25
 *  Get a list of tasks daily on a rolling 7 day window to review for QC.
 *  This will allow techs to see what new IDs were created by whom, and review for accuracy,
 *  housing history, group ids and flags.
 *  Refer tkt # 13504
 */
SELECT
    t.taskid,
    t.title,
    t.formType as TaskType,
    t.assignedto,
    t.duedate,
    t.createdby,
    t.created,
    t.qcstate as Status
FROM ehr.tasks t
WHERE t.created >= TIMESTAMPADD('day', -7, NOW())
And t.formtype = 'birth'


