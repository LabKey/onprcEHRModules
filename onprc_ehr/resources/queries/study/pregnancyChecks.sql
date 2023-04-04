/*
 By Lakshmi Kolli, 3/27/2023
 Monkeys needing pregnancy checks:
Exclude monkeys who have been assessed and found to be nonpregnant- maybe exclude 'nonpregnant state'
from the SNOMED code or exclude those with a procedure: ultrasound or procedure: ultrasound-uterus in the record in the last 30 days?

Filter criteria
Status = alive
Gender = female
Age = greater than or equal to 2.5 years
# Research assignments = 0
Days since last group assignment (DLG) = greater than or equal to 21 AND less than or equal to 175
Est Delivery Date = blank
Area = does not equal Corrals; Shelters; ASB ESPF; Catch Area; Harem
Cage = is not blank

Report columns for notification:
ID
Species
Age
Project(s)
Current weight (kg)
Area
Room
Cage
Active notes
Pregnancies-active: observations/tests
Days since last group assignment
 */
-- SELECT
--     d.id,
--     d.species,
--     d.gender,
--     d.birth,
--     d.project,
--     d.Id.MostRecentWeight,
--     d.Id.curlocation.area,
--     d.Id.curlocation.room,
--     d.Id.curlocation.cage,
--     --d.mostRecentHx,
--     (Select ActiveNotes From demographicsActiveNotes Where Id = d.Id ) as ActiveNotes,
--     d.mostRecentClinicalObservations,
--     p.estDeliveryDate
--     ,(Select TIMESTAMPDIFF('SQL_TSI_DAY', endDate, now()) From pregnancyChecks_LastGroupAssignment Where Id = d.Id ) as DaysSinceLastGroupAssignment
--     --(Select count(*) from assignment Where Now() > date And enddate IS NULL and Id = d.Id) as num_projects
-- FROM study.demographics d, study.pregnancyConfirmation p
-- WHERE d.calculated_status = 'Alive'
--   AND TIMESTAMPDIFF('SQL_TSI_MONTH', d.birth, now()) >= 29 --greater than 2.5years
--   AND d.id = p.id
--   AND d.gender = 'F'
--   AND p.estDeliveryDate IS NULL
--   AND d.Id.curlocation.area NOT IN ('Corral', 'Shelters', 'ASB ESPF', 'Catch Area', 'Harem')
--   AND d.Id.curlocation.cage IS NOT NULL
--   AND d.Id NOT IN (Select Id From assignment Where Now() > date And enddate IS NULL) --# Research assignments = 0
--   AND d.Id NOT IN (Select Id From ehr.snomed_tags Where code like 'F-30980') -- Exclude animals with snomed 'non pregnanct state'
-- -- exclude those with a procedure: ultrasound or procedure: ultrasound-uterus or ultrasound - Pregnant in the record in the last 30 days?
--   AND d.Id NOT IN (Select Id From study.encounters Where procedureId in (799, 763, 873) And TIMESTAMPDIFF('SQL_TSI_DAY', date, now()) <= 30 )
--
Select * from demographics_FemalePregnancyChecks