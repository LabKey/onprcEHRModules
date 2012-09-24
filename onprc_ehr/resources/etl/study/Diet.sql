Select
	--IDKey as IDKey ,
	cast(AnimalID as varchar) as Id,
	afd.ProjectID as Project,   ---- Ref_ProjectsIacuc
	afd.StartDate as Date  ,
	ReleaseDate as enddate ,
	--afd.DietCode as DietCode,     ----- Ref_Diet
	d.Description as Diet,
	Frequency as  FrequencyInt,
	s1.value as FrequencyMeaning,
	--Duration as Duration ,		-- # of days
	Billable as Billable  ,		-- 0 = no, 1 = yes
	Status as StatusField  ,
	--BillID as  BillID,			-- not used

	afd.objectid,
	afd.ts as rowversion

From Af_Diet afd
left join Sys_Parameters s1 on (s1.Field = 'Frequency' and afd.Frequency = s1.Flag)
left join Ref_ProjectsIacuc proj on (proj.ProjectID = afd.ProjectID)
left join Ref_Diet d on (d.DietCode = afd.DietCode)

where afd.ts > ?