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
--PARAMETERS(EndDate TIMESTAMP)

SELECT
  p.id,
  p.date,
  p.project,
  alias.alias as account,
  p.chargeId,
  p.chargeId.departmentCode as serviceCenter,
  p.categories,
  p.startDate,
  p.chargeId.name as item,
  p.chargeId.category as category,
  p.housingRecords as sourceRecord,
  alias.budgetstartdate as GrantStart,
  alias.farate,
  RateCalc2025(alias.alias,p.chargeID,p.project, alias.budgetstartdate,alias.farate) as unitCost



FROM onprc_billing.perDiems p

LEFT JOIN onprc_billing_public.chargeRates cr ON (
    CAST(p.date AS DATE) >= CAST(cr.startDate AS DATE) AND
    (CAST(p.date AS DATE) <= cr.enddateCoalesced OR cr.enddate IS NULL) AND
    p.chargeId = cr.chargeId
)

LEFT JOIN onprc_billing_public.projectAccountHistory aliasAtTime ON (
    aliasAtTime.project = p.project AND
    aliasAtTime.startDate <= cast(p.date as date) AND
    aliasAtTime.endDate >= cast(p.date as date)
    )
LEFT JOIN onprc_billing_public.aliases alias ON (
  aliasAtTime.account = alias.alias
)

LEFT JOIN onprc_billing_public.projectMultipliers pm ON (
    CAST(p.date AS DATE) >= CASt(pm.startDate AS DATE) AND
    (CAST(p.date AS DATE) <= pm.enddateCoalesced OR pm.enddate IS NULL) AND
    alias.alias = pm.account
)
Where p.id.demographics.species Not IN ('Rabbit','Guinea Pig')
