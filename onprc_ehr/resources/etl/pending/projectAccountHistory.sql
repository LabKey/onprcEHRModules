/*
Ref_ProjectAccounts

Created by: W. Borum	Date: 8/22/2012

Tested by: 			Date:
	Raymond Blasa           8/22/2012 16:25

*/

Select
	rpa.ProjectAccountID,
	rpa.ProjectID,					--Ref_ProjectsIACUC
	rpa.OHSUFundNumber,
	rpa.OHSUAccountNumber,
	rpa.PrimaryInvestigatorID,		--Ref_Investigator
	rpa.DateCreated,
	rpa.DateDisabled,
	rpa.AliasExpirationDate,
	rpa.AliasStartDate,
	rpa.AccountStatus,				-- 0 = inactive, 1 = active
    rpa.objectid

From Ref_ProjectAccounts rpa
	left join Ref_Technicians rt on (rpa.FinancialAnalyst = rt.ID)
	left join Sys_Parameters s1 on (s1.field = 'DepartmentCode' and s1.Flag = rpa.FinancialAnalyst)

