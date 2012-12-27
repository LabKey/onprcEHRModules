/*
 * Copyright (c) 2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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

