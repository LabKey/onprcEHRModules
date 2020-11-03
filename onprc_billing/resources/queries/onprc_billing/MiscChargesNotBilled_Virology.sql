--New query as source of Misc CHarges Not yet billing will replace needed items in Test and Production
SELECT d.Id,
d.date,
d.billingDate,
d.project,
d.account as ChargeTo,
d.chargetype as CreditTo,
d.creditAccount,
d.creditAccountType,
d.investigatorId,
d.chargeId,
d.category,
d.item,
d.unitCost,
m.unitCost as nihRate,
d.quantity,
Sum(d.unitCost * d.quantity) as TOtalCharges,
d.chargeCategory,
d.comment,

d.invoiceId,
d.created,
d.createdby,
m.taskId
FROM MiscChargeswithRates d join MiscCharges m on d.taskId = m.taskId and d.sourceRecord = m.objectID
where d.invoiceID is null and d.category = 'Virology'
Group by
d.Id,
d.date,
d.billingDate,
d.project,
d.account,
d.chargetype,
d.creditAccount,
d.creditAccountType,
d.investigatorId,
d.chargeId,
d.category,
d.item,
d.unitCost,
m.unitCost,
d.quantity,
d.chargeCategory,
d.comment,

d.invoiceId,
d.created,
d.createdby,
m.taskId