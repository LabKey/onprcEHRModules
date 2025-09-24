/* Added by Kollil 09/22/2025
When BSU creates a case AND scores the alopecia at either 4 or 5 (only those scores) THEN the vet assigned to that animal should receive an alert.
Show open cases in last 7 days
Refer to tkt # 12523
*/
SELECT
    co.Id,
    co.date AS MostRecentDate,
    co.observation AS MostRecentAlopeciaScore,
    co.performedby,
    co.enteredSincevetReview,
    co.Id.assignedVet.AssignedVet as AssignedVet,
    c.date as BehaviorCaseOpenDate
FROM study.clinical_observations AS co
    INNER JOIN study.demographics AS d
        ON co.Id = d.Id
    INNER JOIN study.Cases AS c
        ON c.Id = co.Id
        AND c.category = 'Behavior'
        AND c.allProblemCategories = 'Behavioral: Alopecia'
        AND c.enddate IS NULL
WHERE
    co.category = 'Alopecia Score'
    AND co.observation IN ('4', '5')
    --AND co.date >= '2025-01-01'
    AND d.calculated_status = 'Alive'
    AND co.date = (
    SELECT MAX(co2.date)
    FROM study.clinical_observations AS co2
    WHERE co2.Id = co.Id
      AND co2.category = 'Alopecia Score'
      AND co2.observation IN ('4', '5')
)
  AND c.date >= TIMESTAMPADD(SQL_TSI_DAY, -7, now())