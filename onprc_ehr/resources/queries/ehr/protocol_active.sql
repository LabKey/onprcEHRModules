SELECT
       protocol,
       protocol.displayName as displayName

FROM ehr.protocol
where (enddate is null or enddate >= Now())
order by protocol