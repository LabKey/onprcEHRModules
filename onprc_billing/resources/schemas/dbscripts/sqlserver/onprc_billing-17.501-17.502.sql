
GO
/****** Object:  StoredProcedure [onprc_billing].[AnnualRateChangeProcess]    Script Date: 5/4/2018 10:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
