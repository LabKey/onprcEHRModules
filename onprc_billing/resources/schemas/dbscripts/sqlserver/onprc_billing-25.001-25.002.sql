CREATE FUNCTION [onprc_ehr].[RateCalc2025]
    (
    @alias varchar(20),
    @chargeId float,
    @project float,
    @startDate date,
    @GrantDate date,
    @baseSubsidyVal float  -- This parameter may be deprecated but kept for compatibility
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
        @GrantDate Date,
        @subsidy float,
        @faRate float,
        @removeSubsidy smallInt,
        @aliasRaiseFA smallInt,
        @chargeRaiseFA smallInt

    -- Retrieve the grant's budget start date


-- Determine base subsidy based on grant date
SET @baseSubsidy = CASE
        WHEN @GrantDate > '2024-07-01' THEN 0.475
        ELSE 0.47
END;

    -- Use the calculated base subsidy instead of the input parameter
    SET @subsidy = @baseSubsidy;

    -- Rest of the function logic remains with corrections...

    -- Determine project exemption
    SET @projectExemption = (
        SELECT cr.unitcost
        FROM onprc_billing.chargeRateExemptions cr
        WHERE cr.chargeId = @chargeId
            AND cr.project = @project
            AND cr.startDate < @startDate
            AND (@startDate <= cr.endDate OR cr.enddate IS NULL)
    );

    -- Determine project multiplier
    SET @projectMultipler = (
        SELECT pm.multiplier
        FROM onprc_billing.projectMultipliers pm
        WHERE pm.account = @alias
            AND pm.startdate <= @startDate
            AND (pm.enddate >= @startDate OR pm.enddate IS NULL)
    );

    -- Check for non-OGA alias
    SET @NonOGAAlias = (
        SELECT a.category
        FROM onprc_billing.aliases a
        WHERE a.alias = @alias
            AND a.budgetStartDate <= @startDate
            AND a.budgetEndDate >= @startDate
    );

    -- Check for blank alias type
    SET @blankAliasType = (
        SELECT a.aliasType
        FROM onprc_billing.aliases a
        WHERE a.alias = @alias
            AND a.budgetStartDate <= @startDate
            AND a.budgetEndDate >= @startDate
    );

    -- Determine if subsidy should be removed
    SET @removeSubsidy = (
        SELECT t.removeSubsidy
        FROM onprc_billing.aliases a
        JOIN onprc_billing.aliasTypes t ON a.aliasType = t.aliasType
        WHERE a.alias = @alias
            AND a.budgetStartDate <= @startDate
            AND a.budgetEndDate >= @startDate
    );

    -- Check if charge can raise F&A
    SET @chargeRaiseFA = (
        SELECT c.canRaiseFA
        FROM onprc_billing.chargeableItems c
        JOIN onprc_billing.chargeRates cr ON c.rowId = cr.chargeId
        WHERE cr.chargeId = @chargeId
            AND cr.StartDate <= @startDate
            AND (cr.EndDate >= @startDate OR cr.EndDate IS NULL)
    );

    -- Check if alias can raise F&A
    SET @aliasRaiseFA = (
        SELECT t.canRaiseFA
        FROM onprc_billing.aliases a
        JOIN onprc_billing.aliasTypes t ON a.aliasType = t.aliasType
        WHERE a.alias = @alias
            AND a.budgetStartDate <= @startDate
            AND a.budgetEndDate >= @startDate
    );

    -- Get F&A rate for alias
    SET @faRate = (
        SELECT a.faRate
        FROM onprc_billing.aliases a
        WHERE a.alias = @alias
            AND a.budgetStartDate <= @startDate
            AND a.budgetEndDate >= @startDate
    );

    -- Get base unit cost
    SET @unitCost = (
        SELECT r.unitcost
        FROM onprc_billing.chargeRates r
        WHERE r.chargeID = @chargeId
            AND r.startDate <= @startDate
            AND (r.enddate >= @startDate OR r.enddate IS NULL)
    );

    -- Calculate final unit cost
    SET @unitCostVal = CASE
        WHEN @projectExemption IS NOT NULL THEN @projectExemption
        WHEN @projectMultipler IS NOT NULL THEN @projectMultipler * @unitCost
        WHEN @unitCost IS NULL THEN NULL
        WHEN @NonOGAAlias IS NOT NULL AND @NonOGAAlias != 'OGA' THEN @unitCost
        WHEN @blankAliasType IS NULL THEN NULL
        WHEN (@removeSubsidy = 1 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1)) THEN
            ((@unitCost / (1 - @subsidy)) * (CASE WHEN @faRate < @baseSubsidy THEN (1 + @baseSubsidy) ELSE 1 END)
        WHEN (@removeSubsidy = 1 AND @aliasRaiseFA = 0) THEN
            (@unitCost / (1 - @subsidy))
        WHEN (@removeSubsidy = 0 AND (@aliasRaiseFA = 1 AND @chargeRaiseFA = 1)) THEN
            (@unitCost * (CASE WHEN @faRate = 0 THEN (1 + @subsidy) ELSE 1 END))
        ELSE @unitCost
    END;

    RETURN @unitCostVal;
END
GO