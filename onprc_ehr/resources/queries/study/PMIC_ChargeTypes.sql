SELECT chargetype
From Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing.chargeUnits
Where servicecenter is null or servicecenter like 'PMIC'
