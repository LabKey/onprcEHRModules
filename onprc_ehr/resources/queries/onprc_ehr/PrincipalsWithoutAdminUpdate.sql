/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
    u.UserId,
    u.DisplayName,
    'u' as Type,
    u.FirstName,
    u.LastName

FROM onprc_ehr.usersActiveNames u


UNION ALL

SELECT
    g.idkey as UserId,
    g.displayName as DisplayName,
    g.type as Type,
    null as FirstName,
    null as LastName
FROM onprc_ehr.Reference_Data_IDkey g
Where g.type = 'g'
and g.status = 1
and g.endDate is null
