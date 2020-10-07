--this returns day lease for adults
--updated 6/7/2019 correction of previous lease lookup
Select
l.id,
l.project.name as CenterProject,
l.alias,
l.leasetype,
l.assignmentdate,
l.assignCondition.code,
l.projectedReleaseCondition.code as ProjectedReleaseCode,
Cast(l.ageAtAssignment as Integer) as AssignmentAge,
Case
	When l.leasetype = lf.chargeID.name then lf.chargeid
	else Null
	End as chargeId,
Null as RevisedChargeID,
l.dayleaselength as quantity




FROM onprc_Billing.leaseFee_LeaseType  l JOIN onprc_billing.leaseFeeDefinition lf ON (

       l.Leasetype = lf.chargeId.Name
       AND lf.active = true)
where l.daylease <> 'yes'

UNION

--this returns ESPF DUal assigned animals
Select
l.id,
l.project.name as CenterProject,
l.alias,
l.leasetype,
l.assignmentdate,
l.assignCondition.code,
l.projectedReleaseCondition.code as ProjectedReleaseCode,
Cast(l.ageAtAssignment as Integer) as AssignmentAge,
Case
	When l.leasetype = 'U42 Expanded SPF Lease' then lf.chargeId
	else Null
	End as chargeId,
Null as RevisedChargeID,
1 as quantity



FROM onprc_Billing.leaseFee_LeaseType  l JOIN onprc_billing.leaseFeeDefinition lf ON (

       l.Leasetype = lf.chargeId.Name
       AND lf.active = true)
where l.daylease <> 'yes'



UNION

SELECT l.id,
l.project.name as CenterProject,
l.alias,
l.leasetype,
l.assignmentdate,
l.assignCondition.code,

l.projectedReleaseCondition.code as ProjectedReleaseCode,
Cast(l.ageAtAssignment as Integer) as AssignmentAge,
lf.chargeId,
Null as RevisedChargeID,

1 as quantity

FROM onprc_Billing.leaseFee_LeaseType l left outer JOIN onprc_billing.leaseFeeDefinition lf ON (

       lf.assignCondition = l.assignCondition.code
       AND lf.releaseCondition = l.projectedReleaseCondition.code
       AND (Cast(l.ageAtAssignment as Integer) >= lf.minAge OR lf.minAge IS NULL)
       AND (Cast(l.ageAtAssignment as Integer) < lf.maxAge OR lf.maxAge IS NULL)
       AND lf.active = true)

where (l.leasetype = 'Research Assignment P51 Adult') and l.daylease <> 'yes'

UNION


--day lease no condition change
SELECT l.id,
l.project.name as CenterProject,
l.alias,
l.leasetype,
l.assignmentdate,
l.assignCondition.code,

l.projectedReleaseCondition.code as ProjectedReleaseCode,
Cast(l.ageAtAssignment as Integer) as AssignmentAge,
Case
	when l.daylease = 'yes' then '90'
end as ChargeID,
Null as RevisedChargeID,
l.dayleaselength as Quantity

FROM onprc_Billing.leaseFee_LeaseType  l
where l.daylease = 'yes' and l.leasetype <> 'Day Lease Research Assignment P51 NHP Condition Change'

UNION


--day lease condition change
SELECT l.id,
l.project.name as CenterProject,
l.alias,
l.leasetype,
l.assignmentdate,
l.assignCondition.code,

l.projectedReleaseCondition.code as ProjectedReleaseCode,
Cast(l.ageAtAssignment as Integer) as AssignmentAge,
lf.ChargeID,
Null as RevisedChargeID,

1 as  Quantity

FROM onprc_Billing.leaseFee_LeaseType  l
	left outer JOIN onprc_billing.leaseFeeDefinition lf ON (

       lf.assignCondition = l.assignCondition.code
       AND lf.releaseCondition = l.ReleaseCondition.code
       AND (Cast(l.ageAtAssignment as Integer) >= lf.minAge OR lf.minAge IS NULL)
       AND (Cast(l.ageAtAssignment as Integer) < lf.maxAge OR lf.maxAge IS NULL)
       AND lf.active = true)

where l.daylease = 'yes' and l.leasetype = 'Day Lease Research Assignment P51 NHP Condition Change'


UNION

SELECT l.id,
l.project.name as CenterProject,
l.alias,
l.leasetype,
l.assignmentdate,
l.assignCondition.code,

l.projectedReleaseCondition.code as ProjectedReleaseCode,
Cast(l.ageAtAssignment as Integer) as AssignmentAge,
Case
	when l.leasetype = 'Research Assignment P51 Infant' then lf.chargeId
end as ChargeID,
Null as RevisedChargeID,

1 as quantity

FROM onprc_Billing.leaseFee_LeaseType  l left outer JOIN onprc_billing.leaseFeeDefinition lf ON (

       lf.assignCondition = l.assignCondition.code
       AND lf.releaseCondition = l.projectedReleaseCondition.code
       AND (Cast(l.ageAtAssignment as Integer) >= lf.minAge OR lf.minAge IS NULL)
       AND (Cast(l.ageAtAssignment as Integer) < lf.maxAge OR lf.maxAge IS NULL)
       AND lf.active = true)

where (l.leasetype = 'Research Assignment P51 Infant') and l.daylease <> 'yes'

--deals with Release adjustmnents
UNION

Select
r.id,
r.project.name as CenterProject,
r.alias,
'Adjustment-Automatic' as LeaseType,
r.date,
r.assignCondition,
Null as ProjectedReleaseCondition,
r.ageatTime,
r.leasecharge2 as originalChargeID,
r.leasecharge1 as revisedChargeID,

1 as quantity


from onprc_billing.leaseFeeReleaseAdjustment r