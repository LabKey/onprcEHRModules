--This query will populate a temp table with the values neeeded to add to protocols for Base Protocol and Revision Number
-- This will be converted to a stored procedure once ready
-- I have been running these in Management Studio against my Dev Database
-- Create the temporary table
CREATE TABLE #eIACUCUpdate
(rowid varchar(255) not Null,
 BaseProtocol varchar(50) Not Null,
 RevisionNumber varchar(20) Not Null,
 Protocol_Id varchar(50) Not Null);

--Populate the tempary table from query
Insert INTO #eIACUCUpdate(rowid,BaseProtocol,RevisionNumber,Protocol_id)
Select
    rowid,
    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 6,15)
         else p.protocol_id
        End as BaseProtocol,
    Case when len(p.protocol_id) > 10 then substring(p.protocol_id, 1,4)
         else 'Original'
        End as RevisionNumber,protocol_id


from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p

Select * from #eIACUCUpdate
--	DROP Table #eIACUCUpdate
--Need to update the table onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS with vlaues before I can limit what is prepared to update Protocols
Update p1
Set p1.BaseProtocol = e.BaseProtocol

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 join #eIACUCUpdate e on p1.protocol_id = e.Protocol_Id

Update p1
Set p1.RevisionNumber = e.RevisionNumber

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 join #eIACUCUpdate e on p1.protocol_id = e.Protocol_Id



--Now will limit the records to be inserted to most recent record


update p
Set p.description = 'Update'

    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
where p.last_Modified = (Select Max(p1.Last_Modified) from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p1 where p1.BaseProtocol = p.BaseProtocol)
  and p.BaseProtocol is not null


--At this point the onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS is ready to update ehr.protocol fields

--Find matching fields in ehr.protocol
select
    p.protocol,
    p.external_id,
    p.enddate,
    e.BaseProtocol,
    e.RevisionNumber,
    e.protocol_State,
    e.last_modified


from ehr.protocoltest p left join onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e on p.external_id = e.BaseProtocol
where e.description is not null and
  --determine if all ready enddates
    p.enddate is null

--Add the end of the processes need to set description field back to empty
Created [ehr].[protocol_test] in dev instance for testing

Update p
set p.enddate = e.Last_Modified, p.modified = getDate(),p.Protocol_State = e.Protocol_State,p.last_modified - e.Last_Modified
    from ehr.protocol_test p left join onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e on p.external_id = e.BaseProtocol
where e.description is not null






