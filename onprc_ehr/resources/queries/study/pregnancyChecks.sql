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

SELECT
    d.id,
    d.species,
    d.gender,
    d.geographic_origin,
    d.Id.age.ageInYears,
    d.Id.currentCondition.condition,
    d.Id.spfStatus.status,
    d.Id.activeAssignments.projectAndInvestigator,
    d.Id.activeAssignments.numResearchAssignments,
    d.Id.MostRecentWeight.DaysSinceWeight,
    d.Id.MostRecentWeight,
    d.Id.curlocation.area,
    d.Id.curlocation.room,
    d.Id.curlocation.cage,
    d.Id.activeNoteList.Notes,
    d.Id.activepregnancies.estDeliveryDate,
    d.Id.historicAnimalGroups.daysSinceLastAssignment
FROM study.demographics d
WHERE d.calculated_status = 'Alive'
    AND d.Id.age.ageInYears >= 2.5 --greater than 2.5years
    AND d.gender = 'F'
    AND d.Id.activepregnancies.estDeliveryDate IS NULL
    AND d.Id.curlocation.area NOT IN ('Corral', 'Shelters', 'ASB ESPF', 'Catch Area', 'Harem')
    AND d.Id.curlocation.cage IS NOT NULL
    AND d.Id.historicAnimalGroups.daysSinceLastAssignment between 20 and 176
    AND d.Id.activeAssignments.numResearchAssignments = 0 --# Research assignments = 0
    --AND d.Id NOT IN (Select Id From ehr.snomed_tags Where code like 'F-30980') -- Exclude animals with snomed 'non pregnanct state'
    -- exclude those with a procedure: ultrasound or procedure: ultrasound-uterus or ultrasound - Pregnant in the record in the last 30 days?
    AND d.Id NOT IN (Select Id From study.encounters Where procedureId in (799, 763, 873) And TIMESTAMPDIFF('SQL_TSI_DAY', date, now()) <= 30 )
    AND d.Id NOT IN (Select Id From study.pregnancyConfirmation Where confirmationType = 428 And TIMESTAMPDIFF('SQL_TSI_DAY', date, now()) <= 30 )
    -- Added above filter to identify the animals where they had pregnancy confirmation within 30 days,
    -- this is to catch any missing US procedure entries into the encounters table