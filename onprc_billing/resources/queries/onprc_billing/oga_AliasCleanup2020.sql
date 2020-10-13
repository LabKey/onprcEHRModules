USE [Labkey]
GO
/****** Object:  StoredProcedure [onprc_billing].[oga_AliasCleanupNew]    Script Date: 1/29/2020 7:13:37 AM ******/

CREATE PROCEDURE [onprc_billing].[oga_AliasCleanup]

    AS
    BEGIN

--This update will be used to enter date disabled for all aliases used in Invoiced Items
--This update will be used to enter date disabled for all aliases used in Invoiced Items
Update onprc_billing.aliases
	Set COMMENTS = 'Found In PRoject Account History',dateDisabled = GetDate(), aliasEnabled = 'n'
Where alias in (Select Distinct Alias


from onprc_billing.aliases a left outer join onprc_billing.projectAccountHistory p
	on a.alias = p.account
	where p.account is not null and p.enddate < getDate()
	and a.category != 'OHSU GL'	) --and a.projectStatus != 'Active')


--This update will be used to enter date disabled for all aliases used in Invoiced Items
Update onprc_billing.aliases
	Set COMMENTS = 'Found In INvoiced ITem',dateDisabled = GetDate(), aliasEnabled = 'n'
Where alias in (Select Distinct Alias


from onprc_billing.aliases a left outer join onprc_billing.invoicedItems i
	on a.alias = i.debitedaccount
	where i.debitedaccount is not null
	and a.category != 'OHSU GL')--and a.projectStatus != 'Active')


/*

        --Handles active non OGA Aliases
        Update a
        Set a.projectStatus = 'Active',a.comments = 'In Use - Non ONPRC Alias', a.category = 'OHSU GL'

--Select a.Alias,p.account -- update the category to
        from onprc_billing.aliases a join onprc_billing.projectAccountHistory p on p.account = a.alias
        where p.enddate > = GetDate() and a.alias Not Like '9%'

--handle inactive GL Aliases in the Dataset
        Update gl
        set gl.projectStatus = 'Non Active GL', gl.aliasEnabled = 'n', gl.datedisabled = GetDate(), gl.comments = 'GL Alias Not Active entered Previously'

--Select gl.*
        from onprc_billing.aliases gl left outer join onprc_billing.projectAccountHistory p on p.account = gl.alias
        where gl.alias not like '9%' and (gl.comments != 'In Use - Non ONPRC Alias' or gl.comments is null)

--Handles Expired Aliases by setting Date Disabled
        Update a1
        Set a1.dateDisabled = GetDate(), comments = 'Expired Alias'
--select a1.alias,a1.budgetEndDate
        from onprc_billing.aliases a1
        where a1.budgetEndDate <=GetDate()

        Update a4
        set dateDisabled = GetDate(), comments = 'Grant Closed', projectStatus = 'Grant Closed'
--Select a4.alias,s.[PROJECT STATUS],a4.projectStatus
        from onprc_billing.aliases a4 left Outer join onprc_billing.ogaSynch s on Cast(a4.alias as varchar(50)) = Cast(s.[alias] as VarChar(50))
        where a4.dateDisabled is null and a4.projectstatus in ('Archived','Closed','IM PURGEd')

--Update the existing data to add PPQ, ORG PPQ Date to Existing Aliases

        Update a10
        Set organization =  s.ORG, a10.PPQCode = s.[PPQ CODE], a10.PPQDate = s.[PPQ DATE]


        from onprc_billing.aliases a10 left Outer join onprc_billing.ogaSynch s on Cast(a10.alias as varchar(50)) = Cast(s.[alias] as VarChar(50))
        where a10.Organization is null
*/

    END