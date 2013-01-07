PARAMETERS(STARTDATE TIMESTAMP, ENDDATE TIMESTAMP)

SELECT
a.id,
a.date,
a.project,
a.enddate,
a.projectedReleaseCondition,
a.releaseCondition,
a.assignCondition,
lf.chargeId,
null as chargeId2

FROM study.assignment a
LEFT JOIN onprc_billing.leaseFeeDefinition lf
  ON (lf.assignCondition = a.assignCondition AND lf.releaseCondition = a.releaseCondition AND (a.id.age.ageInYears >= lf.minAge AND lf.minAge IS NULL) AND (a.id.age.ageInYears < lf.maxAge OR lf.maxAge IS NULL))
WHERE CONVERT(a.date, DATE) >= STARTDATE AND CONVERT(a.date, DATE) <= ENDDATE
AND a.qcstate.publicdata = true AND lf.active = true

--add released animals that need adjustments
UNION ALL

SELECT
a.id,
a.date,
a.project,
a.enddate,
a.projectedReleaseCondition,
a.releaseCondition,
a.assignCondition,
lf.chargeId,
lf2.chargeId as chargeId2

FROM study.assignment a
LEFT JOIN onprc_billing.leaseFeeDefinition lf
  ON (lf.assignCondition = a.assignCondition AND lf.releaseCondition = a.releaseCondition AND (a.id.age.ageInYears >= lf.minAge AND lf.minAge IS NULL) AND (a.id.age.ageInYears < lf.maxAge OR lf.maxAge IS NULL))

--TODO: should this be based on age at time of assignment?
LEFT JOIN onprc_billing.leaseFeeDefinition lf2
  ON (lf2.assignCondition = a.assignCondition AND lf2.releaseCondition = a.projectedReleaseCondition AND (a.id.age.ageInYears >= lf.minAge AND lf.minAge IS NULL) AND (a.id.age.ageInYears < lf2.maxAge OR lf2.maxAge IS NULL))

WHERE a.releaseCondition != a.projectedReleaseCondition
AND a.enddate is not null AND CONVERT(a.enddateCoalesced, DATE) >= STARTDATE AND CONVERT(a.enddateCoalesced, date) <= ENDDATE
AND a.qcstate.publicdata = true AND lf.active = true

