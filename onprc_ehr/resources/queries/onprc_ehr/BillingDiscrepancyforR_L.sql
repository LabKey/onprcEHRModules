/*
=====================================================================
 Query Name      : GJ_BillingDiscrepanciesRL
 Schema          : onprc_ehr
 Purpose         : Identify procedure charges where the billed project
                   does not match the animal’s current project and
                   highlight animals with dual active assignments.
 Issue / Ticket  : EHR Issue 11870
 Author          : jonesga
 Last Modified   : 2026-07-15
update"         Deploying to Test F for review
=====================================================================
*/

WITH ProcedureFees AS (
    SELECT
        pfr.id,
        pfr.date,
        pfr.project.displayName AS ProjectBilledTo,
        pfr.project AS billedProjectObj,
        pfr.chargeType,
        pfr.procedureId,
        pfr.chargeId,
        pfr.unitCost,
        pfr.matchesProject,
        pfr.taskId
    FROM onprc_billing.procedureFeeRates pfr
)
,
/*-------------------------------------------------------------------
  Active assignment context
-------------------------------------------------------------------*/
     ActiveAssignments AS (
         SELECT
             a.Id,
             a.project,
             a.project.displayName AS ProjectName
         FROM study.assignment a
         WHERE
             a.enddate IS NULL
            OR a.enddate >= CURDATE()
     ),

     AssignmentCounts AS (
         SELECT
             Id,
             COUNT(DISTINCT project) AS AssignmentCount
         FROM ActiveAssignments
         GROUP BY Id
     ),

     AnimalAssignmentStatus AS (
         SELECT
             aa.Id,
             aa.ProjectName AS CurrentProject,
             ac.AssignmentCount,
             CASE
                 WHEN ac.AssignmentCount > 1 THEN true
                 ELSE false
                 END AS IsDualAssigned
         FROM ActiveAssignments aa
                  LEFT JOIN AssignmentCounts ac
                            ON aa.Id = ac.Id
     )

/*-------------------------------------------------------------------
  Final result
-------------------------------------------------------------------*/
SELECT
    pf.id,
    pf.date,

    pf.ProjectBilledTo,
    aas.CurrentProject,

    CASE
        WHEN pf.ProjectBilledTo = aas.CurrentProject
            THEN 'Billing is Correct'
        ELSE 'Billing Needs Review'
        END AS ChargeReview,

    CASE
        WHEN aas.IsDualAssigned = true
            THEN 'Dual Assigned'
        ELSE 'Single Assignment'
        END AS AssignmentStatus,

    aas.AssignmentCount,

    pf.chargeType,
    pf.procedureId,
    pf.chargeId,
    pf.unitCost,
    pf.matchesProject,
    pf.taskId

FROM ProcedureFees pf
         LEFT JOIN AnimalAssignmentStatus aas
                   ON pf.id = aas.Id

WHERE
    pf.ProjectBilledTo NOT LIKE '0492-%'
        --or
  --AND aas.IsDualAssigned = true)

ORDER BY
    pf.date DESC,
    pf.id;