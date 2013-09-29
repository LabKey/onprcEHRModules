--first find overlapping intervals
SELECT
  r1.chargeId,
  r1.rowid as rowid1,
  r1.startDate as startDate1,
  r1.enddate as endDate1,
  r2.rowid as rowid2,
  r2.startDate as startDate2,
  r2.enddate as endDate2
FROM onprc_billing.creditAccount r1
JOIN onprc_billing.creditAccount r2 ON (r1.rowid != r2.rowid and r1.chargeId = r2.chargeId AND cast(r1.startDate as DATE) <= r2.enddateCoalesced AND r1.enddateCoalesced >= cast(r2.startDate as DATE))