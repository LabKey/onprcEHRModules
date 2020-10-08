/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
USE Labkey
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonesga@phsu.edu
-- Create date: 2020/4/11
-- Description:	Process to clean the onprc_billing.aliases dataset to only pertient
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'AliasCleanup202004')
    DROP PROCEDURE ALIASCleanup202004
GO
CREATE PROCEDURE onprc_billing.AliasCleanup202004

AS
BEGIN
    --Handles active non OGA Aliases
    Update a
    Set a.projectStatus = 'Active',a.comments = 'In Use - Non ONPRC Alias', a.category = 'OHSU GL'
--Se[onprc_billing].[OGA_RemoveRecords]ect a.Alias,p.account -- update the category to
    from onprc_billing.aliases a join onprc_billing.projectAccountHistory p on p.account = a.alias
    where p.enddate > = GetDate() and a.alias Not Like '9%'

-- updates the alias dataset setting end date and comment for disabled aliases
    Update a
    Set dateDisabled = '4/1/2020', Comments = 'Alias Disabled'
    from onprc_billing.aliases a
    where aliasEnabled = 'N'

    Update a1
    set a1.projectStatus = 'Non Active GL', a1.aliasEnabled = 'n', a1.datedisabled = GetDate(), a1.comments = 'GL Alias Not Active entered Previously'

    from onprc_billing.aliases a1 left outer join onprc_billing.projectAccountHistory p on p.account = a1.alias
    where a1.alias not like '9%' and (a1.comments != 'In Use - Non ONPRC Alias' or a1.comments is null)

    Update a2
    Set a2.dateDisabled = GetDate(), comments = 'Expired Alias', aliasEnabled = 'n'
--select a1.alias,a1.budgetEndDate
    from onprc_billing.aliases a2
    where a2.budgetEndDate <=GetDate()

    Update a4
    set dateDisabled = GetDate(), comments = 'Grant Closed', projectStatus = 'Grant Closed', aliasEnabled = 'N'
--Select a4.alias,s.[PROJECT STATUS],a4.projectStatus
    from onprc_billing.aliases a4 left Outer join onprc_billing.ogaSynch s on Cast(a4.alias as varchar(50)) = Cast(s.[alias] as VarChar(50))
    where a4.dateDisabled is null and a4.projectstatus in ('Archived','Closed','IM PURGEd')
--Remove Records not associated with ONPRC
    DELETE FROM onprc_billing.aliases
    where alias in (Select a.alias
                    from onprc_billing.aliases a left outer join onprc_billing.projectAccountHistory p on a.alias = p.account
                    where p.account is  null and a.dateDisabled is not null)
    --Update the existing data to add PPQ, ORG PPQ Date to Existing Aliases
--Update a10
--Set A10. =  s.ORG, a10.PPQNumber = s.[PPQ CODE], a10.PPQDate = s.[PPQ DATE]
--from onprc_billing.aliases a10 left Outer join onprc_billing.ogaSynch s on Cast(a10.alias as varchar(50)) = Cast(s.[alias] as VarChar(50))
--where a10.Org is null
END
GO



