Select 'eiacuc' as source,
        e.Protocol_ID,
       e.Protocol_Title,
        e.PROTOCOL_State,
        Case
            when len(e.protocol_ID) > 10 then substring(e.protocol_id, 6,15)
            Else e.protocol_id
        End as original_Protocol,
       e.Template_OID,
       e.Approval_Date
        /*e.
       e.Protocol_OID,

       e.PI_ID,
       e.PI_First_Name,
       e.PI_Last_Name,
       e.PI_Email,
       e.PI_Phone,
       e.USDA_Level,
       e.Approval_Date
        e.Annual_Update_Due,
        e.Three_year_Expiration,
       e.Last_Modified,
       e.createdby,
       e.created,
       e.modifiedby,
       e.modified,

       e.PPQ_Numbers,
       e.Description*/


from eIACUCImport.eIACUC_PRIME_VIEW_PROTOCOLS e
where e.Protocol_State Not in ('terminated','withdrawn','expired')

Union All
--docuemtnation on Union

SELECT
    'Prime' as Source,
    p.external_id as PrimeProtocol,
    p.title,
    p.protocol_state,
    p.external_id as original_protocol,
    p.Template_OID,
    p.approve
    /*p.investigatorId,
    p.approve,
    p.lastAnnualReview,
    p.enddate,
    p.external_id,
    p.ibc_approval_num,
    p.usda_level,
    p.last_modification,
    p.description,
    p.container,
    p.contacts,
    p.PPQ_Numbers,
    p.PROTOCOL_State,
    p.Template_OID,
    p.Approval_Date,
    p.Annual_Update_Due,
    p.Three_year_Expiration,
    p.last_modified,
    p.displayName,
    p.annualReviewDate,
    p.daysUntilAnnualReview,
    p.renewalDate,
    p.daysUntilRenewal*/
FROM prime_protocols.protocol p
where p.enddate is null