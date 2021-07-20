
Select value,columnName from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.Reference_Data
Where enddate is null
And columnName = 'ComplianceTracking'
