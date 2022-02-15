SELECT displayname as name
From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.Reference_StaffNames
Where Type like 'Necropsy' and DisableDate is null
