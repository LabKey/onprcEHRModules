/*
study.demographicsAssignedVet

* Returns one or more assigned vets per animal ID
* Note to future self: be very careful when adding more fields to this view. It can easily
  result in additional rows per animal if they're distinct.
 */

SELECT
    f.Id,
    f.AssignedVet,
    f.AssignmentType,
    GROUP_CONCAT(
            CASE WHEN f.matchedRule = 0 THEN f.ActiveMasterProblems ELSE NULL END,
            '; '
    ) AS MasterProblems,
    f.Area,
    f.Room
FROM vetAssignment_filter f
WHERE f.matchedRule = (
    SELECT min(matchedRule)
    FROM vetAssignment_filter sub
    WHERE sub.Id = f.Id
)
GROUP BY f.Id, f.AssignedVet, f.AssignmentType, f.Area, f.Room