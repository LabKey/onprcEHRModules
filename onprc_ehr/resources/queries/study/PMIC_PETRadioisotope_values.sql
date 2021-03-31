SELECT value, name from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.PMIC_Reference_Data
where name like 'PETRadioisotope' and dateDisabled is null