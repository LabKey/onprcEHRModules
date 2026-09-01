WITH ruleData AS (
    SELECT
        rowid,
        CASE
            WHEN (userId IS NOT NULL AND Room IS NOT NULL AND Area IS NULL AND Project IS NULL AND Protocol IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Area IS NOT NULL AND Room IS NULL AND Project IS NULL AND Protocol IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Project IS NOT NULL AND Room IS NOT NULL AND Area IS NULL AND Protocol IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Project IS NOT NULL AND Room IS NOT NULL AND Area IS NULL AND Protocol IS NULL AND Priority = false) THEN 1
            WHEN (userId IS NOT NULL AND Project IS NOT NULL AND Area IS NOT NULL AND Room IS NULL AND Protocol IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Project IS NOT NULL AND Area IS NOT NULL AND Room IS NULL AND Protocol IS NULL AND Priority = false) THEN 1
            WHEN (userId IS NOT NULL AND Project IS NOT NULL AND Area IS NULL AND Room IS NULL AND Protocol IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Project IS NOT NULL AND Area IS NULL AND Room IS NULL AND Protocol IS NULL AND Priority = false) THEN 1
            WHEN (userId IS NOT NULL AND Protocol.DisplayName IS NOT NULL AND Room IS NOT NULL AND Area IS NULL AND Project IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Protocol.DisplayName IS NOT NULL AND Area IS NOT NULL AND Room IS NULL AND Project IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Protocol.DisplayName IS NOT NULL AND Room IS NOT NULL AND Area IS NULL AND Project IS NULL AND Priority = false) THEN 1
            WHEN (userId IS NOT NULL AND Protocol.DisplayName IS NOT NULL AND Area IS NOT NULL AND Room IS NULL AND Project IS NULL AND Priority = false) THEN 1
            WHEN (userId IS NOT NULL AND Protocol.DisplayName IS NOT NULL AND Area IS NULL AND Room IS NULL AND Project IS NULL AND Priority = true) THEN 1
            WHEN (userId IS NOT NULL AND Protocol.DisplayName IS NOT NULL AND Area IS NULL AND Room IS NULL AND Project IS NULL AND Priority = false) THEN 1
            WHEN (userId IS NOT NULL AND Room IS NOT NULL AND Area IS NULL AND Protocol IS NULL AND Project IS NULL AND Priority = false) THEN 1
            WHEN (userId IS NOT NULL AND Area IS NOT NULL AND Room IS NULL AND Protocol IS NULL AND Project IS NULL AND Priority = false) THEN 1
            ELSE 0
            END AS valid
    FROM onprc_ehr.vet_assignment
)
SELECT
    userId,
    project,
    protocol,
    area,
    room,
    priority
FROM onprc_ehr.vet_assignment
WHERE rowid IN (SELECT rowid FROM ruleData WHERE valid = 0)
