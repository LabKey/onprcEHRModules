SELECT
  p.parent as Id,
  p.date,
  p.Id as FosterChild,
  p.relationship,
  p.method

FROM study.parentage p
WHERE p.qcstate.publicdata = true and p.enddateCoalesced <= now()
And p.relationship = 'Foster Dam'