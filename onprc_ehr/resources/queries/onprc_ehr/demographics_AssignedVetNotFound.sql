<!--20230614 changed the link to vet review-->
SELECT d.Id,
       d.gender,
       d.species,
       d.geographic_origin,
       d.birth,
       d.death,
       d.calculated_status,
       d.id.assignedVet.assignedvet,
       d.id.assignedVet.AssignmentType

FROM demographics d
where d.calculated_status = 'Alive'
  and (d.id Not Like 'gp%' or d.id  not like 'rp%')
  and d.id.assignedVet.assignedVet is Null