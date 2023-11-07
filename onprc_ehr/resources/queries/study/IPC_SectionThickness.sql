SELECT value, name from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.IPC_Reference_Data
Where name like 'IPCSectionThickness' and dateDisabled is null