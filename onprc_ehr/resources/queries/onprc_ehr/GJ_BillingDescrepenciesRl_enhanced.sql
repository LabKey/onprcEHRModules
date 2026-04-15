/*
=====================================================================
 Query Name      : GJ_BillingDescrepenciesRL
 Schema          : onprc_ehr
 Purpose         : To provide the R&L team with a tool to identify when
                   procedure charges will be generated pointing to an
                   alias not associated with the animal's project
 Issue / Ticket  : EHR Issue 11870
 Development Status: In development FB posted to Test E
 Author          : jonesga
 Created         : 2026-04-10
 Last Modified   : 2026-04-14
Latest Changes:  Added logic requested relating to date run but requires more review
                Also added functionality to add a Red X where ther is a problem
                THis is a new query based on the original with the enahncements
=====================================================================
*/

WITH RunContext AS (
    SELECT
        CURDATE() AS runDate,
        DAYOFWEEK(CURDATE()) AS runDayOfWeekNum,
        CASE DAYOFWEEK(CURDATE())
            WHEN 1 THEN 'Sunday'
            WHEN 2 THEN 'Monday'
            WHEN 3 THEN 'Tuesday'
            WHEN 4 THEN 'Wednesday'
            WHEN 5 THEN 'Thursday'
            WHEN 6 THEN 'Friday'
            WHEN 7 THEN 'Saturday'
            END AS runDayOfWeekName,

        -- If run on Monday, include Friday–Sunday; otherwise include yesterday
        CASE
            WHEN DAYOFWEEK(CURDATE()) = 2 THEN timestampadd('SQL_TSI_DAY', -3, CURDATE())
            ELSE timestampadd('SQL_TSI_DAY', -1, CURDATE())
            END AS changeStartDate,

        CURDATE() AS changeEndDate,

        CASE
            WHEN DAYOFWEEK(CURDATE()) = 2
                THEN 'Monday run – includes Friday, Saturday, and Sunday changes'
            ELSE 'Daily run – includes previous day changes'
            END AS runLogicNote
),

     procedureFees AS (
         SELECT
             pfr.id,
             pfr.date,
             pfr.project,
             pfr.account,
             pfr.chargetype AS chargeType,
             pfr.assistingStaff,
             pfr.procedureid,
             pfr.chargeID,
             pfr.serviceCenter,
             pfr.item,
             pfr.category,
             pfr.sourceRecord,
             pfr.unitcost,
             pfr.NIHRate,
             pfr.creditAccount,
             pfr.matchesProject,
             pfr.isAdjustment,
             pfr.IsAcceptingCharges,
             pfr.isExpiredAccount,
             pfr.currentActiveAlias
         FROM onprc_billing.procedurefeeRates pfr
     ),

     ProjectAlias AS (
         SELECT
             pa.name,
             pa.account
         FROM ehr.project pa
         WHERE pa.enddate > CURDATE()
            OR pa.enddate IS NULL
     )

SELECT
    pf.id,
    pf.date,
    pf.project,
    pf.account AS chargeToAlias,
    pa.account AS projectAlias,

    -- ✅ Status with symbols for conditional formatting
    CASE
        WHEN pf.account = pa.account
            THEN '✅ Billing is Correct'
        ELSE '❌ Billing Needs Review'
        END AS ChargeReview,

    pf.chargeType,
    pf.procedureID,
    pf.chargeID,
    pf.unitcost,
    pf.matchesProject,

    -- ✅ Run context for transparency and auditability
    --rc.runDate,
    --rc.runDayOfWeekName,
    --rc.runLogicNote

FROM procedureFees pf
        -- CROSS JOIN RunContext rc
         LEFT JOIN ProjectAlias pa
                   ON pf.project.displayName = pa.name

WHERE pf.project.displayName NOT LIKE '0492-%'
  --AND pf.date >= rc.changeStartDate
  --AND pf.date < rc.changeEndDate;