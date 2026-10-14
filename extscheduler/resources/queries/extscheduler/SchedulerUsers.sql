/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(GroupName VARCHAR)
SELECT *
FROM core.Users
WHERE UserId in (
   SELECT UserId
   FROM core.Members m
   WHERE m.GroupId.Name = GroupName
)