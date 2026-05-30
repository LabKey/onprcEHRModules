/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select a.Id,
       a.date,
       b.Id.curLocation.area as area,
       b.Id.curLocation.room as room,
       b.Id.curLocation.cage as cage,
       a.label,
       a.comment,
       b.calculated_status as LiveStatus

from genotypesWithSignificance a, study.demographics b where a.Id = b.Id