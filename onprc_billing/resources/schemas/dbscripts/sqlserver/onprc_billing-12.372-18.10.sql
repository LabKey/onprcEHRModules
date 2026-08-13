-- Contents of onprc_billing-12.373-12.374.sql to onprc_billing-17.501-17.502.sql from onprc19.1Prod

--cREATED 8/25/2016
--gjones
--NEW Data set to control Inflation factor for Rates for ONPRC
--
CREATE TABLE onprc_billing.AnnualInflationRate (
                                                   billingYear varchar(10) not null,
                                                   inflationRate decimal,
                                                   startDate datetime,
                                                   endDate datetime,

                                                   createdBy integer,
                                                   created datetime,
                                                   modifiedBy integer,
                                                   modified datetime,


);

EXEC sp_rename 'onprc_billing.AnnualInflationRate', 'AnnualRateChange';

-- Created: 4-26-2017  R.Blasa

CREATE TABLE onprc_billing.MergeChargtypeUpdates (
                                                     rowid int IDENTITY(1,1) NOT NULL,
                                                     ProjectName varchar(50) not null,
                                                     Protocol varchar(100) not null,
                                                     ChargeType varchar(50) not null,
                                                     objectid ENTITYID,
                                                     startDate datetime,
                                                     endDate datetime

                                                         CONSTRAINT PK_MergeType PRIMARY KEY(rowid)
);

-- Adds table Annual Rate Change to Billing
-- Note: Unnecessary due to onprc_billing.AnnualRateChange existing in the DB
-- from when it was renamed in the 12.378-12.379 script


-- SET ANSI_NULLS ON
-- GO
--
-- SET QUOTED_IDENTIFIER ON
-- GO
-- DROP TABLE onprc_billing.AnnualRateChange;
-- CREATE TABLE onprc_billing.AnnualRateChange
-- (
-- 	[billingYear] [varchar](10) NOT NULL,
-- 	[inflationRate] [decimal](18, 0) NULL,
-- 	[startDate] [datetime] NULL,
-- 	[endDate] [datetime] NULL,
-- 	[createdBy] [int] NULL,
-- 	[created] [datetime] NULL,
-- 	[modifiedBy] [int] NULL,
-- 	[modified] [datetime] NULL
-- ) ON [PRIMARY]
-- GO

-- Adds table Annual Rate Change to Billing
-- add primary key and identity key
ALTER TABLE onprc_billing.AnnualRateChange Add RowID Int IDENTITY (1,1)not null;
ALTER TABLE onprc_billing.AnnualRateChange Add CONSTRAINT PK_AnnualRateChange_RowID PRIMARY KEY CLUSTERED (RowID);

