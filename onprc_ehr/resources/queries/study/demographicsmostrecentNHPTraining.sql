/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select Id,
       max(date) as date,
       group_concat(DISTINCT training_type) as training_type,
       group_concat(DISTINCT training_results) as training_results,
       group_concat(DISTINCT remark) as remark

from onprc_ehr.NHP_Training
group by Id