SELECT value, name, sort_order from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.StudyDetails_Reference_Data
where name like 'Study_Group' and dateDisabled is null