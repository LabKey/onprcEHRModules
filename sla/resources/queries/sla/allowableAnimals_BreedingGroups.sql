-- Modified the query to get the eIACUC data accurately. Included the TR protocols, By kollil 6/16/21
SELECT a.protocol,
       --c.protocol_id as eIACUC_protocol_name,
       a.species,
       --b.species as eIACUC_species_name,
       a.gender,
       a.strain,
       a.age,
       a.allowed,
       --b.Number_Of_Animals_Max as Allowed,
       a.startdate,
       a.enddate,
       'Group Id & Name - ' + b.group_id + ', ' + b.group_name + ', Breeding Allowed - ' + (Case When cast (b.breeding_colony AS varchar)  = '0' Then 'Yes'  Else 'No' END)  as Breeding_Info
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals a,
		Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS c,
    	Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.eIACUC_PRIME_VIEW_ANIMAL_GROUPS b
Where c.Protocol_State = 'Approved'
  And (c.protocol_Id = a.protocol.displayname OR c.protocol_Id like '%' + a.protocol.displayname)
  And c.protocol_Id = b.parent_protocol
  And curdate() between a.startdate And a.endDate
  And b.species = CASE
    WHEN a.species = 'Mice'	THEN 'Mouse'
    WHEN a.species = 'Rats'	THEN 'Rat'
    WHEN a.species = 'Rabbits' THEN 'Rabbit'
    WHEN a.species = 'Guinea Pigs' THEN 'Guinea Pig'
    ELSE 'unknown'
END



