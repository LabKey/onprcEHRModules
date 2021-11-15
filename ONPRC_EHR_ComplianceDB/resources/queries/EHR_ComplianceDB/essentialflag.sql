select value from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.Reference_Data
where columnName = 'Necropsydist'
  And enddate is null