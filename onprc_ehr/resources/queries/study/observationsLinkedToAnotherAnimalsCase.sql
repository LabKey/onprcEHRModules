WITH Observations AS (
    SELECT
        o.Id,
        o.caseid,
        o.caseid.id.id        AS linkid,
        o.caseid.caseNo       AS linkCaseNo,
        o.caseid._key         AS linkCaseKey,
        o.caseid.date         AS linkCaseDate,
        o.taskid,
        o.performedby,
        o.date,
        o.created,

        NULLIF(o.category, 'Observations') AS category,
        NULLIF(o.area, 'N/A')               AS area,

        CASE
            WHEN o.category IS NULL AND o.observation IS NOT NULL
                THEN o.observation
            WHEN o.category IS NOT NULL AND o.observation IS NULL
                THEN o.category
            WHEN o.category IS NOT NULL AND o.area IS NULL
                THEN (o.category || ': ' || o.observation)
            WHEN o.category IS NOT NULL AND o.area IS NOT NULL
                THEN (o.category || ': ' || o.area || ', ' || o.observation)
            ELSE NULL
            END
            ||
        COALESCE(
                CASE
                    WHEN o.remark IS NOT NULL AND o.observation IS NOT NULL
                        THEN ('. ' || o.remark)
                    ELSE o.remark
                    END,
                ''
        ) AS observation_string
    FROM study.clinical_observations o
    WHERE
        o.caseid IS NOT NULL
      AND o.category NOT IN ('Vet Review', 'Reviewed')
      AND o.id <> o.caseid.id.id   -- MUCH faster than NOT LIKE
),

    AggregatedObservations AS (
        SELECT
            Id,
            caseid,
            linkid,
            linkCaseNo,
            linkCaseKey,
            linkCaseDate,
            taskid,
            performedby,
    date,
    MIN(created) AS created,
    GROUP_CONCAT(
    CAST(observation_string AS VARCHAR(1000)),
    '; '
    ) AS observations
FROM Observations
GROUP BY
    Id,
    caseid,
    linkid,
    linkCaseNo,
    linkCaseKey,
    linkCaseDate,
    taskid,
    performedby,
    date
    ),

    AnimalCases AS (
SELECT
    ao.*,
    c.category,
    c.caseNo,
    c.objectId AS key
FROM AggregatedObservations ao
    LEFT JOIN study.cases c
ON c.Id = ao.Id
    AND ao.created >= c.date
    AND (ao.created <= c.enddate OR c.enddate IS NULL)
    )

SELECT
    Id           AS ObsAnimalId,
    date,
    created,
    observations,
    taskid,
    performedby,
    linkid       AS LinkedCaseAnimalId,
    caseid       AS linkedCaseCategory,
    linkCaseNo,
    linkCaseKey,
    linkCaseDate,
    GROUP_CONCAT(category, ', ') AS openCasesAtObsCreation,
    GROUP_CONCAT(caseNo, ', ')   AS openCaseNosAtObsCreation,
    GROUP_CONCAT(key, ', ')      AS openCaseKeysAtObsCreation
FROM AnimalCases
GROUP BY
    Id,
    date,
    created,
    observations,
    taskid,
    performedby,
    linkid,
    caseid,
    linkCaseNo,
    linkCaseKey,
    linkCaseDate