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
),

     ActiveAssignments AS (
         SELECT
             a.Id,
             a.project,
             a.project.displayName AS ProjectName
         FROM study.assignment a
         WHERE
             (a.enddate IS NULL OR a.enddate >= CURDATE())
           AND a.date = (
             SELECT MAX(a2.date)
             FROM study.assignment a2
             WHERE a2.Id = a.Id
               AND (a2.enddate IS NULL OR a2.enddate >= CURDATE())
         )
     ),

/*-------------------------------------------------------------------
  Collapse to ONE row per animal.
  - CurrentProjects: comma list, for display only
  - AssignmentCount / IsDualAssigned: aggregated per animal
  - recent
-------------------------------------------------------------------*/
     AnimalAssignmentStatus AS (
         SELECT
             aa.Id,
             GROUP_CONCAT(DISTINCT aa.ProjectName) AS CurrentProjects,
             COUNT(DISTINCT aa.project)            AS AssignmentCount,
             CASE WHEN COUNT(DISTINCT aa.project) > 1 THEN true ELSE false END AS IsDualAssigned
         FROM ActiveAssignments aa
         GROUP BY aa.Id
     )

/*-------------------------------------------------------------------
  Final result
-------------------------------------------------------------------*/
SELECT
    pf.id,
    pf.date,
    pf.ProjectBilledTo,
    aas.CurrentProjects,

    CASE
        WHEN aas.CurrentProjects IS NULL
            THEN 'Billing is Correct'
        -- billed project matches ANY of the animal's active assignments
        WHEN EXISTS (
            SELECT 1
            FROM ActiveAssignments aa2
            WHERE aa2.Id = pf.id
              AND aa2.ProjectName = pf.ProjectBilledTo
        ) THEN 'Billing is Correct'
        ELSE 'Billing Needs Review'
        END AS ChargeReview,

    CASE
        WHEN aas.IsDualAssigned = true THEN 'Dual Assigned'
        ELSE 'Single Assignment'
        END AS AssignmentStatus,

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
    pf.ProjectBilledTo NOT LIKE '0492'

ORDER BY
    pf.date DESC,
    pf.id;