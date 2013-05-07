SELECT
a.Id,
a.date,
a.tissue,
a.microbe,
a.antibiotic,
a.resistant,
a.project,
a.remark,
a.taskid,
a.requestid,
a.performedby

FROM study."Antibiotic Sensitivity" a
WHERE a.antibiotic NOT IN (
  'E-71875',
  'E-719Y1',
  'E-719Y3',
  'E-72040',
  'E-72045',
  'E-721X0',
  'E-72360',
  'E-72500',
  'E-72600',
  'E-72682',
  'E-72720',
  'E-Y7240'
)