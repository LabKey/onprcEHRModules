-- ✅ LabKey-Compatible Optimized PotentialDam Query (Last 1 Year)
-- Filters to births within the last 12 months
--reload as FB named

WITH ValidBirthRecords AS (
    SELECT
        b.participantid,
        b.date,
        b.species,
        b.room,
        b.cage,
        b.dam,
        d1.participantid AS BornAnimalParticipantID,
        d1.birth AS BornAnimalBirth,
        d1.gender AS BornAnimalGender,
        d1.species AS BornAnimalSpecies,
        d1.death AS BornAnimalDeath
    FROM study.birth b
             INNER JOIN study.demographics d1
                        ON d1.participantID = b.participantid
    WHERE b.date IS NOT NULL
      AND b.date >= TIMESTAMPADD('SQL_TSI_YEAR', -1, now())  -- ✅ limit to past 1 year
      AND b.date <= now()
      AND d1.death IS NULL
      AND NOT EXISTS (
        SELECT 1
        FROM study.birth b2
        WHERE b2.participantid = b.participantid
          AND b2.date > b.date
    )
),

     FemalesSuitableAge AS (
         SELECT
             participantid,
             birth,
             gender,
             species,
             death,
             CASE WHEN death IS NULL THEN 'Active' ELSE 'Deceased' END AS Status,
             TIMESTAMPDIFF('SQL_TSI_YEAR', birth, now()) AS CurrentAgeYears
         FROM study.demographics
         WHERE gender = 'f'
           AND birth IS NOT NULL
           AND death IS NULL
     ),

     HousingRecords AS (
         SELECT
             participantid,
             date,
             enddate,
             room,
             cage,
             TIMESTAMPDIFF('SQL_TSI_DAY', date, COALESCE(enddate, now())) AS HousingDurationDays,
             CASE
                 WHEN enddate IS NULL THEN 'Current'
                 WHEN enddate >= now() THEN 'Active'
                 ELSE 'Historical'
                 END AS HousingStatus
         FROM study.housing
         WHERE date IS NOT NULL
     ),

     PotentialDams AS (
         SELECT
             br.participantid AS BirthParticipantID,
             br.date AS BirthDate,
             br.species AS BornAnimalSpecies,
             br.room AS BirthRoom,
             br.cage AS BirthCage,
             d.participantid AS DamParticipantID,
             d.birth AS DamBirth,
             d.gender AS DamGender,
             d.species AS DamSpecies,
             d.death AS DamDeath,
             d.Status AS DamStatus,
             d.CurrentAgeYears,
             TIMESTAMPDIFF('SQL_TSI_DAY', d.birth, br.date) / 365.0 AS DamAgeAtTime,
             CASE
                 WHEN d.participantid = br.dam THEN 'KnownDam'
                 WHEN h.participantid IS NOT NULL THEN 'CoHoused'
                 ELSE 'Unknown'
                 END AS MatchType,
             h.room AS HousingRoom,
             h.cage AS HousingCage,
             h.HousingStatus,
             h.HousingDurationDays
         FROM ValidBirthRecords br
                  INNER JOIN FemalesSuitableAge d
                             ON d.species = br.BornAnimalSpecies
                                 AND TIMESTAMPDIFF('SQL_TSI_DAY', d.birth, br.date) > 912
                  LEFT JOIN HousingRecords h
                            ON h.participantid = d.participantid
                                AND h.date <= br.date
                                AND (h.enddate IS NULL OR h.enddate >= br.date)
                                AND h.room = br.room
                                AND (h.cage = br.cage OR (h.cage IS NULL AND br.cage IS NULL))
         WHERE d.participantid = br.dam
            OR h.participantid IS NOT NULL
     ),

     BestDamPerBirth AS (
         SELECT
             pd1.BirthParticipantID,
             pd1.BirthDate,
             pd1.DamParticipantID,
             pd1.DamBirth,
             pd1.DamGender,
             pd1.DamSpecies,
             pd1.DamDeath,
             pd1.DamStatus,
             pd1.CurrentAgeYears,
             pd1.DamAgeAtTime,
             pd1.MatchType,
             pd1.HousingRoom,
             pd1.HousingCage,
             pd1.HousingStatus,
             pd1.HousingDurationDays,
             pd1.BornAnimalSpecies,
             pd1.BirthRoom,
             pd1.BirthCage,
             (SELECT COUNT(*)
              FROM PotentialDams pd2
              WHERE pd2.BirthParticipantID = pd1.BirthParticipantID
                AND pd2.BirthDate = pd1.BirthDate) AS TotalPotentialDams
         FROM PotentialDams pd1
         WHERE NOT EXISTS (
             SELECT 1
             FROM PotentialDams pd2
             WHERE pd2.BirthParticipantID = pd1.BirthParticipantID
               AND pd2.BirthDate = pd1.BirthDate
               AND pd2.MatchType = 'KnownDam'
         )
           AND NOT EXISTS (
             SELECT 1
             FROM PotentialDams pd3
             WHERE pd3.BirthParticipantID = pd1.BirthParticipantID
               AND pd3.BirthDate = pd1.BirthDate
               AND pd3.MatchType = pd1.MatchType
               AND COALESCE(pd3.HousingDurationDays, 0) > COALESCE(pd1.HousingDurationDays, 0)
         )
     ),

     DamValidation AS (
         SELECT
             BirthParticipantID,
             BirthDate,
             DamParticipantID,
             DamBirth,
             DamGender,
             DamSpecies,
             DamDeath,
             DamStatus,
             CurrentAgeYears,
             DamAgeAtTime,
             MatchType,
             HousingRoom,
             HousingCage,
             HousingStatus,
             HousingDurationDays,
             TotalPotentialDams,
             CASE
                 WHEN DamStatus = 'Deceased' THEN 'WARNING: Dam is deceased'
                 WHEN DamAgeAtTime < 2.5 THEN 'WARNING: Dam age below 2.5 years'
                 WHEN DamAgeAtTime > 20 THEN 'WARNING: Dam age above 20 years'
                 WHEN MatchType = 'Unknown' THEN 'WARNING: No housing or known dam match'
                 WHEN MatchType = 'KnownDam' AND HousingStatus IS NULL THEN 'INFO: Known dam, no housing record'
                 ELSE 'Valid'
                 END AS ValidationStatus,
             CASE
                 WHEN MatchType = 'KnownDam' THEN 1.0
                 WHEN HousingDurationDays >= 30 THEN 1.0
                 WHEN HousingDurationDays >= 7 THEN 0.5
                 ELSE 0.0
                 END AS ConfidenceScore
         FROM BestDamPerBirth
     )

SELECT
    BirthParticipantID,
    BirthDate,
    DamParticipantID,
    DamBirth,
    DamGender,
    DamSpecies,
    DamDeath,
    DamStatus,
    CurrentAgeYears,
    DamAgeAtTime,
    MatchType,
    HousingRoom,
    HousingCage,
    HousingStatus,
    HousingDurationDays,
    TotalPotentialDams,
    ValidationStatus,
    ConfidenceScore,
    now() AS CreatedDate,
    1011 AS CreatedByUserID,
    now() AS ModifiedDate,
    1011 AS ModifiedByUserID,
    'CD17027B-C55F-102F-9907-5107380A54BE' AS RecordID
FROM DamValidation
ORDER BY BirthParticipantID, BirthDate;
