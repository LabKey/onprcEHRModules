SELECT value, name from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.IPC_Reference_Data
Where name like 'IPCIHC' and dateDisabled is null