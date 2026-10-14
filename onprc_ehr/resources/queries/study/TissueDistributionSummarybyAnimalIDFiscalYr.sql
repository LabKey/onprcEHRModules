/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- Added: 1-2-2018  R.Blasa
SELECT
    fiscalYear,
    t.id,
  count(t.Id) as totalSamples,
  count(distinct t.Id) as distinctAnimals,
  count(distinct t.recipient) as distinctRecipients

FROM study.tissueDistributions t
Where t.taskid is not null
  And t.QCState.Label in ('Request: Pending','Completed')

GROUP BY  fiscalYear, t.id