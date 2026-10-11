/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
       protocol,
       protocol.displayName as displayName

FROM ehr.protocol
where (enddate is null or enddate >= Now())
order by protocol