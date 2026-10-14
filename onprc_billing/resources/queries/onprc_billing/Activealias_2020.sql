/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT a.alias,
       a.category,
       a.aliasEnabled,
       a.projectNumber,
       a.grantNumber as OGAAwardNumber,
       a.agencyAwardNumber,
       a.investigatorId,
       a.investigatorName,
       a.fiscalAuthority,
       a.fiscalAuthorityName,
       a.budgetStartDate,
       a.budgetEndDate,
       a.faRate,
       a.faSchedule,
       a.projectTitle,
       a.projectDescription,
       a.projectStatus,
       a.aliasType,
       a.container,
       a.dateDisabled,
       a.Comments,
       a.PPQNumber,
       a.PPQDate,
       a.ApplicationTypeDescription,
       a.AwardStatus,
       a.AwardID,
       a.ApplicationType,
       a.ProjectID,
       a.ActivityType,
       a.AwardNumber,
       a.AwardSuffix,
       a.ADFMEmpNum,
       a.ADFMFullName,
       a.ActivityTypeDescription,
       a.FUndingSourceNumber,
       a.FUndingSourceName,
       a.Org
FROM aliases a 
where aliasEnabled = 'y' 