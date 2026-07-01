/*
 Added by Kolli, Feb 2026
 Refer tkt# 14114 for details
 Display 4 columns: Animal Id, Area, Genetic dam, Observed dam

 Get genetic and observed dam mismatch data.
 Use the following criteria,
 * 1. One genetic dam per animal
 * 2. Included Alive + Dead animals
 * 3. Excludes animals that have a foster dam
 * 4. Excludes rows where observedDam or geneticDam IS BLANK
 * 5. Keeps only mismatches between observed and genetic dams
 * 6. Excludes old parentage entries, enddate IS BLANK
*/

/*
 Modifications by Kolli, June 2026
 Refer tkt# 14891 for details

 * 1. Remove cases in which the ID has a surrogate dam entered in prime. (There are several but 41043 is one example)
 * 2. Remove cases in which the observed dam is "unknown"
 * 3. Remove cases in which the observed dam ID is not an ONPRC. E.g. there are several NEPRC IDs of the format ###-####.
 */

SELECT
    d.Id,
    d.Id.curLocation.area AS Area,
    gd.geneticDam,
    b.dam AS observedDam

FROM study.demographics d

LEFT JOIN (
    SELECT
        p.Id,
        MAX(p.parent) AS geneticDam
    FROM study.parentage p
    WHERE p.relationship = 'Dam'
      AND p.method IN ('Genetic', 'Provisional Genetic')
      AND p.enddate IS NULL
    GROUP BY p.Id
) gd
    ON gd.Id = d.Id

LEFT JOIN study.birth b
    ON b.Id = d.Id

WHERE d.calculated_status.code IN ('Alive', 'Dead')
  AND d.qcstate = 18

    /* exclude animals with active Foster Dam */
  AND NOT EXISTS (
    SELECT 1
    FROM study.parentage fd
    WHERE fd.Id = d.Id
      AND fd.relationship = 'Foster Dam'
      AND fd.enddate IS NULL
      AND COALESCE(RTRIM(LTRIM(CAST(fd.parent AS VARCHAR(50)))), '') <> ''
  )

    /* exclude animals with active Surrogate Dam */
  AND NOT EXISTS (
    SELECT 1
    FROM study.parentage sd
    WHERE sd.Id = d.Id
      AND sd.relationship = 'Surrogate Dam'
      AND sd.enddate IS NULL
      AND COALESCE(RTRIM(LTRIM(CAST(sd.parent AS VARCHAR(50)))), '') <> ''
  )

    /* observed dam is not blank */
  AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') <> ''

    /* observed dam is not unknown */
  AND LOWER(COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '')) <> 'unknown'

    /* observed dam is an ONPRC ID, not external format like ###-#### */
  AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') NOT LIKE '%-%'

    /* genetic dam is not blank */
  AND COALESCE(RTRIM(LTRIM(CAST(gd.geneticDam AS VARCHAR(50)))), '') <> ''

    /* observed dam does not match genetic dam */
  AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') <>
      COALESCE(RTRIM(LTRIM(CAST(gd.geneticDam AS VARCHAR(50)))), '');


-- SELECT
--     d.Id,
--     d.Id.curLocation.area AS Area,
--     coalesce(p2.parent, '') as geneticDam,
--     coalesce(b.dam, '') as observedDam
-- FROM study.demographics d
--
--     LEFT JOIN (
--     SELECT
--         p2.Id,
--         MAX(p2.parent) AS parent
--     FROM study.parentage p2
--     WHERE (p2.method = 'Genetic' OR p2.method = 'Provisional Genetic')
--       AND p2.relationship = 'Dam'
--       AND p2.enddate IS NULL
--     GROUP BY p2.Id
-- ) p2 ON d.Id = p2.Id
--
--     LEFT JOIN (
--     SELECT
--         p3.Id,
--         MAX(p3.parent) AS parent
--     FROM study.parentage p3
--     WHERE p3.relationship = 'Foster Dam'
--       AND p3.enddate IS NULL
--     GROUP BY p3.Id
-- ) p3 ON d.Id = p3.Id
--
--     LEFT JOIN study.birth b
--         ON b.Id = d.Id
--
-- WHERE d.calculated_status.code IN ('Alive', 'Dead') AND d.qcstate = 18
--     /* exclude foster-dam cases (NULL or blank only) */
--   AND COALESCE(RTRIM(LTRIM(CAST(p3.parent AS VARCHAR(50)))), '') = ''
--
--     /* 1. exclude animals with active Surrogate Dam entered */
--   AND NOT EXISTS (
--     SELECT 1
--     FROM study.parentage sd
--     WHERE sd.Id = d.Id
--       AND sd.relationship = 'Surrogate Dam'
--       AND sd.enddate IS NULL
--       AND COALESCE(RTRIM(LTRIM(CAST(sd.parent AS VARCHAR(50)))), '') <> ''
-- )
--
--     /* 2. exclude observed dam = unknown */
--   AND LOWER(COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '')) <> 'unknown'
--
--     /* 3. exclude observed dam IDs that are not ONPRC IDs, e.g. NEPRC ###-#### */
--   AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') NOT LIKE '%-%'
--
--     /* exclude blank observed dam */
--   AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') <> ''
--
--     /* exclude blank genetic dam */
--   AND COALESCE(RTRIM(LTRIM(CAST(p2.parent AS VARCHAR(50)))), '') <> ''
--
--     /* mismatch observed vs genetic */
--   AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') <>
--       COALESCE(RTRIM(LTRIM(CAST(p2.parent AS VARCHAR(50)))), '')
--
--
