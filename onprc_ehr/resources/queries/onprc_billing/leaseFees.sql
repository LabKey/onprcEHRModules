/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
PARAMETERS(STARTDATE TIMESTAMP, ENDDATE TIMESTAMP)

SELECT
a.id,
a.date,
a.project,
a.enddate,
a.projectedReleaseCondition,
a.releaseCondition,
a.assignCondition,
a.ageAtTime.AgeAtTimeYearsRounded as ageAtTime,
lf.chargeId,
null as chargeId2

FROM study.assignment a
LEFT JOIN onprc_billing.leaseFeeDefinition lf
  ON (lf.assignCondition = a.assignCondition
    AND lf.releaseCondition = a.projectedReleaseCondition
    AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf.minAge OR lf.minAge IS NULL)
    AND (a.ageAtTime.AgeAtTimeYearsRounded < lf.maxAge OR lf.maxAge IS NULL)
  )
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
a.ageAtTime.AgeAtTimeYearsRounded as ageAtTime,
lf.chargeId,
lf2.chargeId as chargeId2

FROM study.assignment a
LEFT JOIN onprc_billing.leaseFeeDefinition lf
  ON (lf.assignCondition = a.assignCondition
    AND lf.releaseCondition = a.releaseCondition
    AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf.minAge OR lf.minAge IS NULL)
    AND (a.ageAtTime.AgeAtTimeYearsRounded < lf.maxAge OR lf.maxAge IS NULL)
  )

LEFT JOIN onprc_billing.leaseFeeDefinition lf2
  ON (lf2.assignCondition = a.assignCondition
    AND lf2.releaseCondition = a.projectedReleaseCondition
    AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf.minAge OR lf.minAge IS NULL)
    AND (a.ageAtTime.AgeAtTimeYearsRounded < lf2.maxAge OR lf2.maxAge IS NULL)
  )

WHERE a.releaseCondition != a.projectedReleaseCondition
AND a.enddate is not null AND CONVERT(a.enddateCoalesced, DATE) >= STARTDATE AND CONVERT(a.enddateCoalesced, date) <= ENDDATE
AND a.qcstate.publicdata = true AND lf.active = true

