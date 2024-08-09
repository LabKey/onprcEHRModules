SELECT
    Id,
    date,
    enddate,
    frequency,
    treatmenttimes,
    project,
    code,
    volumewithunits,
    concentrationwithunits,
    amountwithunits,
    route,
    performedby,
    remark,
    reason,
    modifiedby,
    modified,
    category,
    taskid
FROM study.treatment_order
WHERE code NOT IN ('E-85760', 'E-Y7735')
  AND enddate is null