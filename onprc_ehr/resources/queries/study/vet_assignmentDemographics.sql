--removed referennce to Project
SELECT
    Distinct

    Case
        when dm.Id is not null then dm.id
        else d.id
        end as id,
    b.gender,
    b.species,
    b.geographic_origin,
    b.date,
    dm.death as death,
    dm.LastDayAtCenter,
    h.room.area,
    h.room,
--d.calculated_status,
    Case
        when dm.id is not null then dm.calculated_status
        When d2.id = d.id then 'Deceased'
        wHEN D1.ID = d.id then 'Shipped'
        Else 'Unknown'
        End
        As Calculated_status,

    TimeStampAdd('SQL_TSI_YEAR', -1,Now()) as LastYear,
    Case
        when dm.calculated_status = 'alive' then Null
        When n.assignedVet is not Null then n.assignedVet
        when d3.assignedvet is not null then d3.assignedVet
        --   when cr.date >TimeStampAdd('SQL_TSI_MONTH', -12,Now())  then 'Remark OVer 12 Months'
        --when (n.assignedVet is null or d3.assignedVet is Null and cr.date >TimeStampAdd('SQL_TSI_MONTH', -12,Now()) ) then ''
        Else Null
        End as DeceasedAssignedVet,

--n.assignedVet as DeceaseDAssignedVet,
    c.vetNames as CaseVet,
    c.category,
    CASE
        --  When cr.id is null then 'No Clin Remarks Found'
        WHen dm.id = d.id and dm.calculated_status = 'dead' then 'Deceased NHP'
        When (d3.id = d.id) then 'Deceased NHP'
        WHEN (n.id IS NOT null) THEN 'SHIPPED NHP'
        WHEN (c.id IS NOT NULL) THEN 'Active Case'
        when s1.project is not null then s1.projectType
        when s2.project is not null then s2.projectType
        WHen r1.id is not null then r1.protocoltype
        WHen r2.id is not null then r2.protocoltype

        ELSE 'P51'
        END as assignmentType,

    Case
        when s1.project is not null then s1.use_category
        when s2.project is not null then s1.use_category
        when r1.protocol is not null then r1.use_Category
        when r2.protocol is not null then r2.use_category
        else  ' '
        End As use_category,
--r1.use_Category,
--This needs to be a case statement that resturned the protocol whether Resource or research with research being the priority

    Case
        when r1.protocol is not null then r1.VetAssignedProtocol
        when r2.protocol is not null then r2.VetAssignedProtocol
        else  ' '
        End As protocol,

    Case
        when s1.project is not null then s1.VetAssignedProject
        when s2.project is not null then s2.VetAssignedProject
        else  null
        End As project,

    Case
        when r1.protocol is not null then r1.PI
        when r2.protocol is not null then r2.PI
        else  ' '
        End As ProtocolPI

--r1.protocol
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.animal d

--Handles Shipped NHPs

LEFT JOIN (
   select r.id, r.assignedVet


	from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.departure d1 join study.clinremarks r on d1.id = r.id
		where d1.date > TimeStampAdd('SQL_TSI_month', -12,Now())
        and r.date = (Select Max(r1.date) AS MaxDate from study.clinremarks r1 where r1.id = d1.id))



 n on (n.Id =d.id)

--Handles Deceased NHPs

    LEFT JOIN (
    select d1.id, r.assignedVet


    from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.demographics d1 join
    Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.clinremarks r on d1.id = r.id
    where (d1.date > TimeStampAdd('SQL_TSI_month', -12,Now()) and d1.calculated_status = 'dead'
    and r.date = (Select Max(r1.date) AS MaxDate from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.clinremarks r1 where r1.id = d1.id)))



    d3 on (d3.Id =d.id)





--Handles NHPS with open Cases

    LEFT JOIN (
    SELECT
    c.Id,
    c.category,
    c.assignedvet.DisplayName as vetNames,
    c.date

    FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.cases c
    WHERE (c.category not in ('Behavior','Surgery')
    and c.IsOpen= 'true')
    --and c.enddateCoalesced >= curdate() )
    --and c.allProblemCategories not like 'Routine%'
    GROUP BY c.Id,c.category,c.date,c.assignedvet.DisplayName
    ) c ON (c.Id = d.Id)

--Review for Assigned Animals
    left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.birth b on b.id = d.id
    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.vet_AssignedResearch r1 on d.id = r1.id
    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.vet_assignedResource r2 on d.id = r2.id --and r2.id not in  (Select r3.id from study.vet_AssignedResearch r3)
    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.vet_AssignedResearch_project s1 on d.id = s1.id
    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.vet_assignedResource_project s2 on d.id = s2.id
    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.housing h on h.id  = d.id and (h.enddateTimeCoalesced >= now())
    left join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.deaths d1 on d.id  = d1.id
    left join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.departure d2 on d2.id = d.id
    left join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.demographics dm on dm.id = d.id
    --left join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.clinRemarks cr on cr.id = d.id


--report only on animals that are alive or deceased in last year
where
    dm.calculated_status = 'Alive' and
    (d2.date is Null or Cast(d2.date as varchar(20)) > d.MostRecentArrival or (d2.date >  TimeStampAdd('SQL_TSI_MONTH', -12,Now())))
  and (d.demographics.calculated_status is not null) --and
-- d.id not Like '[A-Z]%'
  and (d1.date < TimeStampAdd('SQL_TSI_DAY',-90,d1.date) or d1.date is Null)