Update 20250813
Changed the from to read from onprc_billing instead of public


SELECT
c.chargetype as value

FROM onprc_billing.chargeUnits c
WHERE c.shownInBlood = true