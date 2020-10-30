Select
d.id,
d.calculated_Status,
d.earliestRemarkSinceReview,
d.lastVetReview,
d.lastDayAtCenter,
v.assignedVet
From demographics d, demographicsAssignedVet v
Where d.id = v.id
And ( (d.lastDayAtCenter >= timestampadd('SQL_TSI_Day', -90, Now())) or (d.lastDayAtCenter IS NULL))
and v.assignedVet is Not Null
