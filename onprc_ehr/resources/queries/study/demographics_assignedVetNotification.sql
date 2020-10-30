--date:  6/19/2019
--Promotoed to UAT by gjones

SELECT
d.id,
d.calculated_Status,
d.earliestRemarkSinceReview,
d.lastVetReview,
v.assignedVet
FROM demographicsAssignedVet v join demographics d on v.id = d.id
where d.lastDayAtCenter > TimestampDiff('SQL_TSI_Day', 90, Now())