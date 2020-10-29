--Determine how to exempt the follwoing from adjustments
--0493-03, 0622-01,0833,0300

SELECT
Distinct
d.Id,
d.ResearchOwned,
d.project,
d.alias,
d.AgeAtAssignment,
d.ageinyears,
d.AgeGroup,
d.BirthAssignment,
d.BirthType,
d.AssignmentType,
d.DayLease,
d.DayLeaseLength,
d.MultipleAssignments,
d.date,
d.projectedRelease,
d.enddate,
d.dateFinalized,
d.assignCondition,
d.projectedReleaseCondition,
d.releaseCondition,
d.releaseType,
'Adjustment - Automatic' as chargeCategory,
d.remark,
(Select
 lf.chargeId.name from onprc_billing.leasefeedefinition lf
 Where lf.assignCondition = d.assigncondition
 	AND lf.releaseCondition = d.projectedReleaseCondition.code
       AND (Cast(d.ageAtAssignment as Integer) >= lf.minAge OR lf.minAge IS NULL)
       AND (Cast(d.ageAtAssignment as Integer) < lf.maxAge OR lf.maxAge IS NULL)
       AND lf.active = true) as OriginalChargeName,
(Select
 lf.chargeId from onprc_billing.leasefeedefinition lf
 Where lf.assignCondition = d.assigncondition
 	AND lf.releaseCondition = d.projectedReleaseCondition.code
       AND (Cast(d.ageAtAssignment as Integer) >= lf.minAge OR lf.minAge IS NULL)
       AND (Cast(d.ageAtAssignment as Integer) < lf.maxAge OR lf.maxAge IS NULL)
       AND lf.active = true) as OriginalChargeID,



(Select
 lf1.chargeId.name from onprc_billing.leasefeedefinition lf1
 Where lf1.assignCondition = d.assigncondition
 	AND lf1.releaseCondition = d.releaseCondition
       AND (Cast(d.ageAtAssignment as Integer) >= lf1.minAge OR lf1.minAge IS NULL)
       AND (Cast(d.ageAtAssignment as Integer) < lf1.maxAge OR lf1.maxAge IS NULL)
       AND lf1.active = true) as RevisedChargeName,

(Select
 lf1.chargeId from onprc_billing.leasefeedefinition lf1
 Where lf1.assignCondition = d.assigncondition
 	AND lf1.releaseCondition = d.releaseCondition
       AND (Cast(d.ageAtAssignment as Integer) >= lf1.minAge OR lf1.minAge IS NULL)
       AND (Cast(d.ageAtAssignment as Integer) < lf1.maxAge OR lf1.maxAge IS NULL)
       AND lf1.active = true) as RevisedChargecode


FROM leasefee_demograpicsTest d -- this query is broken on onprc's server, so is deleted in the module


where d.enddate is not null
	and d.releasecondition <> d.projectedReleaseCondition
	and d.ResearchOwned  = 'no'
	and d.id not in
	(Select da.id from 	study.dualassigned da where da.id = d.id and da.dualassignment = d.project
     	and (da.enddate is null or da.enddate > d.date)
     	and (da.dualenddate is null or Dualenddate > d.date)
     	and da.project.displayName in ('0300','0833','0492-03','0622-01'))`