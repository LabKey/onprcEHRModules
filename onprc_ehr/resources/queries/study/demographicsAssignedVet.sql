/*
study.demographicsAssignedVet

Returns one or more assigned vets per animal ID
  * When there is an open case, it returns one record for each vet having an open
    case for that animal
  * When there is not an open case, it returns one record for the lowest-numbered
    matched rule
  * VAF2 determines the lowest matched rule for each animal. Doing an inner join
    with VAF1 results in only those records matching the lowest matched rule per
    animal. The select distinct limits it to a single record.

Per Lindsay's request, this user-defined query includes all the fields that the
Vet Assignment Raw Data file does.

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
--    VAF1.CaseVet,
--    VAF1.CaseDate,
--    VAF1.Project,
--    VAF1.ProjectType,
--    VAF1.Protocol,
--    VAF1.ProtocolPI,
    VAF1.Room,
    VAF1.Area,
    VAF1.Species
--    VAF1.Calculated_status,
--    VAF1.MatchedRule

FROM
    vetAssignment_Filter AS VAF1
        INNER JOIN
    MinMatchedRules AS MMR
    ON VAF1.Id = MMR.Id
        AND VAF1.matchedRule = MMR.MinRule