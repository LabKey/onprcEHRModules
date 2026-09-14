/*
study.demographicsAssignedVet

* Returns one or more assigned vets per animal ID
* Note to future self: be very careful when adding more fields to this view. It can easily
  result in additional rows per animal if they're distinct.
 */

WITH MinRule AS (
    SELECT Id, MIN(matchedRule) AS MinMatchedRule
    FROM vetAssignment_filter
    GROUP BY Id
),
    VetCaseData AS (
        SELECT
            Id,
            AssignedVet,
            GROUP_CONCAT(DISTINCT ActiveMasterProblems, ', ') AS GroupedMasterProblems -- DISTINCT prevents duplicate master problems if dual-assigned
        FROM vetAssignment_filter
        WHERE matchedRule = 0
        GROUP BY Id, AssignedVet
    )
SELECT DISTINCT -- DISTINCT prevents duplicate rows
    f.Id,
    f.AssignedVet,
    f.AssignmentType,
    v.GroupedMasterProblems AS MasterProblems,
    f.Area,
    f.Room
FROM vetAssignment_filter f
     JOIN MinRule m
          ON m.Id = f.Id
              AND m.MinMatchedRule = f.matchedRule
     LEFT JOIN VetCaseData v
               ON v.Id = f.Id
                   AND v.AssignedVet = f.AssignedVet