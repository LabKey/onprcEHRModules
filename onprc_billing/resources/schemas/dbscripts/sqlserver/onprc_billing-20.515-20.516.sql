

CREATE FUNCTION [onprc_ehr].[RateCalc]
    (
    @alias varchar(20),
    @chargeId float,
    @project float,
    @startDate date,
    @baseSubsidyVal float
    )

    RETURNS float
    AS
BEGIN
Declare @unitCostVal float,
			   @projectExemption float,
			   @projectMultipler float,
			   @unitCost float,
			   @NonOGAAlias varchar(20),
			   @blankAliasType varchar(20),
			   @baseSubsidy float,
			   @subsidy float,
               @faRate float,
               @removeSubsidy smallInt,
               @aliasRaiseFA smallInt,
               @chargeRaiseFA smallInt


	--initiate Variables
	--determine if there is a project level exemption
	--the base subsidy is defined as a gloabl variable in the Labkey Java Code in onprc_ehr.java and if a change in the base rate is requested, the data needs to be updated in each position
Set @baseSubsidyVal = .47
Set @basesubsidy = .47
Set @unitCost = 1000
Set @subsidy = @baseSubsidyVal
Set @projectExemption = (Select cr.unitcost From onprc_billing.chargeRateExemptions cr
    Where cr.chargeId = @chargeId
    and cr.project = @project
    and cr.startDate < @startDate
    and ((@startDate <= cr.endDate) or (cr.enddate is null)))

--determine if there is a project level multiplier	--	onprc_billing.projectMultipler
--verified the query
Set @projectMultipler = (Select pm.multiplier From onprc_billing.projectMultipliers pm
    Where pm.account = @alias
    and pm.startdate <= @startDate
    and ((pm.enddate >= @startDate) or (pm.enddate is Null)))


--determine if the alias is a non oga rate --onprc_billing.aliases --category column
--verified query
Set @NonOGAAlias = (Select a.category From onprc_billing.aliases a
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----determine if Alias Type is Blank
----verified query
Set @blankAliasType = (Select a.aliasType From onprc_billing.aliases a
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----determine if remove subsidy if true
----verified query
Set @removeSubsidy = (Select t.removeSubsidy From onprc_billing.aliases a join onprc_billing.aliasTypes t on a.aliasType = t.aliasType
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----determine if raise F&A is True for Charge Rate --Need to set date parameters on most of these
----Need to lock down date range
Set @chargeRaiseFA = (Select c.canRaiseFA From onprc_billing.chargeableItems c join onprc_billing.chargeRates cr on c.rowId = cr.chargeId
    Where cr.chargeId = @chargeId
    and (cr.StartDate < @startDate and cr.EndDate > @startDate))

----determine if rate F&A is true for alias
Set @aliasRaiseFA = (Select t.canRaiseFA From onprc_billing.aliases a join onprc_billing.aliasTypes t on a.aliasType = t.aliasType
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

----get FA Rate for Alias
Set @faRate = (Select a.faRate From onprc_billing.aliases a
    Where a.alias = @alias
    and (a.budgetStartDate < @startDate and a.budgetEndDate > @startDate))

--determine unit cost
--if it retunrs null there is no charge rate
Set @unitCost = (Select r.unitcost From onprc_billing.chargeRates r
    Where r.chargeID = @chargeId
    and r.startDate <= @startDate
    and ((r.enddate >= @startDate) or r.enddate Is Null))

--determine Unit Cost
Select @unitCostVal =

       Case
           --returns unit cost when there is an exemption at the project level
           When @projectExemption is not null then @projectExemption
           --return value for a charge that has a pm multiplier
           When @projectMultipler is not null then @projectMultipler * @unitCost
           ------ --where there is no unit cost listed return null
           When @unitCost is null then null
           --where the alias type is not OGA charge NIH Rate
           When @NonOGAAlias is not null and @NonOGAAlias != 'OGA' then @unitCost
           ------when alias type is not known then return null
           When @blankAliasType is null then null

           When (@removeSubsidy = 1 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1))
               THEN ((@unitCost / (1 - COALESCE(@subsidy, 0))) * (CASE WHEN (@faRate IS NOT NULL AND @faRate < @baseSubsidy) THEN (1 + @baseSubsidy / (1 + @faRate)) ELSE 1 END))

           When (@removeSubsidy = 1 AND @aliasRaiseFA = 0)
               THEN (@unitCost / (1 - COALESCE(@subsidy, 0)))


           When (@removeSubsidy = 0 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1))
               Then (@unitCost * (CASE WHEN (@faRate IS NOT NULL AND @faRate = 0) THEN  (1 + @Subsidy / (1 + @faRate)) ELSE 1 END))

           When (@removeSubsidy = 0 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1))
               Then (@unitCost * (CASE WHEN (@faRate IS NOT NULL AND @faRate < @Subsidy) THEN (1 + @Subsidy / (1 + @faRate)) ELSE 1 END))

           Else @unitCost
           END

           --return @unitCost
           return @unitCostVal--@projectExemption

End

GO
