/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT b.Id,
b.date,
b.date_type,
b.birth_condition,
b.room,
b.cage,
b.dam

FROM study.birth b join study.flags s on b.dam = s.id and s.flag.value = 'JMac Obese HFD' and s.enddate is null