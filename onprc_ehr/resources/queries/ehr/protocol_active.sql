SELECT
       protocol,
       external_id

FROM ehr.protocol
where (enddate is null or enddate >= Now())
order by protocol