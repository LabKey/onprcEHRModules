 SELECT
	--iacuc.ProjectID as ProjectID , --Ref_ProjectsIACUC
	rtrim(ltrim(lower(ri.IACUCCode))) as protocol,
	
	--iacuc.ProcedureID as ProcedureID  , --Ref_SurgProcedure
	(SELECT rowid from labkey.ehr_lookups.procedures p WHERE p.name = s.procedureName) as procedureid,
	
	iacuc.ProcedureCount as allowed,
	iacuc.DateCreated as startdate,
	iacuc.objectid 

FROM IACUC_NHPSurgeries IACUC
left join Ref_SurgProcedure s on (iacuc.ProcedureID = s.ProcedureID)
left join Ref_ProjectsIACUC ri on (IACUC.ProjectID = ri.ProjectID) 
where IACUC.DateDisabled is null
and iacuc.ts > ?