PARAMETERS(chargeDate TIMESTAMP DEFAULT '1/1/2019')

SELECT lf.rowId,
--lf.minAge,
--lf.maxAge,
--lf.assignCondition,
--lf.releaseCondition,
lf.chargeId,
lf.chargeid.rowId as lfRowID,
cr.chargeid.rowid as CRRowID,
cr.unitcost,
lf.chargeunit,
lf.active,
lf.startDate as lfstartdate,
cr.startDate as CRStartdate,
lf.endDate as lfenddate,
cr.enddate as crEndDate
FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeDefinition lf
    join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.chargeRates cr
        on lf.chargeID.rowid = cr.chargeID.rowid --and lf.startdate >= cr.startDate and lf.enddate <= cr.enddate)
where ((lf.startdate <= chargedate and lf.enddate >= chargedate)
    and (cr.startdate <=Chargedate and cr.enddate >= chargedate))