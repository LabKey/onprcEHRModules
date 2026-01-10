/*
 Created by Kollil in Dec 2025
 Tkt # 13461
 This query is the ONPRC version of the core LK EHR query called, weightRelChange. In addition to the original one, this new query has two filters:
 1. Filter out any animal with the following SNOMED Codes:
    Begin active weight management regimen (P-YY961)
    However, we would need to include animals that have this additional SNOMED Code if it's entered AFTER the one above
    Release from active weight management regimen (P-YY960)
 2. Remove Shelters, Corral and Hospital locations from the lists
  */
SELECT
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
WHERE w.qcstate.publicdata = true
  AND d.Id.curlocation.area NOT IN ('Shelters', 'Corral', 'Hospital')-- Exclude animals from these locations
  AND NOT ( --exclude females under 5yrs, males under 7yrs
    (d.gender.code = 'f' AND d.Id.age.ageInYears < 5)
    OR (d.gender.code = 'm' AND d.Id.age.ageInYears < 7)
    )
  AND w.Id NOT IN
      (SELECT DISTINCT t.Id
       FROM study.WeightManagementMMAData t
       WHERE NOT EXISTS
                 (
                     -- Find animals whose latest 'Weight MMA BEGIN' has no later 'Weight MMA RELEASE'
                     SELECT 1
                     FROM study.WeightManagementMMAData b
                     WHERE b.Id = t.Id
                       AND b.code = 'P-YY961'
                       AND b.date = (SELECT MAX(b2.date)
                                     FROM study.WeightManagementMMAData b2
                                     WHERE b2.Id = t.Id
                                       AND b2.code = 'P-YY961')
                       AND NOT EXISTS (SELECT 1
                                       FROM study.WeightManagementMMAData r
                                       WHERE r.Id = t.Id
                                         AND r.code = 'P-YY960'
                                         AND r.date > b.date)
                 )
      )
