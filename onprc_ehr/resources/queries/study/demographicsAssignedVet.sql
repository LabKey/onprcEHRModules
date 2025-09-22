/*
study.demographicsAssignedVet

* Returns one or more assigned vets per animal ID
* Note to future self: don't be tempted to add more fields to this view. It will likely
  result in additional rows per animal as they won't be distinct.

 */

-- Step 1: Find the minimum matchedRule for each ID
WITH MinMatchedRules AS (
    SELECT
        VAF2.Id,
        MIN(VAF2.matchedRule) AS MinRule
    FROM
        vetAssignment_Filter AS VAF2
    GROUP BY
        VAF2.Id
)

-- Step 2: Join the original table with the filtered minimum matched rules
SELECT DISTINCT
    VAF1.Id,
    VAF1.AssignedVet,
    VAF1.AssignmentType,
    VAF1.Room,
    VAF1.Area,
    VAF1.Species

FROM
    vetAssignment_Filter AS VAF1
        INNER JOIN
    MinMatchedRules AS MMR
    ON VAF1.Id = MMR.Id
        AND VAF1.matchedRule = MMR.MinRule