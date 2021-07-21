SELECT a.protocol,
       a.species,
       a.gender,
       a.strain,
       a.age,
       a.allowed,
       a.startdate,
       a.enddate,
       b.group_id,
       b.group_name,
       b.breeding_colony as BreedingAllowed
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals a,
    Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.eIACUC_PRIME_VIEW_ANIMAL_GROUPS b
Where a.protocol.displayname = b.parent_protocol