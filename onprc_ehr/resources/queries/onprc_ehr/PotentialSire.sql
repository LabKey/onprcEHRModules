/*
ULTRA-OPTIMIZED LABKEY VERSION
------------------------------
✅ 100% LabKey SQL compatible
✅ Keeps pre-filtering for minimal joins
✅ Avoids LabKey-incompatible functions
✅ Ready to run directly in LabKey Query Editor
QUery Validated and ran in Dev Instance
Reload  after bad Name
*/

WITH RecentBirths AS (
    SELECT
        b.participantid,
        b.date,
        b.species,
        b.room,
        b.cage,
        b.dam
    FROM study.birth b
             INNER JOIN study.demographics d1
                        ON d1.participantID = b.participantid
                            AND d1.death IS NULL
    WHERE b.date IS NOT NULL
      AND b.date BETWEEN TIMESTAMPADD('SQL_TSI_YEAR', -1, NOW()) AND NOW()
),
     BreedingMales AS (
         SELECT
             participantid,
             birth,
             gender,
             species,
             death
         FROM study.demographics
         WHERE gender = 'm'
           AND death IS NULL
           AND birth IS NOT NULL
           AND TIMESTAMPDIFF('SQL_TSI_DAY', birth, NOW()) > 912   -- approx. 2.5 years
     ),
     RelevantHousing AS (
         SELECT
             participantid,
             date,
             enddate,
             room,
             cage
         FROM study.housing
         WHERE date IS NOT NULL
           AND date >= TIMESTAMPADD('SQL_TSI_YEAR', -1, NOW())
     )
SELECT
    rb.participantid AS BirthParticipantID,
    rb.date AS BirthDate,
    rb.species AS BornAnimalSpecies,
    rb.room AS BirthRoom,
    rb.cage AS BirthCage,
    bm.participantid AS SireParticipantID,
    bm.birth AS SireBirth,
    bm.gender AS SireGender,
    bm.species AS SireSpecies,
    bm.death AS SireDeath,
    CASE WHEN bm.death IS NULL THEN 'Active' ELSE 'Deceased' END AS SireStatus,
    ROUND(TIMESTAMPDIFF('SQL_TSI_DAY', bm.birth, rb.date) / 365.0, 2) AS SireAgeAtTime,
    CASE
        WHEN bm.participantid = rb.dam THEN 'Dam'
        WHEN rh.participantid IS NOT NULL THEN 'Housing'
        ELSE 'Unknown'
        END AS MatchType,
    COALESCE(rh.room, '') AS HousingRoom,
    COALESCE(rh.cage, '') AS HousingCage,
    CASE
        WHEN rh.enddate IS NULL THEN 'Current'
        WHEN rh.enddate >= NOW() THEN 'Active'
        ELSE 'Historical'
        END AS HousingStatus,
    TIMESTAMPDIFF('SQL_TSI_DAY', rh.date, COALESCE(rh.enddate, NOW())) AS HousingDurationDays,
    CASE
        WHEN bm.death IS NOT NULL THEN 'WARNING: Sire is deceased'
        WHEN TIMESTAMPDIFF('SQL_TSI_DAY', bm.birth, rb.date) / 365.0 < 2.5 THEN 'WARNING: Sire age below 2.5 years'
        WHEN TIMESTAMPDIFF('SQL_TSI_DAY', bm.birth, rb.date) / 365.0 > 15 THEN 'WARNING: Sire age above 15 years'
        ELSE 'Valid'
        END AS ValidationStatus,
    NOW() AS CreatedDate,
    1011 AS CreatedByUserID,
    NOW() AS ModifiedDate,
    1011 AS ModifiedByUserID,
    'CD17027B-C55F-102F-9907-5107380A54BE' AS RecordID
FROM RecentBirths rb
         INNER JOIN BreedingMales bm
                    ON bm.species = rb.species
                        AND TIMESTAMPDIFF('SQL_TSI_DAY', bm.birth, rb.date) > 912
         LEFT JOIN RelevantHousing rh
                   ON rh.participantid = bm.participantid
                       AND rh.date <= rb.date
                       AND COALESCE(rh.enddate, NOW()) >= rb.date
                       AND rh.room = rb.room
                       AND (rh.cage = rb.cage OR (rh.cage IS NULL AND rb.cage IS NULL))
WHERE bm.participantid = rb.dam
   OR rh.participantid IS NOT NULL
ORDER BY rb.participantid, rb.date;
