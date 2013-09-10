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
  p.id,
  p.date,
  p.enddate,
  p.project,
  p.projectedReleaseCondition,
  p.releaseCondition,
  p.assignCondition,
  p.ageAtTime,
  p.category,
  p.chargeId,

  p.leaseCharge1,
  p.leaseCharge2,

  CASE
    WHEN p.category = 'Lease Fee' THEN coalesce(e.unitcost, cr.unitcost)
    ELSE (coalesce(e3.unitcost, cr3.unitcost) - coalesce(e2.unitcost, cr2.unitcost))
  END as unitcost,

  ce.account,
  ce.rowid as creditAccountId,
  CASE
    WHEN e.unitcost IS NOT NULL THEN 'Y'
    ELSE null
  END as isExemption

FROM onprc_billing.leaseFees p

--the first charge
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

--the original charge (for adjustments)
LEFT JOIN onprc_billing.chargeRates cr2 ON (
    p.date >= cr2.startDate AND
    p.date <= cr2.enddateTimeCoalesced AND
    p.leaseCharge1 = cr2.chargeId
)

LEFT JOIN onprc_billing.chargeRateExemptions e2 ON (
    p.date >= e2.startDate AND
    p.date <= e2.enddateTimeCoalesced AND
    p.leaseCharge1 = e2.chargeId AND
    p.project = e2.project
)
--EO original charge

--the final charge (for adjustments)
LEFT JOIN onprc_billing.chargeRates cr3 ON (
  p.date >= cr3.startDate AND
  p.date <= cr3.enddateTimeCoalesced AND
  p.leaseCharge2 = cr3.chargeId
)

LEFT JOIN onprc_billing.chargeRateExemptions e3 ON (
  p.date >= e3.startDate AND
  p.date <= e3.enddateTimeCoalesced AND
  p.leaseCharge2 = e3.chargeId AND
  p.project = e3.project
)
--EO final charge

LEFT JOIN onprc_billing.creditAccount ce ON (
    p.date >= ce.startDate AND
    p.date <= ce.enddateTimeCoalesced AND
    p.chargeId = ce.chargeId
)