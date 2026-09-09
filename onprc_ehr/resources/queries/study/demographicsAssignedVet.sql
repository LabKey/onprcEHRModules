SELECT
    f.Id,
    f.AssignedVet,
    f.AssignmentType,
    GROUP_CONCAT(
            CASE WHEN f.matchedRule = 0 THEN f.ActiveMasterProblems ELSE NULL END,
            ', '
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

/* WITH MinRule AS (
    SELECT Id, MIN(matchedRule) AS MinMatchedRule
    FROM vetAssignment_filter
    GROUP BY Id
),
    VetCaseData AS (
        SELECT
            Id,
            AssignedVet,
            GROUP_CONCAT(DISTINCT ActiveMasterProblems, ', ') AS GroupedMasterProblems
        FROM vetAssignment_filter
        WHERE matchedRule = 0
        GROUP BY Id, AssignedVet
    )
SELECT DISTINCT
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
                   AND v.AssignedVet = f.AssignedVet */