--PARAMETERS(A VARCHAR DEFAULT '9012221',P double DEFAULT 277,
--   c DOUBLE DEFAULT 1477,
--   s TIMESTAMP DEFAULT '1/1/2019',
--   B DOUBLE
--   )
--2019-11-22 clean up of code onn function had a bad date select
Select
c.id,
c.CenterProject,
c.alias,
c.alias as ChargeTO,
t.creditTo,
c.projectID,
c.chargeId,
t.leasetype,
r.unitcost,
c.assignmentDate,
t.faRate,
t.removesubsidy,
t.canRaiseFA,

RateCalc(c.alias,c.chargeID,c.projectID,c.assignmentDate,t.farate)  as CalculatedRate

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.leasefee_RateData c
	left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.chargeRates r
	    on c.chargeID = r.chargeID
	left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.leasefee_leaseType t
	    on (c.id = t.id and c.projectID = t.projectID and t.assignmentDate = c.assignmentDate)
where r.startDate <= c.assignmentDate and r.enddate >= c.assignmentDate