/*
 Added by Kolli, Feb 2026
 Refer tkt# 14114
 Get data where genetic and observed dam do not match, AND foster dam ISBLANK AND Observed Dam IS NOT BLANK
*/

SELECT
    d.Id,
    d.Id.curLocation.area AS Area,
    coalesce(p2.parent, '') as geneticDam,
    coalesce(b.dam, '') as observedDam

FROM study.demographics d

LEFT JOIN (
    SELECT
        p2.Id,
        MAX(p2.parent) AS parent
    FROM study.parentage p2
    WHERE (p2.method = 'Genetic' OR p2.method = 'Provisional Genetic')
      AND p2.relationship = 'Dam'
    GROUP BY p2.Id
) p2 ON d.Id = p2.Id

LEFT JOIN (
    SELECT
        p3.Id,
        MAX(p3.parent) AS parent
    FROM study.parentage p3
    WHERE p3.relationship = 'Foster Dam'
    GROUP BY p3.Id
) p3 ON d.Id = p3.Id

LEFT JOIN study.birth b
       ON b.Id = d.Id

WHERE d.calculated_status.code IN ('Alive', 'Dead') AND d.qcstate = 18
    /* exclude foster-dam cases (NULL or blank only) */
    AND COALESCE(RTRIM(LTRIM(CAST(p3.parent AS VARCHAR(50)))), '') = ''

    /* exclude blank observed dam */
    AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') <> ''

    /* exclude blank genetic dam */
    AND COALESCE(RTRIM(LTRIM(CAST(p2.parent AS VARCHAR(50)))), '') <> ''

    /* mismatch observed vs genetic */
    AND COALESCE(RTRIM(LTRIM(CAST(b.dam AS VARCHAR(50)))), '') <>
      COALESCE(RTRIM(LTRIM(CAST(p2.parent AS VARCHAR(50)))), '')


-- SELECT
--     Id,
--     Area,
--     geneticdam,
--     observeddam
-- FROM ParentageCompleted
-- WHERE
--     /* treat NULL or blank foster dam as "no foster dam" */
--     (
--         fosterdam IS NULL
--         OR RTRIM(LTRIM(CAST(fosterdam AS VARCHAR))) = ''
--     )
--
--     /* exclude blank observed dam */
--      AND COALESCE(RTRIM(LTRIM(CAST(observeddam AS VARCHAR(50)))), '') <> ''
--   AND
--     /* mismatch, treating NULL as empty and trimming whitespace */
--     RTRIM(LTRIM(COALESCE(CAST(observeddam AS VARCHAR), '')))
--         <>
--     RTRIM(LTRIM(COALESCE(CAST(geneticdam AS VARCHAR), '')))
--
