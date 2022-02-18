SELECT e.rowid,
       e.Protocol_ID,
       e.Template_OID,
       e.Protocol_OID,
       e.Protocol_Title,
       Case
           When len(e.Protocol_ID) > 10 then ('Renewal for Original Protocol ' + Substring(e.protocol_ID,6,15) + ' added ' + cast(e.created  as varchar(20)))
           else (e.Protocol_ID + ' added  as New Protocol ' + cast(e.created  as varchar(20)))
           End  as Description,

       e.PI_ID,
       i.userID as InvestigatorID,
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



FROM eIACUC_PRIME_VIEW_PROTOCOLS e left outer join onprc_ehr.investigators i on e.pi_id = i.employeeid
where (e.protocol_state not in ('Withdrawn','terminated', 'Expired')
    and e.protocol_id not in (Select protocol from ehr.protocol where enddate is null))