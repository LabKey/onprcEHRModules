/*
 Created by Kollil in Dec 2025
 Tkt # 13461
 Added two filters to the Demographics dataset:
 1. Filter out any animal with the following SNOMED Codes:
    Begin active weight management regimen (P-YY961)
    However, we would need to include animals that have this additional SNOMED Code if it's entered AFTER the one above
    Release from active weight management regimen (P-YY960)
 2. Remove Shelters, Corral and Hospital locations from the lists
  */

SELECT DISTINCT
    l.lsid,
    l.Id,

    l.date AS LatestWeightDate,
    l.weight AS LatestWeight,

    p.date, -- AS PrevWeightDate
    p.weight, -- AS PrevWeight

    timestampdiff('SQL_TSI_DAY', p.date, l.date) AS IntervalInDays,
    age_in_months(p.date, l.date) AS IntervalInMonths,

    CASE
        WHEN p.weight IS NOT NULL AND p.weight > 0 THEN
            ROUND(((l.weight - p.weight) * 100 / p.weight), 1)
        ELSE NULL
        END AS PctChange,

    CASE
        WHEN p.weight IS NOT NULL AND p.weight > 0 THEN
            ABS(ROUND(((l.weight - p.weight) * 100 / p.weight), 1))
        ELSE NULL
        END AS AbsPctChange,

    l.qcstate AS LatestQcState,
    p.qcstate AS PrevQcState

FROM
    (SELECT Id, MAX(date) AS LatestDate
     FROM study.weight
     GROUP BY Id) lw

        JOIN study.weight l
             ON l.Id = lw.Id
                 AND l.date = lw.LatestDate

        LEFT JOIN study.weight p
                  ON p.Id = lw.Id
                      AND p.date = (
                          SELECT MAX(w2.date)
                          FROM study.weight w2
                          WHERE w2.Id = lw.Id
                            AND w2.date <= timestampadd('SQL_TSI_DAY', -30, lw.LatestDate)
                            AND w2.date >= timestampadd('SQL_TSI_DAY', -100, lw.LatestDate)
                      )

WHERE l.Id.curlocation.area NOT IN ('Shelters', 'Corral', 'Hospital')-- Exclude animals from these locations
  AND NOT (-- Exclude females under 5yrs, males under 7yrs
    (l.Id.demographics.gender.code = 'f' AND l.Id.age.ageInYears < 5)
        OR (l.Id.demographics.gender.code = 'm' AND l.Id.age.ageInYears < 7)
    )
  AND l.qcstate.publicdata = true
  AND NOT EXISTS (
    -- -- Find animals whose latest 'Weight MMA BEGIN' has no later 'Weight MMA RELEASE'
    SELECT 1
    FROM study.WeightManagementMMAData b
    WHERE b.Id = l.Id
      AND b.code = 'P-YY961'
      AND b.date = (
        SELECT MAX(b2.date)
        FROM study.WeightManagementMMAData b2
        WHERE b2.Id = l.Id
          AND b2.code = 'P-YY961'
    )
      AND NOT EXISTS (
        SELECT 1
        FROM study.WeightManagementMMAData r
        WHERE r.Id = l.Id
          AND r.code = 'P-YY960'
          AND r.date > b.date
    )
)

/*SELECT
    w.lsid,
    w.Id,
    w.date,
    w.Id.MostRecentWeight.MostRecentWeightDate as LatestWeightDate,
    w.Id.MostRecentWeight.MostRecentWeight AS LatestWeight,

    timestampdiff('SQL_TSI_DAY', w.date, w.Id.MostRecentWeight.MostRecentWeightDate) AS IntervalInDays,
    age_in_months(w.date, w.Id.MostRecentWeight.MostRecentWeightDate) AS IntervalInMonths,

    w.weight,
    CASE WHEN w.date >= timestampadd('SQL_TSI_DAY', -730, w.Id.MostRecentWeight.MostRecentWeightDate) THEN
             Round(((w.Id.MostRecentWeight.MostRecentWeight - w.weight) * 100 / w.weight), 1)
         ELSE
             null
        END  AS PctChange,

    CASE WHEN w.date >= timestampadd('SQL_TSI_DAY', -730, w.Id.MostRecentWeight.MostRecentWeightDate) THEN
             Abs(Round(((w.Id.MostRecentWeight.MostRecentWeight - w.weight) * 100 / w.weight), 1))
         else
             null
        END  AS AbsPctChange,
    w.qcstate
FROM study.weight w
WHERE w.Id.curlocation.area NOT IN ('Shelters', 'Corral', 'Hospital')-- Exclude animals from these locations
  AND NOT (-- Exclude females under 5yrs, males under 7yrs
    (w.Id.demographics.gender.code = 'f' AND w.Id.age.ageInYears < 5)
        OR (w.Id.demographics.gender.code = 'm' AND w.Id.age.ageInYears < 7)
    )
  AND w.qcstate.publicdata = true
  AND NOT EXISTS (
    -- -- Find animals whose latest 'Weight MMA BEGIN' has no later 'Weight MMA RELEASE'
    SELECT 1
    FROM study.WeightManagementMMAData b
    WHERE b.Id = w.Id
      AND b.code = 'P-YY961'
      AND b.date = (
        SELECT MAX(b2.date)
        FROM study.WeightManagementMMAData b2
        WHERE b2.Id = w.Id
          AND b2.code = 'P-YY961'
    )
      AND NOT EXISTS (
        SELECT 1
        FROM study.WeightManagementMMAData r
        WHERE r.Id = w.Id
          AND r.code = 'P-YY960'
          AND r.date > b.date
    )
 )

