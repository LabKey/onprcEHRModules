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
PARAMETERS(EndDate TIMESTAMP)

SELECT
  p.*,
  p.chargeId.name as item,
  null sourceRecord,
  coalesce(e.unitCost, cr.unitCost) as unitCost,
  p.effectiveDays as quantity,
  p.effectiveDays * coalesce(e.unitCost, cr.unitCost) as totalcost,

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
  'N' as isMiscCharge

FROM onprc_billing.perDiems p

LEFT JOIN onprc_billing.chargeRates cr ON (
    p.startdate >= cr.startDate AND
    p.startdate <= cr.enddateTimeCoalesced AND
    p.chargeId = cr.chargeId
)

LEFT JOIN onprc_billing.chargeRateExemptions e ON (
    p.startdate >= e.startDate AND
    p.startdate <= e.enddateTimeCoalesced AND
    p.chargeId = e.chargeId AND
    p.project = e.project
)

LEFT JOIN onprc_billing.creditAccount ce ON (
    p.startdate >= ce.startDate AND
    p.startdate <= ce.enddateTimeCoalesced AND
    p.chargeId = ce.chargeId
)

UNION ALL

--add misc charges
SELECT
  mc.id,
  mc.date,
  mc.project,
  mc.chargeId,
  null as categories,
  null as overlappingProjects,
  null as effectiveDays,
  null as totalDaysAssigned,
  null as startDate,
  null as numDays,
  mc.item,
  mc.sourceRecord,
  mc.unitcost,
  mc.quantity,
  mc.totalcost,

  mc.creditAccount,
  mc.creditAccountId,
  mc.isExemption,
  mc.lacksRate,
  mc.exemptionId,
  mc.rateId,
  'Y' as isMiscCharge

FROM onprc_billing.miscChargesFeeRateData mc
WHERE cast(mc.billingDate as date) >= CAST(StartDate as date) AND cast(mc.billingDate as date) <= CAST(EndDate as date)
AND mc.category = 'Animal Per Diem'