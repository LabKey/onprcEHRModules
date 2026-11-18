/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Select Id, MAX(enddate) as endDate --, TIMESTAMPDIFF('SQL_TSI_DAY', enddate, now()) as DaysSinceLastGroupAssignment
From animal_group_members
Where enddate is not null
And (TIMESTAMPDIFF('SQL_TSI_DAY', enddate, now()) >= 21 and TIMESTAMPDIFF('SQL_TSI_DAY', enddate, now()) <= 175)
Group by id