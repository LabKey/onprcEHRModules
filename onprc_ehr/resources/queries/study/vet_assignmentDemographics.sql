--Reviewed 2/7/2019 to update from vet_AssignmentDemographics_new
--Is the depenency for vet_assignmentSelect
--Reviewed 2/7/2019 to update from vet_AssignmentDemographics_new
--Is the depenency for vet_assignmentSelect

SELECT
Distinct

d.Id,
d.gender,
d.species,
d.geographic_origin,
d.birth,
d.death,
d.lastDayatCenter,
h.room.area,
h.room,
d.calculated_status,
TimeStampAdd('SQL_TSI_YEAR', -1,Now()) as LastYear,
n.assignedVet as DeceaseDAssignedVet,
c.vetNames as CaseVet,
c.category,
	CASE
          WHEN (n.id IS NOT null) THEN 'DECEASED or SHIPPED NHP'
          WHEN (c.id IS NOT NULL) THEN 'Active Case'
	      WHen r1.id is not null then 'Research Assigned'
		  WHen r2.id is not null then 'Resource Assigned'

    	ELSE 'P51'
 	 END as assignmentType,

Case
    when r1.protocol is not null then r1.use_Category
    when r2.protocol is not null then r2.use_category
    else  ' '
    End As use_category,
--r1.use_Category,
--This needs to be a case statement that resturned the protocol whether Resource or research with research being the priority

Case
    when r1.protocol is not null then r1.protocol.displayName
    when r2.protocol is not null then r2.protocol.displayName
    else  ' '
    End As protocol,

--r1.protocol
FROM study.demographics d

--Handles Deceased NHPs

LEFT JOIN (
   select r.id, r.assignedVet


	from study.demographics d1 join study.clinremarks r on d1.id = r.id
		where d1.lastdayatCenter > TimeStampAdd('SQL_TSI_month', -12,Now())
        and r.date = (Select Max(r1.date) from study.clinremarks r1 where r1.id = d1.id))



 n on (n.Id =d.id)


--Handles NHPS with open Cases

LEFT JOIN (
    SELECT
    c.Id,
   c.category,
    c.assignedvet.DisplayName as vetNames,
    c.date

  FROM study.cases c
  WHERE (c.category not in ('Behavior','Surgery')
  and c.IsOpen = 'true')
  --and c.enddateCoalesced >= curdate() )
  --and c.allProblemCategories not like 'Routine%'
  GROUP BY c.Id,c.category,c.date,c.assignedvet.DisplayName
) c ON (c.Id = d.Id)

--Review for Assigned Animals
Left Join study.vet_AssignedResearch r1 on d.id = r1.id
Left Join study.vet_assignedResource r2 on d.id = r2.id --and r2.id not in  (Select r3.id from study.vet_AssignedResearch r3)
Left Join study.housing h on h.id  = d.id and (h.enddateTimeCoalesced >= now())

--report only on animals that are alive or deceased in last year
where
	(d.lastDayAtCenter is Null or d.lastDayAtCenter >  TimeStampAdd('SQL_TSI_MONTH', -12,Now()))
	 --(d.calculated_Status = 'Alive' OR  (d.death is null or d.death > TimeStampAdd('SQL_TSI_MONTH', -2,Now()))
	 and d.id not Like '[A-Z]%'