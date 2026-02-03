/*
 Added by Kolli, Feb 2026
 Refer tkt# 14114
 Get data where genetic and observed dam do not match, AND foster dam ISBLANK.
 */

SELECT
    Id,
    Area,
    geneticdam,
    observeddam
FROM ParentageCompleted
WHERE
    /* treat NULL or blank foster dam as "no foster dam" */
    (
        fosterdam IS NULL
        OR RTRIM(LTRIM(CAST(fosterdam AS VARCHAR))) = ''
    )
  AND
    /* mismatch, treating NULL as empty and trimming whitespace */
    RTRIM(LTRIM(COALESCE(CAST(observeddam AS VARCHAR), '')))
        <>
    RTRIM(LTRIM(COALESCE(CAST(geneticdam AS VARCHAR), '')))