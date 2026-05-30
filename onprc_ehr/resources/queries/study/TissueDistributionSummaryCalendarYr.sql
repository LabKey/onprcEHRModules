/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- Created: 1-2-2-18  R.Blasa
SELECT
  calendarYear,
  t.requestCategory,
  count(t.Id) as totalSamples,
  count(distinct t.Id) as distinctAnimals,
  count(distinct t.recipient) as distinctRecipients

FROM study.tissueDistributions t
Where t.taskid is not null
  And t.QCState.Label in ('Request: Pending','Completed')

GROUP BY calendarYear, t.requestCategory