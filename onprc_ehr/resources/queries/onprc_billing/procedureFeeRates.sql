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
SELECT
  p.*,
  p.chargeId.name as item,
  p.chargeId.category as category,
  coalesce(e.unitCost, cr.unitCost) as unitCost,
  1 as quantity,
  coalesce(e.unitCost, cr.unitCost) as totalcost,
  ce.account as creditAccount,
  ce.rowid as creditAccountId,
  CASE
    WHEN e.unitCost IS NOT NULL THEN 'Y'
    ELSE null
  END as isExemption,
  CASE
    WHEN (e.unitCost IS NULL AND cr.unitCost IS NULL) THEN 'Y'
    ELSE null
  END as lacksRate,
  e.rowid as exemptionId,
  CASE WHEN e.rowid IS NULL THEN cr.rowid ELSE null END as rateId,

  --find assignment on this date
  CASE
  WHEN p.project IS NULL THEN 'N'
  WHEN p.project.alwaysavailable = true THEN null
  WHEN (SELECT count(*) as projects FROM study.assignment a WHERE
    p.Id = a.Id AND
    p.project = a.project AND
    (cast(p.date AS DATE) < a.enddateCoalesced OR a.enddate IS NULL) AND
    p.date >= a.dateOnly
  ) > 0 THEN null
  ELSE 'N' END as matchesProject,
  null as isMiscCharge,
  (SELECT group_concat(distinct a.project.displayName, chr(10)) as projects FROM study.assignment a WHERE
    p.Id = a.Id AND
    p.project = a.project AND
    (cast(p.date AS DATE) < a.enddateCoalesced OR a.enddate IS NULL) AND
    p.date >= a.dateOnly
  ) as assignmentAtTime,
  CASE WHEN p.project.account IS NULL THEN 'Y' ELSE null END as isMissingAccount,
  CASE
    WHEN ifdefined(p.project.account.aliasEnabled) IS NULL THEN null
    WHEN (ifdefined(p.project.account.aliasEnabled) IS NULL OR ifdefined(p.project.account.aliasEnabled) != 'Y') THEN 'Y'
    ELSE null
  END as isExpiredAccount

FROM onprc_billing.procedureFees p

LEFT JOIN onprc_billing.chargeRates cr ON (
    p.date >= cr.startDate AND
    p.date <= cr.enddateTimeCoalesced AND
    p.chargeId = cr.chargeId
)

LEFT JOIN onprc_billing.chargeRateExemptions e ON (
    p.date >= e.startDate AND
    p.date <= e.enddateTimeCoalesced AND
    p.chargeId = e.chargeId AND
    p.project = e.project
)

LEFT JOIN onprc_billing.creditAccount ce ON (
    p.date >= ce.startDate AND
    p.date <= ce.enddateTimeCoalesced AND
    p.chargeId = ce.chargeId
)


UNION ALL

--add misc charges
SELECT
  mc.id,
  mc.date,
  mc.project,
  null as procedureId,
  mc.chargeId,
  mc.sourceRecord,

  mc.item,
  mc.category,
  mc.unitcost,
  mc.quantity,
  mc.totalcost,

  mc.creditAccount,
  mc.creditAccountId,
  mc.isExemption,
  mc.lacksRate,
  mc.exemptionId,
  mc.rateId,
  mc.matchesProject as matchesProject,
  'Y' as isMiscCharge,
  mc.assignmentAtTime,
  mc.isMissingAccount,
  mc.isExpiredAccount

FROM onprc_billing.miscChargesFeeRateData mc
WHERE cast(mc.billingDate as date) >= CAST(StartDate as date) AND cast(mc.billingDate as date) <= CAST(EndDate as date)
AND mc.category IN ('Surgical Procedure', 'Clinical Procedure')
