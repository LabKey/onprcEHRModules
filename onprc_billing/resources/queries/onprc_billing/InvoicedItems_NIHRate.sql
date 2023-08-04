SELECT
    i.invoiceId,
    i.itemCode,
    i.unitCost,
    r.chargeId,
    r.startDate,
    r.enddate

FROM onprc_billing.invoicedItems i, onprc_billing.chargerates r
where i.itemCode = r.chargeID.itemCode