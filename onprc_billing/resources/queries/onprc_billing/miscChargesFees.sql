/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 * UPDATE 1/8/2023 - ADDING lINKED sCHEMA TO iNVOICE rUNS AND iNVOICES iTEMS TO GET iNVOICE nUMBER
 *  Rebuild as unwanted files included
 * THis addition includes the Linked Schea to Invoice Runs and Ivoice Items
 */



SELECT
    mc.Id,
    mc.date,
    mc.billingDate,
    mc.project,
    mc.chargeId,
    mc.item,
    mc.quantity,
    round(CAST(CASE
                   --order of priority for unit cost:
                   --project-level exemption: pay this value
                   WHEN (e.unitCost IS NOT NULL) THEN e.unitCost
                   --project-level multiplier: multiply NIH rate by this value
                   WHEN (pm.multiplier IS NOT NULL AND cr.unitCost IS NOT NULL) THEN (cr.unitCost * pm.multiplier)
                   --if there is not a known rate, we dont know what do to
                   WHEN (cr.unitCost IS NULL) THEN null
                   --for non-OGA aliases, we always use the NIH rate
                   WHEN (alias.category IS NOT NULL AND alias.category != 'OGA') THEN cr.unitCost
                   --if we dont know the aliasType, we also dont know what do to
                   WHEN (alias.aliasType.removeSubsidy = true AND (alias.aliasType.canRaiseFA = true AND mc.chargeId.canRaiseFA = true)) THEN ((cr.unitCost / (1 - COALESCE(cr.subsidy, 0))) * (CASE WHEN (alias.faRate IS NOT NULL AND alias.faRate < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE)) THEN
                                                                                                                                                                                                         ((1 + (CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE) / (1 + alias.faRate)))) ELSE 1 END))

                   --remove subsidy only
                   WHEN (alias.aliasType.removeSubsidy = true AND alias.aliasType.canRaiseFA = false) THEN (cr.unitCost / (1 - COALESCE(cr.subsidy, 0)))

                   --raise F&A only
                   --WHEN (alias.aliasType.removeSubsidy = false AND (alias.aliasType.canRaiseFA = true AND mc.chargeId.canRaiseFA = true)) THEN (cr.unitCost * (CASE WHEN (alias.faRate IS NOT NULL AND alias.faRate < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE)) THEN (1 + (CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE) - alias.faRate)) ELSE 1 END))
                   WHEN (alias.aliasType.removeSubsidy = false AND (alias.aliasType.canRaiseFA = true AND mc.chargeId.canRaiseFA = true)) THEN (cr.unitCost * (CASE WHEN (alias.faRate IS NOT NULL AND alias.faRate < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE)) THEN ((1 + (CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE)))/(1+ alias.faRate)) ELSE 1 END))
                   --the NIH rate
                   ELSE cr.unitCost
                   END AS DOUBLE), 2) as unitCost,
    --mc.unitCost,
    mc.category,
    mc.chargeCategory,
    mc.invoicedItemId,
    mc.objectid as sourceRecord,
    mc.comment,
    mc.debitedaccount,
    mc.creditedaccount,
    mc.sourceInvoicedItem,
    ir.rowID as InvoiceNumber,
    invoiceItem.transactionNumber,
    --(Select invoiceNumber from study_finance.invoiceRuns where objectID = mc.invoiceID) as InvoiceNumber,
    mc.taskid,
    mc.chargeType as chargeUnit

FROM onprc_billing.miscCharges mc

         LEFT JOIN onprc_billing_public.chargeRates cr ON (
    CAST(mc.date AS DATE) >= CAST(cr.startDate AS DATE) AND
    (CAST(mc.date AS DATE) <= cr.enddateCoalesced OR cr.enddate IS NULL) AND
    mc.chargeId = cr.chargeId
    )

         LEFT JOIN onprc_billing_public.chargeRateExemptions e ON (
    CAST(mc.date AS DATE) >= CAST(e.startDate AS DATE) AND
    (CAST(mc.date AS DATE) <= e.enddateCoalesced OR e.enddate IS NULL) AND
    mc.chargeId = e.chargeId AND
    mc.project = e.project
    )

         LEFT JOIN onprc_billing_public.creditAccount ce ON (
    CAST(mc.date AS DATE) >= CAST(ce.startDate AS DATE) AND
    (CAST(mc.date AS DATE) <= ce.enddateCoalesced OR ce.enddate IS NULL) AND
    mc.chargeId = ce.chargeId
    )

         LEFT JOIN onprc_billing_public.projectAccountHistory aliasAtTime ON (
    aliasAtTime.project = mc.project AND
    aliasAtTime.startDate <= cast(mc.date as date) AND
    aliasAtTime.endDate >= cast(mc.date as date)
    )

         LEFT JOIN onprc_billing_public.aliases alias ON (
    aliasAtTime.account = alias.alias and alias.datedisabled is null
    )

         LEFT JOIN onprc_billing_public.projectMultipliers pm ON (
    CAST(mc.date AS DATE) >= CASt(pm.startDate AS DATE) AND
    (CAST(mc.date AS DATE) <= pm.enddateCoalesced OR pm.enddate IS NULL) AND
    alias.alias = pm.account)
         LEFT JOIN study_billing.invoiceRuns ir on
    ir.objectID = mc.invoiceID
         LEFT JOIN study_billing.invoicedItems InvoiceItem on
    invoiceItem.objectID = mc.sourceInvoicedItem