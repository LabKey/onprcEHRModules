SELECT value, name from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.PMIC_Reference_Data
Where name like 'WetLabUse' and dateDisabled is null