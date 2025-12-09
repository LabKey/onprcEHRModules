/* Kollil, Aug 2024:
  Get all the meds except the following two medications that are allowed to enter without the end dates.
1. E-85760 - Medroxyprogesterone injectable (150mg/ml)
2. E-Y7735 - Diet - Weekly Multivitamin

   Added these two Diets to the list by Kollil on 4/15/25. Refer to tkt #12363
3. E-X0500 - Diet, L-Phyto (Low-phytoestrogen)
4. E-Y9750 - Diet, 5047 High Protein, Jumbo

    Added Diet to the list by Kollil on 5/14/25. Refer to tkt #12506
5. E-X1380 - Diet Daily (Non-standard), 5LOP (TAD)
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
    taskid.rowid as TaskId
FROM study.treatment_order
WHERE code NOT IN ('E-85760', 'E-Y7735', 'E-X0500', 'E-Y9750', 'E-X1380')
  AND enddate is null