/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

select a.*, b.UserId, Left(b.Email,CHARINDEX('@',b.Email)-1) as emailName from Reference_StaffNames a, onprc_ehr.usersActiveNames b
where a.username = Left(b.Email,CHARINDEX('@',b.Email)-1)
  and b.active = 'true'