SELECT e.rowid,
e.Protocol_ID,
e.Protocol_Title as Title,
--Need to read the value from investigator table and provide id
(Select rowID from investigators where e.PI_ID = employeeID) as Inves,
e.Approval_Date as approve,

Case
            when len(e.protocol_ID) > 10 then substring(e.protocol_id, 6,15)
            Else e.protocol_id
        End as external_id,
e.USDA_Level,
e.Last_Modified,
 (Select distinct container from ehr.protocol) as container,
e.createdby,
e.created,
e.modifiedby,
e.modified,
e.PPQ_Numbers,
e.PROTOCOL_State,
e.Template_OID,
e.Approval_Date,
e.Three_year_Expiration,
e.Annual_Update_Due as AnnualReviewDate,
e.Description
FROM eIACUC_PRIME_VIEW_PROTOCOLS e