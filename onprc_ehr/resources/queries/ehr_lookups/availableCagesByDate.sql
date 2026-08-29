-- Created by Kollil, Oct 2025
-- This query is a variation of the same one in the folder, but, with a date as parameter

PARAMETERS(SnapshotDate TIMESTAMP)

SELECT
    CASE WHEN c.cage IS NULL THEN c.room ELSE (c.room || '-' || c.cage) END AS location,
    c.room,
    c.cage,
    c.cagePosition.row,
    c.cagePosition.columnIdx,
    c.cage_type,
    lc.cage         AS lowerCage,
    lc.cage_type    AS lower_cage_type,
    lc.divider      AS divider,
    CASE
        WHEN c.cage_type = 'No Cage' THEN FALSE
        WHEN COALESCE(lc.divider.countAsSeparate, TRUE) = FALSE THEN FALSE
        ELSE TRUE
        END AS isAvailable,
    CASE WHEN c.status IS NOT NULL AND c.status = 'Unavailable' THEN 1 ELSE 0 END AS isMarkedUnavailable,
    -- Example: occupancy "as of" SnapshotDate from study.housing
    CASE WHEN h.Id IS NOT NULL THEN 1 ELSE 0 END AS isOccupiedAsOf,
    -- Echo the effective date we used (handy for debugging)
    COALESCE(SnapshotDate, NOW()) AS AsOfDate

FROM ehr_lookups.cage AS c

-- left-hand neighbor (structural)
         LEFT JOIN ehr_lookups.cage AS lc
                   ON c.room = lc.room
                       AND c.cagePosition.row = lc.cagePosition.row
                       AND c.cagePosition.columnIdx - 1 = lc.cagePosition.columnIdx
                       AND lc.cage_type <> 'No Cage'

-- time-varying occupancy example (adjust table/columns to your schema):
         LEFT JOIN study.housing AS h
                   ON h.room = c.room
                       AND ( (h.cage IS NULL AND c.cage IS NULL) OR h.cage = c.cage )
                       -- "as of" predicate using the parameter
                       AND h.date <= COALESCE(SnapshotDate, NOW())
                       AND (h.enddate IS NULL OR h.enddate > COALESCE(SnapshotDate, NOW()))

WHERE c.room.housingType.value = 'Cage Location'
