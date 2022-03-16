SELECT e.rowid,
       e.Protocol_ID,
       e.Template_OID,
       e.Protocol_OID,
       e.Protocol_Title,
       Case
            When e.protocol_state <> 'approved' then(('Protocolisnotactive,currentstatusis')+e.protocol_state)
            --When len(e.Protocol_ID) > 10 then ('RenewalforOriginalProtocol'+ Substring(e.protocol_ID,6,15) + 'added' + cast(e.createdasvarchar(20)))
            --else (e.Protocol_ID +' added as New Protocol '+ cast(e.createdasvarchar(20)))
            End as Description,
        Case
            Whene.protocol_statein('expired','terminated','withdrawn')thene.Last_Modified
            End as enddate,
        e.protocol_id as external_id,
       e.PI_ID,
      -- i.userID as InvestigatorID,
       e.PI_Last_Name,
       e.PI_Email,
       e.PI_Phone,
       e.USDA_Level,
       e.Approval_Date,
       e.Annual_Update_Due,
       e.Three_year_Expiration,
       e.Last_Modified,
       e.createdby,
       e.created,
       e.modifiedby,
       e.modified,
       e.PROTOCOL_State,
       e.PPQ_Numbers



FROM eIACUC_PRIME_VIEW_PROTOCOLS e