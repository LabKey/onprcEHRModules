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
Select
    d.Id.curlocation.area as Area,
    d.Id.curlocation.room as Room,
    d.Id.curlocation.cage as Cage,
    d.Id,
    d.Id.utilization.use as ProjectsAndGroups,
    d.species,
    d.geographic_origin,
    d.gender as Sex,
    d.calculated_status,
    d.birth,
    d.Id.Age.YearAndDays,
    d.Id.MostRecentWeight.MostRecentWeight,
    d.Id.MostRecentWeight.MostRecentWeightDate,
    d.Id.viral_status.viralStatus,
    d.history
From Demographics d
Where d.Id Not In (
    SELECT DISTINCT t.Id
    FROM study.WeightManagementMMAData t
    WHERE NOT EXISTS (
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
                            AND r.date > b.date))
)
  AND d.Id.curlocation.area NOT IN ('Shelters', 'Corral', 'Hospital')-- Exclude animals from these locations
