SELECT
distinct name as procedureName

FROM (

select name from ehr_lookups.procedures

union all

select genericName as name FROM ehr_lookups.procedures

) t