-- Adds change inflation rate to 3 position decimal
-- add primary key and identity key
alter table [onprc_billing].[AnnualRateChange]
ALTER COLUMN InflationRate Numeric(18,4)
GO
/****** Object:  StoredProcedure [onprc_billing].[AnnualRateChangeProcess]    Script Date: 5/4/2018 10:50:22 AM ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--DROP Procedure [onprc_billing].[AnnualRateChange]
--Go

CREATE Procedure [onprc_billing].[AnnualRateChangeProcess]

AS

BEGIN
DECLARE


@Year1     float,
                   @Year2     float,
                    @Year3     float,
                   @Year4     float,
                   @Year5     float,
                   @Year6     float,
                   @Year7     float,
                   @Year8     float,
                   @Year9     float,
                   @Aprate1   float,
                   @Aprate2   float,
                   @Aprate3   float,
                   @Aprate4   float,
                   @Aprate5   float,
                   @Aprate6   float,
                   @Aprate7   float,
                    @Aprate8   float,
                   @Aprate9   float,

                   @UnitCost    float,
                   @nSearchkey   int,
                   @TempSearchkey Int,
                   @ChargeId    SmallInt,
				   @CurrentBillingYear SmallInt,
				   @Billingyear  as Smallint








                     ---- Reset Temp tables

Delete Rpt_ChargesProjection




----- INitialize variables

Set @nSearchkey = 0
Set @TempSearchkey = 0
Set @Aprate1 = 0
Set @Aprate2 = 0
Set @Aprate3 = 0
Set @Aprate4 = 0
Set @Aprate5 = 0
Set @Aprate6 = 0
Set @Aprate7 = 0
Set @Aprate8 = 0
Set @Aprate9 = 0
SET @CurrentBillingYear = (Select DATEDIFF(Year,'5/1/1959',GetDate()))
SET @Billingyear = @CurrentBillingYear + 1



---- Begin Processing Data

select Top 1  @nSearchkey = rowid from onprc_billing.chargeRates
where endDate >= GETDATE()
order by rowid



--Billing Year Constant



Select @Aprate1 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear

Select @Aprate2 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 1

Select @Aprate3 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 2

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 3)
Begin

Select @Aprate4 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 3
End



    If exists (Select InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 4)
Begin

Select @Aprate5 = InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 4
End

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 5)
Begin

Select @Aprate6 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 5

End

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 6)
Begin

Select @Aprate7 =  InflationRate from onprc_billing.AnnualRateChange
Where Billingyear = @BillingYear + 6

End

    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 7)
Begin

Select @Aprate8 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 7

End


    If exists (Select  InflationRate from onprc_billing.AnnualRateChange

                    Where Billingyear = @BillingYear + 8)
Begin

Select @Aprate9 =  InflationRate from onprc_billing.AnnualRateChange

Where Billingyear = @BillingYear + 8
End



    While @TempSearchKey < @nSearchkey
Begin

Set @Year1 = 0.0
Set @Year2 = 0.0
Set @Year3 = 0.0
Set @Year4 = 0.0
Set @Year5 = 0.0
Set @Year6 = 0.0
Set @Year7 = 0.0
Set @Year8 = 0.0
Set @Year9 = 0.0
Set @UnitCost = 0.0
Set @ChargeId = 0

    If exists(select *  from onprc_billing.chargeRates
    where endDate >= GETDATE()
    And rowid = @nSearchkey)
BEgin

select Top 1 @UnitCost = unitcost, @ChargeId = chargeid from onprc_billing.chargeRates
where endDate >= GETDATE()
  and rowid = @nSearchkey
order by rowid



set @Year1 = @Aprate1  * @UnitCost
Set @year2 = @year1 * @Aprate2
Set @Year3 = @year2 * @Aprate3
Set @Year4 = @year3 * @Aprate4
Set @Year5 = @year4 * @Aprate5
Set @Year6 = @year5 * @Aprate6
Set @Year7 = @year6 * @Aprate7
Set @Year8 = @year7 * @Aprate8
Set @Year9 = @year8 * @Aprate9



Insert into Rpt_ChargesProjection
values(
          @ChargeId,   ------- ChargeId
          @UnitCost,      ---- starting unit cost for the project year
          @Year1,        ----- !st Rate computation
          @Year2,        ----- !st Rate computation
          @Year3,        ----- !st Rate computation
          @Year4,        ----- !st Rate computation
          @Year5,        ----- !st Rate computation
          @Year6,        ----- !st Rate computation
          @Year7,        ----- !st Rate computation
          @Year8,        ----- !st Rate computation
          --         @Year9,        ----- !st Rate computation,
          @Aprate1,      ------ inflation rate year 57
          @Aprate2,      ------ inflation rate year 58
          @Aprate3,      ------ inflation rate year 59
          @Aprate4,      ------ inflation rate year 60
          @Aprate5,      ------ inflation rate year 61
          @Aprate6,      ------ inflation rate year 62
          @Aprate7,      ------ inflation rate year 63
          @Aprate8,      ------ inflation rate year 64
          @Aprate9,      ------ inflation rate year 65
          @nSearchkey,    ---- RowID
          getdate()       ---- run date

      )

End ---(if)


Set @TempSearchKey = @nSearchkey


select Top 1  @nSearchkey = rowid from onprc_billing.chargeRates
where endDate >= GETDATE()
  And rowid > @nSearchkey
order by rowid




End ----(While)



---Now display the results of the computation
Select chargeid as [ChargeID],
       unitcost as [UnitCost],
       Year1,
       Year2,
       Year3,
       Year4,
       Year5,
       Year6,
       Year7,
       Year8,
       --          year9,
       Rowid as [Row ID],
                            posteddate  as [PostedDate]


from  Rpt_ChargesProjection

Order by  chargeid

END

GO
