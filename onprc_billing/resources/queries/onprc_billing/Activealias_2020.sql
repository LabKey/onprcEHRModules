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