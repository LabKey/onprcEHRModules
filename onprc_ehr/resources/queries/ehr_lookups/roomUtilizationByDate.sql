/* Added by: Kollil, 9/29/2025, Refer tkt # 13276
Created a query that mimics the Room Utilization Report with the With PI Projects view, but with the additional feature
that it can be run for arbitrary prior dates.
 Lisa requested this new reports and is very useful
 */
PARAMETERS (SnapshotDate TIMESTAMP)

SELECT
    r.room,
   -- p.SnapDate AS SnapshotDate,   -- echoes the effective date
    COUNT(DISTINCT c.cage) AS TotalCages,
    MAX(cbr.availableCages) AS AvailableCages,
    MAX(cbr.markedUnavailable) AS MarkedUnavailable,
    COUNT(DISTINCT h.cage) AS CagesUsed,
    MAX(cbr.availableCages) - COUNT(DISTINCT h.cage) - MAX(cbr.markedUnavailable) AS CagesEmpty,
    ROUND(
            (
                (CAST(COUNT(DISTINCT h.cage) AS DOUBLE) + MAX(cbr.markedUnavailable))
                    / NULLIF(CAST(MAX(cbr.availableCages) AS DOUBLE), 0)
                ) * 100.0, 1
    ) AS pctUsed,
    COUNT(DISTINCT h.id) AS TotalAnimals
FROM ehr_lookups.rooms r
-- bind the parameter once; default to today when blank
         LEFT JOIN (
    SELECT COALESCE(SnapshotDate, now()) AS SnapDate
) p ON 1=1

         LEFT JOIN (
    SELECT c1.room, c1.cage
    FROM ehr_lookups.cage c1
    WHERE c1.cage IS NOT NULL
    UNION ALL
    SELECT r2.room, NULL AS cage
    FROM ehr_lookups.rooms r2
) c ON r.room = c.room

         LEFT JOIN study.housing h
                   ON r.room = h.room
                       AND (c.cage = h.cage OR (c.cage IS NULL AND h.cage IS NULL))
                       AND h.date <= p.SnapDate
                       AND (h.enddate IS NULL OR h.enddate > p.SnapDate)

         LEFT JOIN ehr_lookups.availableCagesByRoom cbr
                   ON cbr.room = r.room
WHERE r.datedisabled IS NULL
GROUP BY r.room, p.SnapDate
ORDER BY r.room;