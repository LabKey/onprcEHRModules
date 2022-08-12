/* Added change to make it work */
SELECT
p.Protocol_ID as protocol,
p.Template_OID,
p.Protocol_OID,
p.Protocol_Title as Title,
(Select rowID  from onprc_ehr.investigators where employeeID = p.PI_ID and datedisabled is Null) as InvestigatorID,
--p.PI_ID as investigatorID,
--p.PI_First_Name,
--p.PI_Last_Name,
p.PI_Email,
p.PI_Phone,
p.USDA_Level,
p.Approval_Date as approve,
p.Annual_Update_Due,
p.Three_year_Expiration,
p.Last_Modified,
p.created,
p.modifiedby,
p.modified,
p.PROTOCOL_State,
--Use the Protocol_State to determine end date of a protocol
Case
    When p.protocol_State Not Like 'Approved' then p.last_MOdified
    Else Null
    End as enddate,
p.PPQ_Numbers,
p.Description
FROM eIACUC_PRIME_VIEW_PROTOCOLS p
where len(p.PI_ID) > 3