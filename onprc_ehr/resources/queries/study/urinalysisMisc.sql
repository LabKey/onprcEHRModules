/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  b.Id,
  b.date,
  b.method,
  b.testid,

  b.resultOORIndicator,
  b.results,
  b.units,
  b.remark,
  b.qcstate,
  b.runId,
  b.taskid
FROM study."Urinalysis Results" b

WHERE (b.testId.includeInPanel = false or b.testId.includeInPanel IS NULL) and b.qcstate.publicdata = true

