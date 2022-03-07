SELECT p.protocol,
       p.external_id,
       p.renewaldate,
       p.last_modified,
       p.displayName,
       'Protocol End Date and State Updated per reivew with Integrity Team'  as Description,
       'Expired' as PROTOCOL_State

FROM protocol p
where (p.renewaldate <= '3/1/2022' and p.enddate is null)