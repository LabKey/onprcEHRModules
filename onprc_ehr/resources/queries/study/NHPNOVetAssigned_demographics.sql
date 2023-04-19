SELECT d.Id,
d.gender,
d.species,
d.geographic_origin,
d.birth,
d.death,
d.calculated_status,
d.id.assignedVet.assignedvet
FROM demographics d
where (d.calculated_status = 'alive' and d.id.assignedVet.assignedvet is null)