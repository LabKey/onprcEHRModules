SELECT chargetype
From Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.chargeUnits
Where servicecenter is null or servicecenter like 'PMIC'