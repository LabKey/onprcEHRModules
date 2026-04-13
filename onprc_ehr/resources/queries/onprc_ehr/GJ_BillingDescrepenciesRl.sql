/*
=====================================================================
 Query Name      : GJ_BillingDescrepenciesRL
 Schema          : onprc_ehr
 Purpose         : To provide the R&L team with a tool to idetofy when a procedure charges will be generated
                   Point to a alias that is not associcated witht eh Aniomals assigned project
 Issue / Ticket  :  EHR Issue 11870
  Feature Branch:
 Pull Request:
 Development Status: In development FB posted to Test E
 Business Context:
 Resolution Logic:
 Parameters      : Non Defined
 Output          : Query Grid
 Validation Notes: Thi
 Author          : jonesga
 Created         : 2026-04-10
 Last Modified   : 2026-04-13
=====================================================================
*/
WITH procedureFees AS (
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

     ProjectAlias AS (SELECT pa.name,
                             pa.account
                      FROM ehr.project pa
                      where (pa.enddate > CurDate()
                         or pa.enddate is null)     )

SELECT
    pf.id,
    pf.date,
    pf.project,
    pf.account        AS chargeToAlias,
    pa.account        AS projectAlias,
    CASE    When pf.account = pa.account then 'Billing is Correct'
        ELSE 'Billing Needs Review'
        end as ChargeReview,
    pf.chargeType,
    pf.procedureID,
    pf.chargeID,
    pf.unitcost,
    pf.matchesProject
FROM procedureFees pf
         LEFT JOIN ProjectAlias pa
                   ON pf.project.displayName = pa.name
/*WHERE
    pf.account != pa.account*/