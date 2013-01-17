TRUNCATE TABLE labkey.onprc_ehr.investigators;
INSERT INTO labkey.onprc_ehr.investigators (firstname,lastName,position,address,city,state,country,zip,phoneNumber, investigatorType,emailAddress,dateCreated,dateDisabled,division,objectid)
Select
	FirstName,
	LastName,
	Position,
	Address,
	City,
	State,
	Country,
	ZIP,
	PhoneNumber,
	--InvestigatorType as InvestigatorTypeInt,
	s1.Value as InvestigatorType,
	EmailAddress,
	rinv.DateCreated,
	rinv.DateDisabled,
	--Division as DivisionInt,
	s2.Value as Division,
	rinv.objectid
From IRIS_Production.dbo.Ref_Investigator rinv
     left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Field = 'InvestigatorType'and s1.Flag = rinv.InvestigatorType)
     left join  IRIS_Production.dbo.Sys_Parameters s2 on (s2.Field = 'Division' and s2.Flag = rinv.Division)
WHERE rinv.objectid NOT IN (select objectid FROM labkey.onprc_ehr.investigators);