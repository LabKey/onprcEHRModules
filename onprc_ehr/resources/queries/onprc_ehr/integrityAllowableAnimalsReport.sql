--4/30/2025 Talked wiht KJim Ray and reviewed tghe current output
--she is not interested in the assigned animal counts
--she would like to PI added to the report and to provide a hyperlink from the Protocol Number
--Need to get the current report for allwoable animals in Prime
--New Name and definitions as I refine the process.

With eIACUCAuthorized as (
    SELECT

        g.Parent_Protocol as Protocol,
        g.Species,
        Sum(g.Number_of_Animals_Max) as TotalforSpecies


    FROM eIACUC_PRIME_VIEW_ANIMAL_GROUPS g left outer join eIACUC_PRIME_VIEW_PROTOCOLS p
                                                           on g.Parent_Protocol = p.protocol_id
    where p.protocol_state = 'Approved'
    Group by g.Parent_Protocol,g.Species),
--This will tie the animal authorized to the Base Protocol fior comparison

     BaseProtocolAssigned as (
         Select   a.protocol,
                  p.BaseProtocol,
                  p.RevisionNumber,
                  p.Protocol_State,
                  a.species,
                  a.TotalforSpecies


         from eIACUC_PRIME_VIEW_PROTOCOLS p join  eIACUCAuthorized a
                                                  on a.protocol = p.protocol_id

     ),


     AllowablefromProtocol as (
         Select
             a.protocol,
             a.species,
             Sum(a.allowed)


         From ehr.animalusage a
            Group BY
                a.protocol,
                a.species

     ),
--This will be the final report
     --Need to add a CTE for SLA
     AuthorizedNHP as (
         Select
             p.Protocol,
             --a.project,
             e.species,
             Sum(e.TotalForSpecies) as TotalAuthorized



         from   eIACUCAuthorized e , ehr.protocol p
         Where e.protocol = p.protocol
         Group by
             e.Protocol,
             e.species
     ),
    SummaryNHP as (
        Select
            a.protocol,
            a.species,
            a.TotalAuthorized

        from AuthorizedNHP a
        where a.species not in ('Rat','Mice','Rabbit')

    )
Select * from eIACUCAuthorized
--Select * from CurrentAssigned
--Select * from SummaryNHP
--Select * from BaseProtocolAssigned
--select * from AllowablefromProtocol