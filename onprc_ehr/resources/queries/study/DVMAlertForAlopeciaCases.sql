/* Added by Kollil 09/22/2025
    When BSU creates a case AND scores the alopecia at either 4 or 5 (only those scores)
    THEN the vet assigned to that animal should receive an alert.
    Show open cases in last 7 days
Refer to tkt # 12523
*/
SELECT
    co.Id,
    co.date AS AlertObservationDate,
    co.observation AS AlopeciaScore,
    co.performedby,
    co.enteredSincevetReview,
    co.Id.assignedVet.AssignedVet AS AssignedVet,
    c.BehaviorCaseOpenDate,
    TIMESTAMPADD(SQL_TSI_DAY, 7, c.BehaviorCaseOpenDate) AS VetReviewDueDate
FROM study.clinical_observations co
         INNER JOIN study.demographics d
                    ON d.Id = co.Id
         INNER JOIN (
    SELECT
        x.Id,
        MAX(x.date) AS BehaviorCaseOpenDate
    FROM study.Cases x
    WHERE x.category = 'Behavior'
      AND x.allProblemCategories = 'Behavioral: Alopecia'
      AND x.enddate IS NULL
      AND x.date >= TIMESTAMPADD(SQL_TSI_DAY, -7, NOW())
    GROUP BY x.Id
) c
                    ON c.Id = co.Id
WHERE co.category = 'Alopecia Score'
  AND co.observation IN ('4', '5')
  AND d.calculated_status = 'Alive'

    /* Only the first 4/5 in a streak */
  AND NOT EXISTS (
    SELECT 1
    FROM study.clinical_observations prev
    WHERE prev.Id = co.Id
      AND prev.category = 'Alopecia Score'
      AND prev.observation IN ('4', '5')
      AND prev.date < co.date
      AND prev.date >
          COALESCE(
                  (
                      SELECT MAX(reset.date)
                      FROM study.clinical_observations reset
                      WHERE reset.Id = co.Id
                        AND reset.category = 'Alopecia Score'
                        AND reset.observation IN ('0', '1', '2', '3')
                        AND reset.date < co.date
                  ),
                  '1900-01-01'
          )
);