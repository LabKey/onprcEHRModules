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

Future enhancements
  * Add ProjectType to select statement and hide in XML
  * Add Protocol_PI to study.vet_assignmentFilter and to onprc_ehr.vet_assignment
  * Add species to study.vet_assignmentFilter and to onprc_ehr.vet_assignment
  * Add validation to onprc_ehr.vet_assignment to prevent creating a rule that has
  *   no match in the filter
 */

SELECT DISTINCT VAF1.Id
              , VAF1.AssignedVet
              , VAF1.AssignmentType
              , VAF1.Room
              , VAF1.Area
              , VAF1.Calculated_Status
              , VAF1.MatchedRule
FROM vetAssignment_filter AS VAF1
         INNER JOIN (
    SELECT VAF2.Id
         , MIN(VAF2.matchedRule) AS minRule
    FROM vetAssignment_filter AS VAF2
    GROUP BY VAF2.id
) AS VAF3
    ON VAF1.id = VAF3.id
    AND VAF1.matchedRule = VAF3.minRule


-- SELECT VAF1.Id
--      , VAF1.AssignedVet
--      , VAF1.AssignmentType
-- /*	, VAF1.AssignmentType AS codeAssignmentType*/
--      , VAF1.Room
--      , VAF1.Area
--      , VAF1.Project
--      , VAF1.Protocol
--      , VAF1.ProtocolPI
--      , VAF1.Calculated_Status
--      , VAF1.MatchedRule
--      , VAF1.history
-- FROM vetAssignment_filter AS VAF1
--          INNER JOIN (
--     SELECT VAF2.Id
--          , MIN(VAF2.matchedRule) AS minRule
--     FROM vetAssignment_filter AS VAF2
--     GROUP BY VAF2.id
-- ) AS VAF3 ON VAF1.id = VAF3.id
--     AND VAF1.matchedRule = VAF3.minRule
