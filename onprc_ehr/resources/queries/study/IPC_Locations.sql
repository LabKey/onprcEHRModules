SELECT room
From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr_lookups.rooms
Where dateDisabled is null order by room