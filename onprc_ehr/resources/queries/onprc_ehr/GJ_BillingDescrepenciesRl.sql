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
 Last Modified   : 2026-04-10
=====================================================================\
*/
With procedureFees as (
    Select
        pfr.id,
        pfr.date,
        pfr.project,
    pfr.account,
    pfr.chargetype,
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
   from onprc_billing.procedurefeeRates pfr )

Select pf.* from procedureFees pf

/*I want to add these are parameters on a webpart after we validate the query

WHERE
    (?matchesProject IS NULL OR pfr.matchesProject = ?matchesProject)
  AND (?isAdjustment IS NULL OR pfr.isAdjustment = ?isAdjustment)
  AND (?isAcceptingCharges IS NULL OR pfr.isAcceptingCharges = ?isAcceptingCharges)
  AND (?isExpiredAccount IS NULL OR pfr.isExpiredAccount = ?isExpiredAccount)
  AND (?currentActiveAlias IS NULL OR pfr.currentActiveAlias = ?currentActiveAlias)
*/