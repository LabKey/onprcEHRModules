/* Added by Kollil 08/22/2025
New query created for when an animal receives an alopecia score of 4 or 5, but does not have an open behavioral case for alopecia.
Refer to tkt # 12145.
Show 1 year data.

Modified by Kollil 09/15/2025
Added date comparison to check only dates  and ignore time

Modified by Kollil July 2026
Showing only 1 month data, Refer to tkt # 14974
*/
SELECT
    mr.Id,
    d.species,
    CASE
        WHEN LOWER(d.gender) = 'f' THEN 'Female'
        WHEN LOWER(d.gender) = 'm' THEN 'Male'
        ELSE d.gender
    END AS gender,
    d.Id.age.ageinYearsRounded,
    d.Id.curLocation.area,
    d.Id.curLocation.room,
    d.Id.curLocation.cage,
    mr.observation AS MostRecentAlopeciaScore,
    mr.date,
    mr.performedby
FROM (
         SELECT co.Id, co.created, co.observation, co.date, co.performedby
         FROM study.clinical_observations AS co
         WHERE
           co.category = 'Alopecia Score'
           AND co.created >= TIMESTAMPADD(SQL_TSI_MONTH, -1, NOW())
           AND co.created = (
             SELECT MAX(co2.created)
             FROM study.clinical_observations AS co2
             WHERE
               co2.Id = co.Id
               AND co2.category = 'Alopecia Score'
               AND co2.created >= TIMESTAMPADD(SQL_TSI_MONTH, -1, NOW())
         )
     ) AS mr
         INNER JOIN study.demographics AS d ON mr.Id = d.Id
WHERE
  LOWER(d.calculated_status) = 'alive'
  AND mr.observation IN ('4', '5')
  AND NOT EXISTS (
    SELECT 1
    FROM study.Cases AS c
    WHERE
      c.Id = mr.Id
      AND c.category = 'Behavior'
      AND c.allProblemCategories = 'Behavioral: Alopecia'
      AND CAST(c.date AS DATE) <= CAST(mr.date AS DATE)
      AND (c.enddate IS NULL OR CAST(c.enddate AS DATE) >= CAST(mr.date AS DATE))
)
