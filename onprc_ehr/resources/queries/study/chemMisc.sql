/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  b.id,
  b.date,
  b.method,
  b.testId,

  b.resultOORIndicator,
  b.result,
  b.units,
  b.qualresult,
  b.remark,
  b.qcstate,
  b.taskid,
  b.runId
FROM study."Chemistry Results" b

WHERE (b.testId.includeInPanel = false or b.testId.includeInPanel IS NULL) and b.qcstate.publicdata = true

