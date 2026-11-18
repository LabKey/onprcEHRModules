/*
 * Copyright (c) 2024-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT  Id,
--         Id.demographics.gender as Sex,
        CASE
            WHEN Id.demographics.gender = 'F' THEN 'Female'
            WHEN Id.demographics.gender = 'M' THEN 'Male'
            ELSE 'Unknown'
            END AS Sex,
        Id.Age.ageinyearsrounded as AgeInYearsRounded,
        project.name as project,
        project.protocol.investigatorId.lastname as Investigator,
        project.title as Title,
        date,
        enddate,
        projectedRelease,
        (Select meaning from ehr_lookups.animal_condition where code = assignment.projectedReleaseCondition) as projectedReleaseCondition,
        (Select meaning from ehr_lookups.animal_condition where code = assignment.assignCondition) as assignCondition,
        (Select meaning from ehr_lookups.animal_condition where code = assignment.releaseCondition) as releaseCondition,
FROM assignment
Where projectedReleaseCondition = 206 --'Terminal'
And date <= curdate() and date >= timestampadd(SQL_TSI_DAY, -35, curdate())

