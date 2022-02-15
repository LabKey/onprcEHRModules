SELECT lastName + ', ' + firstName as name
From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.investigators
Where dateDisabled is null
