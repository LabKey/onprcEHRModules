INSERT into labkey.ehr_lookups.source (code, meaning, InstitutionCity, InstitutionState, InstitutionCountry)
	select InstitutionCode, InstitutionName, InstitutionCity, InstitutionState, InstitutionCountry  from Ref_ISISInstitution;

