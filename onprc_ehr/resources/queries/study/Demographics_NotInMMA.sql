/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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

SELECT
    d.Id.curlocation.area AS Area,
    d.Id.curlocation.room AS Room,
    d.Id.curlocation.cage AS Cage,
    d.Id,
    d.Id.utilization.use AS ProjectsAndGroups,
    d.species,
    d.geographic_origin,
    d.gender AS Sex,
    d.calculated_status,
    d.birth,
    d.Id.Age.YearAndDays,
    d.Id.MostRecentWeight.MostRecentWeight,
    d.Id.MostRecentWeight.MostRecentWeightDate,
    d.Id.viral_status.viralStatus,
    d.history
FROM Demographics d
WHERE d.Id.curlocation.area NOT IN ('Shelters', 'Corral', 'Hospital', 'Catch Area')-- Exclude animals from these locations
  AND NOT (-- Exclude females under 5yrs, males under 7yrs
    (d.gender.code = 'f' AND d.Id.age.ageInYears < 5)
        OR (d.gender.code = 'm' AND d.Id.age.ageInYears < 7)
    )
  AND NOT EXISTS (
    -- -- Find animals whose latest 'Weight MMA BEGIN' has no later 'Weight MMA RELEASE'
    SELECT 1
    FROM study.WeightMMA b
    WHERE b.Id = d.Id
      AND b.code = 'P-YY961'
      AND b.date = (
        SELECT MAX(b2.date)
        FROM study.WeightMMA b2
        WHERE b2.Id = d.Id
          AND b2.code = 'P-YY961'
    )
      AND NOT EXISTS (
        SELECT 1
        FROM study.WeightMMA r
        WHERE r.Id = d.Id
          AND r.code = 'P-YY960'
          AND r.date > b.date
    )
)