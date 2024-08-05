--This is being developed as the use of Merge replaces fields which is not the desired affect
--To end date the expired Protocols we will use a Stored Procedure based on this code.


EXEC core.fn_dropifexists 'ProtocolUpdate', 'onprc_ehr', 'TABLE';
-- Insert statements for procedure here
cREATE tABLE onprc_ehr.ProtocolUpdate
(BaseProtocol varchar(50) Not Null,
 RenewalNumber varchar(20) Not Null,
 Protocol_Id varchar(50) Not Null,
 Last_Modified varchar(30) not null ,
 Protocol_State varChar(50) not null,
 LatestREnewal varchar (30) Not Null);

--Populate the temporary table from query
Insert INTO  onprc_ehr.ProtocolUpdate(BaseProtocol,RenewalNumber,Protocol_id,Last_Modified,Protocol_State,LatestRenewal)
Select

    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 6,15)
         else p.protocol_id
        End as BaseProtocol,
    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 1,4)
         else 'Original'
        End as RenewalNumber,
    protocol_id,
    Protocol_State,
    Last_Modified,
    ' ' as LatestRenewal

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
Select * from  onprc_ehr.ProtocolUpdate
Update onprc_ehr.ProtocolUpdate
set LatestRenewal = 1
    from onprc_ehr.ProtocolUpdate p
where (p.BaseProtocol is not null and p.last_Modified = (Select Max(p1.Last_Modified) from onprc_ehr.ProtocolUpdate  p1 where p1.BaseProtocol = p.BaseProtocol))

--This section will determine if there are protocols that should be expired
Select
    protocol,
    external_id,
    endDate

from ehr.protocol
where external_id in (Select baseProtocol from onprc_ehr.ProtocolUpdate where LatestREnewal = 1 and Protocol_State = 'expired')
  and enddate is Null



Select * from  onprc_ehr.ProtocolUpdate
where LatestRenewal  =  1