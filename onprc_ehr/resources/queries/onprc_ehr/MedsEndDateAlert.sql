/* Kollil, Aug 2024:
  Get all the meds except the following two medications that are allowed to enter without the end dates.
1. E-85760 - Medroxyprogesterone injectable (150mg/ml)
2. E-Y7735 - Diet - Weekly Multivitamin
*/
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