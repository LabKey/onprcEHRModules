SELECT Distinct
    resources.id,
    resources.Container
FROM resources
where name like'DCM%'