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
Select
	IDKEY as IDKEY ,
	AnimalID as Id,
	AccountNo as AccountNo,
	afc.ProjectID as ProjectID,			------ Ref_ProjectsIacuc
	OHSUAccountNo as OHSUAccountNo ,
	ProcedureID as ProcedureID ,
	ChargeType as ChargeTypeInt ,
	s1.Value as ChargeType,    
	afc.FeeCode as FeeCode,				-- Ref_Fees
	--ref2.FeeCode
	afc.ChargeCode as ChargeCode ,		-- from ref_fees...
	Amount as Amount,
	BillingDate as BillingDate ,
	ChargeDate as ChargeDate ,
	InvoiceDate as InvoiceDate  ,
	InvoiceNo as InvoiceNo ,
	ProcedureCount as ProcedureCount,
	Remarks as  Remarks,


	ibs.IDKey,
	ibs.ServiceCenter,
	ibs.TransactionType,
	ibs.TransactionNumber,
	ibs.TransactionDate,
	ibs.TransactionDescription,
	ibs.LastName,
	ibs.FirstName,
	ibs.FiscalAuthorityNumber,
	ibs.FAID,
	ibs.FiscalAuthorityName,
	ibs.Department,
	ibs.MailCode,
	ibs.ContactPhone,
	ibs.ItemCode,		-- for PSURG Ref_SurgProcedure, for PDAR Ref_FeesProcedures
	ibs.Quantity,
	ibs.Price,
	ibs.OHSUAlias,
	ibs.TotalAmount,
	ibs.InvoiceDate,
	ibs.InvoiceNumber,
	ibs.ProjectID,				--Ref_ProjectsIacuc
	ibs.CageID,
	ibs.ChargesIDKey,
--	objectid,
--	ts


	afc.objectid,
	afc.ts as rowversion

From Af_Charges afc

left join Sys_Parameters s1 on (s1.Field = 'ChargeType' and afc.ChargeType = s1.Flag)
left join Ref_ProjectsIACUC ref1 on (ref1.ProjectID = afc.projectid)
left join Ref_Fees ref2 on (ref2.FeeCode = afc.FeeCode)
left join AF_ChargesIBS ibs on (ibs.ChargesIDKey = afc.IDKEY)
	

--TODO: add perdiem, rodent


