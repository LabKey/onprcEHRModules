
select value from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.Reference_Data
where LOWER(columnname) = LOWER('employeehost')
  And enddate is null