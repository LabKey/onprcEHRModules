/*
 * Copyright (c) 2010-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(RequirementSet CHAR)

SELECT
  t2.*,
  CASE
    WHEN (t2.sqFtStatus LIKE '%ERROR%' OR t2.heightStatus LIKE '%ERROR%') THEN 'ERROR'
    WHEN (t2.sqFtStatus LIKE '%WARN%' OR t2.heightStatus LIKE '%WARN%') THEN 'WARNING'
    WHEN (t2.sqFtStatus LIKE '%NOTE%' OR t2.heightStatus LIKE '%NOTE%') THEN 'NOTE'
    ELSE null
  END as status
FROM (
SELECT
   t.room,
   t.cage,
   jc.numCages,
   jc.cages,
   jc.cageTypes,
   t.totalAnimals,
   t.distinctAnimals,
   t.weights,
   t.totalWeight,
   t.rawWeight,
   jc.totalSqFt,
   t.requiredSqFt,
   t.requiredSqFtIncluding5Mo,
   t.requiredHeight,
   t.minCageHeight,
   CASE
     WHEN (jc.totalSqFt < t.requiredSqFt AND t.totalWeightExempt != t.totalAnimals) THEN ('ERROR: Insufficient Sq. Ft, needs at least: ' || cast(t.requiredSqFt as varchar))
     WHEN (jc.totalSqFt < t.requiredSqFtIncluding5Mo AND t.totalWeightExempt != t.totalAnimals) THEN ('WARNING: When including 5 month olds, insufficient Sq. Ft, needs at least: ' || cast(t.requiredSqFtIncluding5Mo as varchar))
     WHEN (jc.totalSqFt < t.requiredSqFt AND t.totalWeightExempt = t.totalAnimals) THEN ('NOTE: Insufficient Sq. Ft, needs at least: ' || cast(t.requiredSqFt as varchar) || ', but has exemptions')
     ELSE null
   END as sqFtStatus,
   t.heightStatus,
  t.weightExempt,
  t.totalWeightExempt,
  t.totalHeightExempt,

FROM (

SELECT
    t0.room,
    t0.effectiveCage as cage,
    count(DISTINCT t0.id) as totalAnimals,
    SUM(CASE WHEN t0.ageInMonths >= 6.0 THEN 0 ELSE 1 END) as totalAnimalsUnder6Mo,
    SUM(CASE WHEN t0.ageInMonths = 5.0 THEN 0 ELSE 1 END) as totalAnimals5MonthsOld,
    group_concat(DISTINCT t0.id, chr(10)) as distinctAnimals,
    cast(sum(CASE
      WHEN t0.ageInMonths >= 6.0 THEN t0.MostRecentWeight
      ELSE 0
    END) as float) as totalWeight,
    cast(sum(t0.MostRecentWeight) as float) as rawWeight,
    min(t0.cageHeight) as minCageHeight,

    sum(CASE WHEN (t0.ageInMonths >= 6.0) THEN t0.requiredSqFt ELSE 0.0 END) as requiredSqFt,
    sum(CASE WHEN (t0.ageInMonths >= 5.0) THEN t0.requiredSqFt ELSE 0.0 END) as requiredSqFtIncluding5Mo,
    sum(t0.requiredSqFt) as requiredSqFtForAll,
    max(t0.requiredHeight) as requiredHeight,
    group_concat(t0.mostRecentWeight) as weights,
    group_concat(t0.heightStatus, chr(10)) as heightStatus,
    group_concat(CASE WHEN t0.weightExemption IS NULL THEN NULL ELSE t0.Id END) as weightExempt,
    sum(CASE WHEN t0.weightExemption IS NULL THEN 0 ELSE 1 END) as totalWeightExempt,
    count(t0.heightExemption) as totalHeightExempt

FROM (

SELECT
  pc.room,
  pc.effectiveCage,
  h.id,
  h.Id.age.ageInMonths as ageInMonths,
  h.Id.MostRecentWeight.MostRecentWeight as MostRecentWeight,
  pc.cage_type.height as cageHeight,
  c1.sqft as requiredSqFt,
  c1.height as requiredHeight,
  group_concat(c1.height) as heights,
  f.heightExemption,
  CASE
    WHEN (pc.cage_type.height < c1.height AND f.heightExemption IS NULL) THEN ('ERROR: Insufficient height, ' || h.id ||' needs at least: ' || cast(c1.height AS varchar(50)))
    WHEN (pc.cage_type.height < c1.height AND f.heightExemption IS NOT NULL) THEN cast(('NOTE: Height Exemption: ' || h.Id) as varchar(500))
    ELSE null
  END as heightStatus,
  wf.weightExemption

FROM ehr_lookups.connectedCages pc

JOIN study.housing h ON (h.room = pc.room AND pc.cage = h.cage AND h.isActive = true)

--height flags
LEFT JOIN (
  SELECT
    f.id,
    min(f.flag.value) as heightExemption
  FROM study.flags f
  WHERE f.isActive = true AND f.flag.category = 'Caging Note' and (f.flag.value = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.CAGE_HEIGHT_EXEMPTION_FLAG') OR f.flag.value = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.CAGE_MEDICAL_EXEMPTION_FLAG'))
  GROUP BY f.Id
) f on (f.Id = h.Id)

--weight flags
LEFT JOIN (
  SELECT
    f.id,
    min(f.flag.value) as weightExemption
  FROM study.flags f
  WHERE f.isActive = true AND f.flag.category = 'Caging Note' and (f.flag.value = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.CAGE_WEIGHT_EXEMPTION_FLAG') or f.flag.value = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.CAGE_MEDICAL_EXEMPTION_FLAG'))
  GROUP BY f.Id
) wf on (wf.Id = h.Id)

LEFT JOIN ehr_lookups.cageclass c1 ON (c1.low <= h.Id.mostRecentWeight.mostRecentWeight AND h.Id.mostRecentWeight.mostRecentWeight < c1.high AND c1.requirementset = RequirementSet)

) t0

GROUP BY t0.room, t0.effectiveCage

) t

LEFT JOIN ehr_lookups.connectedCageSummary jc ON (t.cage = jc.effectiveCage AND t.room = jc.room)

) t2