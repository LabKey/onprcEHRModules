SELECT value, name from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.PMIC_Reference_Data
Where name like 'PMIC_DEXA_AnimalPosition_values' and dateDisabled is null