/*
study.demographicsAssignedVet

* Returns one or more assigned vets per animal ID
* Note to future self: be very careful when adding more fields to this view. It can easily
  result in additional rows per animal if they're distinct.
 */

-- Step 1: Find the minimum matchedRule for each ID
WITH MinMatchedRules AS (SELECT Id,
                                min(matchedRule) AS rule
                            FROM vetAssignment_Filter
                            GROUP BY Id)

-- Step 2: Join the original table with the filtered minimum matched rules
SELECT DISTINCT f.Id,
    f.AssignedVet,
    f.AssignmentType,
    p.MasterProblems,
    f.Area,
    f.Room

FROM vetAssignment_Filter f
     JOIN MinMatchedRules r ON f.Id = r.Id AND f.matchedRule = r.rule
     LEFT JOIN (SELECT Id,
                    AssignedVet,
                    GROUP_CONCAT(ActiveMasterProblems, ',') AS MasterProblems
                FROM vetAssignment_filter
                WHERE matchedRule = 0
                GROUP BY Id, AssignedVet) p ON p.Id = f.Id AND p.AssignedVet = f.AssignedVet