/*
=====================================================================
 Query Name      : GJ_BillingDiscrepanciesRL
 Schema          : onprc_ehr
 Purpose         : Identify procedure charges where the billed project
                   does not match the animal’s current project,
                   using project.displayName for clarity
 Parameters      : @DaysBack (integer, 1–30)
 Issue / Ticket  : EHR Issue 11870
 Author          : jonesga
 Last Modified   : 2026-04-17
=====================================================================
*/

WITH DateWindow AS (
    SELECT
        CURDATE() AS runDate,
        TIMESTAMPADD('SQL_TSI_DAY', -@DaysBack, CURDATE()) AS startDate
),

     ProcedureFees AS (
         SELECT
             pfr.id,
             pfr.date,

             -- Use project display names for user-facing review
             pfr.project.displayName        AS ProjectBilledTo,
             pfr.currentProject.displayName AS CurrentProject,

             pfr.project                    AS billedProjectObj,
             pfr.currentProject             AS currentProjectObj,

             pfr.chargeType,
             pfr.procedureId,
             pfr.chargeId,
             pfr.unitCost,
             pfr.matchesProject
         FROM onprc_billing.procedureFeeRates pfr
     )

SELECT
    pf.id,
    pf.date,

    pf.ProjectBilledTo,
    pf.CurrentProject,

    CASE
        WHEN pf.ProjectBilledTo = pf.CurrentProject
            THEN '✅ Billing is Correct'
        ELSE '❌ Billing Needs Review'
        END AS ChargeReview,

    pf.chargeType,
    pf.procedureId,
    pf.chargeId,
    pf.unitCost,
    pf.matchesProject

FROM ProcedureFees pf
         CROSS JOIN DateWindow dw

WHERE pf.ProjectBilledTo NOT LIKE '0492-%'
  AND pf.date >= dw.startDate
  AND pf.date <  dw.runDate
;