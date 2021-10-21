--Created ny kollil on 10/18/21 to dispaly the allowable SLAs with eIACUCNum but no breeding info.
--This query dispalys the allowable SLAs on protocol details page with eIACUCNum
SELECT a.protocol,
       c.protocol_id as eIACUC_protocol_name,
       a.species,
       a.gender,
       a.strain,
       a.age,
       a.allowed,
       a.startdate,
       a.enddate
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals a,
    Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS c
Where c.Protocol_State = 'Approved'
  And (c.protocol_Id = a.protocol.displayname OR c.protocol_Id like '%' + a.protocol.displayname)
  And curdate() between a.startdate And a.endDate